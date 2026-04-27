---
title: 'Spec: Memory MCP Server'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases:
  - memory-mcp-server
  - sqlite-memory-mcp
  - agent-memory-server
---

# Spec: Memory MCP Server

**Purpose:** An MCP server that instantiates the [[agent-knowledge-vault]] as a query-able, agent-writable memory store. Provides two scopes — **session** (volatile, per-conversation) and **vault** (persistent, cross-session) — over a SQLite backend. Exposes memory via standard MCP Resources and Tools so any MCP-compatible agent (ADK, Claude, Swarm) can read and write without provider-specific APIs.

---

## 1. Architecture

```
┌─────────────────────────────────────────────────────┐
│                   MCP Host (Agent)                  │
│  ┌──────────────────────────────────────────────┐   │
│  │               MCP Client                    │   │
│  └──────────────────┬───────────────────────────┘   │
└─────────────────────┼───────────────────────────────┘
                      │ JSON-RPC 2.0 (Stdio or HTTP)
┌─────────────────────┴───────────────────────────────┐
│              Memory MCP Server                      │
│  ┌──────────────┐  ┌────────────────────────────┐   │
│  │  Resource     │  │        Tool Handlers       │   │
│  │  Handler      │  │  commit / search / prune   │   │
│  └──────┬───────┘  └───────────┬────────────────┘   │
│         └──────────────┬───────┘                    │
│              ┌──────────┴────────┐                   │
│              │   SQLite DB       │                   │
│              │  session_memories │                   │
│              │  vault_memories   │                   │
│              └───────────────────┘                   │
└─────────────────────────────────────────────────────┘
```

Transport: **Stdio** (default, for local agent use) or **Streamable HTTP** (for multi-agent deployments). SQLite file is co-located with the server binary; session_memories are cleared at server restart or explicit prune.

---

## 2. SQLite Schema

```sql
CREATE TABLE session_memories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id  TEXT    NOT NULL,
    key         TEXT    NOT NULL,
    content     TEXT    NOT NULL,
    tags        TEXT    NOT NULL DEFAULT '[]',  -- JSON array of strings
    created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    UNIQUE(session_id, key)
);

CREATE INDEX idx_session_memories_session ON session_memories(session_id);
CREATE INDEX idx_session_memories_tags    ON session_memories(tags);  -- partial, via LIKE

CREATE TABLE vault_memories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    key         TEXT    NOT NULL UNIQUE,
    content     TEXT    NOT NULL,
    tags        TEXT    NOT NULL DEFAULT '[]',  -- JSON array of strings
    embedding   BLOB,                           -- optional: float32 LE array (D=1536)
    created_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now')),
    updated_at  TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE INDEX idx_vault_memories_tags ON vault_memories(tags);

-- Full-text search (FTS5) — covers both tables via content= tables
CREATE VIRTUAL TABLE session_fts USING fts5(
    key, content, tags,
    content=session_memories, content_rowid=id
);

CREATE VIRTUAL TABLE vault_fts USING fts5(
    key, content, tags,
    content=vault_memories, content_rowid=id
);

-- Triggers to keep FTS in sync
CREATE TRIGGER session_ai AFTER INSERT ON session_memories BEGIN
    INSERT INTO session_fts(rowid, key, content, tags) VALUES (new.id, new.key, new.content, new.tags);
END;
CREATE TRIGGER session_ad AFTER DELETE ON session_memories BEGIN
    INSERT INTO session_fts(session_fts, rowid, key, content, tags) VALUES('delete', old.id, old.key, old.content, old.tags);
END;
CREATE TRIGGER session_au AFTER UPDATE ON session_memories BEGIN
    INSERT INTO session_fts(session_fts, rowid, key, content, tags) VALUES('delete', old.id, old.key, old.content, old.tags);
    INSERT INTO session_fts(rowid, key, content, tags) VALUES (new.id, new.key, new.content, new.tags);
END;
-- (Identical triggers for vault_memories / vault_fts omitted for brevity)
```

