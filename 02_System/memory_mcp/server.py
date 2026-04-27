import asyncio
import json
import os
import signal
import sqlite3
import struct
from pathlib import Path

try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
    from mcp.types import TextContent
except ImportError:  # pragma: no cover - keeps module testable without SDK
    Server = None
    stdio_server = None
    TextContent = None


SESSION_ID = os.environ.get("MEMORY_MCP_SESSION_ID", "default")
SESSION_PERSIST = os.environ.get("MEMORY_MCP_SESSION_PERSIST", "").lower() == "true"
DEFAULT_DB_PATH = Path(os.environ.get("MEMORY_MCP_DB_PATH", Path(__file__).with_name("memory.db")))
SCHEMA_PATH = Path(__file__).with_name("schema.sql")


def encode_embedding(embedding: list[float] | None) -> bytes | None:
    if embedding is None:
        return None
    return struct.pack(f"<{len(embedding)}f", *embedding)


def _normalize_bm25(score: float) -> float:
    return min(1.0, max(0.0, 1.0 / (1.0 + max(0.0, score))))


def init_db(db_path: Path | str = DEFAULT_DB_PATH) -> sqlite3.Connection:
    path = Path(db_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(path, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    conn.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))
    conn.commit()
    return conn


def _tag_predicate(tags: list[str], tags_expr: str) -> tuple[str, list[str]]:
    clauses = [f"EXISTS (SELECT 1 FROM json_each({tags_expr}) WHERE value = ?)" for _ in tags]
    return " AND ".join(clauses), tags


def commit_memory(
    db: sqlite3.Connection,
    *,
    scope: str,
    key: str,
    content: str,
    tags: list[str] | None = None,
    embedding: list[float] | None = None,
    session_id: str = SESSION_ID,
) -> dict:
    tag_json = json.dumps(tags or [])
    if scope == "session":
        db.execute(
            "INSERT OR REPLACE INTO session_memories(session_id,key,content,tags) VALUES(?,?,?,?)",
            (session_id, key, content, tag_json),
        )
    elif scope == "vault":
        db.execute(
            "INSERT INTO vault_memories(key,content,tags,embedding) VALUES(?,?,?,?) "
            "ON CONFLICT(key) DO UPDATE SET content=excluded.content, tags=excluded.tags, "
            "embedding=excluded.embedding, updated_at=strftime('%Y-%m-%dT%H:%M:%SZ','now')",
            (key, content, tag_json, encode_embedding(embedding)),
        )
    else:
        raise ValueError(f"Unsupported scope: {scope}")
    db.commit()
    return {"committed": True, "key": key, "scope": scope}


def _search_scope(
    db: sqlite3.Connection,
    *,
    table: str,
    fts_table: str,
    scope: str,
    query: str,
    limit: int,
    session_id: str,
    tags: list[str] | None,
) -> list[dict]:
    alias = "m"
    conditions = [f"{fts_table} MATCH ?"]
    params: list[object] = [query]
    if table == "session_memories":
        conditions.append(f"{alias}.session_id = ?")
        params.append(session_id)
    if tags:
        tag_clause, tag_params = _tag_predicate(tags, f"{alias}.tags")
        conditions.append(tag_clause)
        params.extend(tag_params)

    sql = (
        f"SELECT {alias}.key, {alias}.content, {alias}.tags, bm25({fts_table}) AS score "
        f"FROM {fts_table} JOIN {table} {alias} ON {fts_table}.rowid = {alias}.id "
        f"WHERE {' AND '.join(conditions)} ORDER BY score LIMIT ?"
    )
    params.append(limit)
    rows = db.execute(sql, params).fetchall()
    return [
        {
            "key": row["key"],
            "content": row["content"],
            "tags": json.loads(row["tags"]),
            "scope": scope,
            "relevance": _normalize_bm25(row["score"]),
        }
        for row in rows
    ]


def search_memories(
    db: sqlite3.Connection,
    *,
    query: str,
    scope: str = "all",
    tags: list[str] | None = None,
    limit: int = 10,
    session_id: str = SESSION_ID,
    query_embedding: list[float] | None = None,
) -> dict:
    del query_embedding  # Embedding rerank is reserved for a future pass.
    results: list[dict] = []
    if scope in ("session", "all"):
        results.extend(
            _search_scope(
                db,
                table="session_memories",
                fts_table="session_fts",
                scope="session",
                query=query,
                limit=limit,
                session_id=session_id,
                tags=tags,
            )
        )
    if scope in ("vault", "all"):
        results.extend(
            _search_scope(
                db,
                table="vault_memories",
                fts_table="vault_fts",
                scope="vault",
                query=query,
                limit=limit,
                session_id=session_id,
                tags=tags,
            )
        )
    results.sort(key=lambda item: item["relevance"], reverse=True)
    return {"results": results[:limit], "total_searched": len(results)}


def prune_memory(
    db: sqlite3.Connection,
    *,
    scope: str,
    key: str | None = None,
    older_than: str | None = None,
    tags: list[str] | None = None,
    session_id: str = SESSION_ID,
) -> dict:
    if scope == "vault" and not any([key, older_than, tags]):
        raise ValueError("Bulk vault prune requires at least one filter.")

    total = 0
    targets = []
    if scope in ("session", "all"):
        targets.append(("session_memories", True))
    if scope in ("vault", "all"):
        targets.append(("vault_memories", False))

    for table, is_session in targets:
        clauses = []
        params: list[object] = []
        if is_session:
            clauses.append("session_id = ?")
            params.append(session_id)
        if key:
            clauses.append("key = ?")
            params.append(key)
        if older_than:
            clauses.append("created_at < ?")
            params.append(older_than)
        if tags:
            tag_clause, tag_params = _tag_predicate(tags, "tags")
            clauses.append(tag_clause)
            params.extend(tag_params)
        sql = f"DELETE FROM {table}"
        if clauses:
            sql += " WHERE " + " AND ".join(clauses)
        cur = db.execute(sql, params)
        total += cur.rowcount

    db.commit()
    return {"pruned_count": total}


def cleanup_session(db: sqlite3.Connection, session_id: str = SESSION_ID) -> None:
    if SESSION_PERSIST:
        return
    db.execute("DELETE FROM session_memories WHERE session_id = ?", (session_id,))
    db.commit()


def build_server(db: sqlite3.Connection):
    if Server is None or TextContent is None:
        raise RuntimeError("The Python MCP SDK is not installed.")

    app = Server("memory-mcp")

    @app.call_tool()
    async def call_tool(name: str, arguments: dict) -> list[TextContent]:
        if name == "commit_memory":
            payload = commit_memory(db, session_id=SESSION_ID, **arguments)
        elif name == "search_memories":
            payload = search_memories(db, session_id=SESSION_ID, **arguments)
        elif name == "prune_memory":
            payload = prune_memory(db, session_id=SESSION_ID, **arguments)
        else:
            raise ValueError(f"Unknown tool: {name}")
        return [TextContent(type="text", text=json.dumps(payload))]

    return app


async def main() -> None:
    if stdio_server is None:
        raise RuntimeError("The Python MCP SDK is not installed.")

    db = init_db(DEFAULT_DB_PATH)
    app = build_server(db)

    def _shutdown(*_args):
        cleanup_session(db)

    for sig in (signal.SIGTERM, signal.SIGINT):
        signal.signal(sig, _shutdown)

    try:
        async with stdio_server() as (read, write):
            await app.run(read, write, app.create_initialization_options())
    finally:
        cleanup_session(db)
        db.close()


if __name__ == "__main__":
    asyncio.run(main())