**Embedding column:** `BLOB` storing a little-endian `float32[D]` array. When present, `search_memories` can perform cosine-similarity ranking in addition to FTS. Embeddings are written by the agent via `commit_memory` (optional field); the server does not generate them. D=1536 matches `text-embedding-3-small`; set D at server init via config.

---

## 3. MCP Primitives

### 3.1 Resources

| URI | Scope | Content |
|---|---|---|
| `memory://session/{session_id}` | volatile | All memories for the given session, as a JSON array |
| `memory://vault` | persistent | All vault memories (paginated via `?offset=&limit=`), as a JSON array |
| `memory://vault/{key}` | persistent | Single vault memory by key, as a JSON object |

**Resource schema (single memory object):**
```json
{
  "key": "user_preference_language",
  "content": "User prefers Python examples over TypeScript.",
  "tags": ["preference", "coding"],
  "scope": "vault",
  "created_at": "2026-04-27T14:00:00Z",
  "updated_at": "2026-04-27T14:00:00Z"
}
```

Resources support `listChanged` notifications — the server emits `notifications/resources/list_changed` after any `commit_memory` or `prune_memory` call that modifies the resource set.

### 3.2 Tools

#### `commit_memory`

```json
{
  "name": "commit_memory",
  "description": "Store a memory entry in the session (volatile) or vault (persistent) scope. Upserts on key collision.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "scope":     { "type": "string", "enum": ["session", "vault"] },
      "key":       { "type": "string", "description": "Unique identifier for this memory within its scope." },
      "content":   { "type": "string", "description": "The memory content to store." },
      "tags":      { "type": "array", "items": { "type": "string" }, "description": "Categorization tags for retrieval." },
      "embedding": { "type": "array", "items": { "type": "number" }, "description": "Optional pre-computed embedding vector (float32[D])." }
    },
    "required": ["scope", "key", "content"]
  },
  "outputSchema": {
    "type": "object",
    "properties": {
      "committed": { "type": "boolean" },
      "key":       { "type": "string" },
      "scope":     { "type": "string" }
    },
    "required": ["committed", "key", "scope"]
  }
}
```

**Behavior:** `INSERT OR REPLACE` (upsert). For `vault` scope, updates `updated_at`. For `session` scope, requires `session_id` from server state (set at connection initialization via a custom `initialize` param or via a `set_session_id` tool call — see §4).

#### `search_memories`

```json
{
  "name": "search_memories",
  "description": "Search memories by text query, tags, or both. Returns ranked results. Semantic ranking used if embeddings are present and a query_embedding is provided.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query":           { "type": "string", "description": "Full-text search query (FTS5 syntax supported)." },
      "scope":           { "type": "string", "enum": ["session", "vault", "all"], "description": "Which scope(s) to search." },
      "tags":            { "type": "array", "items": { "type": "string" }, "description": "Filter: only return memories with ALL specified tags." },
      "query_embedding": { "type": "array", "items": { "type": "number" }, "description": "Optional: embedding of the query for semantic re-ranking." },
      "limit":           { "type": "integer", "description": "Max results to return.", "default": 10 }
    },
    "required": ["query"]
  },
  "outputSchema": {
    "type": "object",
    "properties": {
      "results": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "key":       { "type": "string" },
            "content":   { "type": "string" },
            "tags":      { "type": "array", "items": { "type": "string" } },
            "scope":     { "type": "string" },
            "relevance": { "type": "number", "description": "Score in [0,1]; 1.0 = exact match." }
          },
          "required": ["key", "content", "tags", "scope", "relevance"]
        }
      },
      "total_searched": { "type": "integer" }
    },
    "required": ["results", "total_searched"]
  }
}
```

**Ranking algorithm:**
1. FTS5 BM25 score (always computed).
2. If `query_embedding` provided AND vault memory has an `embedding`: cosine similarity computed in-process, blended with BM25: `relevance = 0.4 * bm25_norm + 0.6 * cosine_sim`.
3. Tag filter applied as a pre-filter (SQL WHERE clause on `json_each(tags)`).
4. Results sorted descending by `relevance`, limited by `limit`.

#### `prune_memory`

```json
{
  "name": "prune_memory",
  "description": "Delete memory entries. Can target a specific key, or bulk-delete by age or scope.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "scope":       { "type": "string", "enum": ["session", "vault", "all"] },
      "key":         { "type": "string", "description": "If provided, delete only this key (within scope)." },
      "older_than":  { "type": "string", "description": "ISO 8601 datetime. Delete entries created before this timestamp." },
      "tags":        { "type": "array", "items": { "type": "string" }, "description": "Delete entries matching ALL these tags." }
    },
    "required": ["scope"]
  },
  "outputSchema": {
    "type": "object",
    "properties": {
      "pruned_count": { "type": "integer" }
    },
    "required": ["pruned_count"]
  }
}
```

**Safety rule:** `prune_memory` with `scope: "vault"` and no `key`, `older_than`, or `tags` filter is rejected with `McpError::InvalidParams("Bulk vault prune requires at least one filter.")`. Session scope without filters is allowed (clears the entire session on disconnect).

---

## 4. Session Identity

The server needs a `session_id` to namespace volatile memories. Two options:

**Option A (Stdio):** The server reads a `MEMORY_MCP_SESSION_ID` environment variable at startup. Simple, appropriate for single-agent local use.

**Option B (HTTP + custom init param):** During the MCP `initialize` handshake, the client includes a `sessionId` in `clientInfo.extra`:
```json
{
  "clientInfo": { "name": "claude-agent", "version": "1.0", "extra": { "sessionId": "sess_abc123" } }
}
```
The server extracts and stores this for the connection's lifetime.

**Session cleanup:** On connection close (Stdio EOF / HTTP disconnect), the server deletes all `session_memories` rows for that `session_id`. Configurable via `MEMORY_MCP_SESSION_PERSIST=true` to skip cleanup (useful for debugging).

---

## 5. C# Implementation Blueprint

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<MemoryDb>(sp =>
    new MemoryDb(builder.Configuration["MEMORY_MCP_DB_PATH"] ?? "memory.db"));
builder.Services.AddScoped<ISessionContext, SessionContext>();  // reads session_id from HTTP context
builder.Services.AddMcpServer()
    .WithTool<CommitMemoryTool>()
    .WithTool<SearchMemoriesTool>()
    .WithTool<PruneMemoryTool>()
    .WithResource<SessionMemoryResource>()
    .WithResource<VaultMemoryResource>();

// CommitMemoryTool.cs
[McpTool("commit_memory", "Store a memory in session or vault scope.")]
public async Task<CommitMemoryResult> CommitMemory(
    CommitMemoryArgs args,
    [FromServices] MemoryDb db,
    [FromServices] ISessionContext session,
    CancellationToken ct = default)
{
    var sessionId = session.SessionId;
    await db.UpsertAsync(args.Scope, sessionId, args.Key, args.Content, args.Tags, args.Embedding, ct);
    return new CommitMemoryResult(Committed: true, Key: args.Key, Scope: args.Scope);
}

// Records
public record CommitMemoryArgs(
    string Scope, string Key, string Content,
    string[]? Tags = null, float[]? Embedding = null);
public record CommitMemoryResult(bool Committed, string Key, string Scope);
```

**Key dependencies:** `Microsoft.Data.Sqlite`, `ModelContextProtocol` (C# MCP SDK), `System.Numerics.Tensors` (for cosine similarity on `float[]`).

---

## 6. Python Implementation Blueprint

```python
# server.py
import asyncio, json, sqlite3
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, Resource, TextContent

db = sqlite3.connect("memory.db", check_same_thread=False)
app = Server("memory-mcp")

@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "commit_memory":
        scope = arguments["scope"]
        key   = arguments["key"]
        content = arguments["content"]
        tags  = json.dumps(arguments.get("tags", []))
        if scope == "session":
            db.execute(
                "INSERT OR REPLACE INTO session_memories(session_id,key,content,tags) VALUES(?,?,?,?)",
                (SESSION_ID, key, content, tags))
        else:
            db.execute(
                "INSERT INTO vault_memories(key,content,tags) VALUES(?,?,?) "
                "ON CONFLICT(key) DO UPDATE SET content=excluded.content, tags=excluded.tags, "
                "updated_at=strftime('%Y-%m-%dT%H:%M:%SZ','now')",
                (key, content, tags))
        db.commit()
        return [TextContent(type="text", text=json.dumps({"committed": True, "key": key, "scope": scope}))]

    elif name == "search_memories":
        query = arguments["query"]
        scope = arguments.get("scope", "all")
        limit = arguments.get("limit", 10)
        results = []
        if scope in ("session", "all"):
            rows = db.execute(
                "SELECT s.key, s.content, s.tags, bm25(session_fts) as score "
                "FROM session_fts JOIN session_memories s ON session_fts.rowid=s.id "
                "WHERE session_fts MATCH ? AND s.session_id=? ORDER BY score LIMIT ?",
                (query, SESSION_ID, limit)).fetchall()
            results += [{"key": r[0], "content": r[1], "tags": json.loads(r[2]),
                         "scope": "session", "relevance": min(1.0, -r[3]/10)} for r in rows]
        if scope in ("vault", "all"):
            rows = db.execute(
                "SELECT v.key, v.content, v.tags, bm25(vault_fts) as score "
                "FROM vault_fts JOIN vault_memories v ON vault_fts.rowid=v.id "
                "WHERE vault_fts MATCH ? ORDER BY score LIMIT ?",
                (query, limit)).fetchall()
            results += [{"key": r[0], "content": r[1], "tags": json.loads(r[2]),
                         "scope": "vault", "relevance": min(1.0, -r[3]/10)} for r in rows]
        results.sort(key=lambda r: r["relevance"], reverse=True)
        return [TextContent(type="text", text=json.dumps({"results": results[:limit], "total_searched": len(results)}))]

    elif name == "prune_memory":
        scope = arguments["scope"]
        key   = arguments.get("key")
        if key:
            if scope == "session":
                cur = db.execute("DELETE FROM session_memories WHERE session_id=? AND key=?", (SESSION_ID, key))
            else:
                cur = db.execute("DELETE FROM vault_memories WHERE key=?", (key,))
        else:
            if scope == "session":
                cur = db.execute("DELETE FROM session_memories WHERE session_id=?", (SESSION_ID,))
            else:
                raise ValueError("Bulk vault prune requires a key or older_than filter.")
        db.commit()
        return [TextContent(type="text", text=json.dumps({"pruned_count": cur.rowcount}))]

async def main():
    async with stdio_server() as (read, write):
        await app.run(read, write, app.create_initialization_options())

if __name__ == "__main__":
    SESSION_ID = os.environ.get("MEMORY_MCP_SESSION_ID", "default")
    asyncio.run(main())
```

**Key dependencies:** `mcp` (Python MCP SDK), `sqlite3` (stdlib).

---

## 7. Capability Integration

This server's MCP manifest defines two capability levels:

| Agent scope | Permitted tools | Notes |
|---|---|---|
| **Read-only** | `search_memories` | Safe for any agent; no state mutation |
| **Read-write** | `commit_memory`, `search_memories`, `prune_memory` | Requires explicit grant |

Per [[pattern-capability-gating]], the orchestrating agent's `Scope` must include `CommitMemory` to delegate a task that calls `commit_memory`. The server's capability set:
```
Caps(MemoryMCP) = { SearchMemory, CommitMemory, PruneMemory }
```

A read-only orchestrator's effective delegation:
```
Effective = { SearchMemory, CommitMemory, PruneMemory } ∩ { SearchMemory } = { SearchMemory }
```

---

## References
- [[agent-knowledge-vault]]
- [[lit-mcp-architecture]]
- [[capability-lattice-spec]]
- [[pattern-capability-gating]]
- [[pattern-state-transfer]]
- [[csharp-mcp-sdk]]
- [[rust-mcp-patterns]]
- [[semantic-embedding-pipeline]]
- [[adk-long-term-memory]]
- [[rust-tier-0-patterns]]
