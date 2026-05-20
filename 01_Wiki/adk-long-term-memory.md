---
title: [[agent-development-kit|ADK]] Long-Term Memory
author: claude-sonnet-4-6
date: '2026-05-19'
status: active
aliases:
  - adk-memory
  - MemoryService
  - long-term-knowledge
  - InMemoryMemoryService
  - VertexAiMemoryBankService
  - DatabaseMemoryService
type: permanent
---

# ADK Long-Term Memory

While [[adk-session-service|Session State]] manages short-term conversational context, the **Memory Service** in [[agent-development-kit|ADK]] provides agents with long-term recall across multiple sessions. It acts as a searchable archive of past interactions and external knowledge.

---

## 1. Core Concepts

- **Long-Term Knowledge:** Information that persists after a session is closed.
- **Semantic Search:** Retrieval based on meaning (embeddings) rather than keyword matching.
- **Integration Point:** A `MemoryService` is provided to the `Runner` at initialization, like other ADK services.

---

## 2. Service Implementations

### `InMemoryMemoryService`

Stores memory in application RAM.

- **Search Method:** Basic keyword matching
- **Use Case:** Prototyping and simple local testing
- **Persistence:** Data is lost on restart

### `VertexAiMemoryBankService`

Production-grade service backed by Google Cloud's Vertex AI Agent Engine.

- **Search Method:** Semantic (vector) search using embeddings
- **Use Case:** Applications requiring robust, persistent, and semantically intelligent recall across thousands of sessions
- **Config:** Requires `agent_engine_id` (Reasoning Engine ID); project/location not required in express mode

```python
from google.adk.memory import VertexAiMemoryBankService

APP_ID = "your-reasoning-engine-id"
memory_service = VertexAiMemoryBankService(agent_engine_id=APP_ID)
```

### `DatabaseMemoryService`

Community-supported persistent memory backed by SQLAlchemy (Postgres, MySQL, SQLite).

- **Search Method:** Keyword matching (JSON index on `(app_name, user_id)`)
- **Storage Schema:** Creates a single `adk_memory_entries` table on first write
  - JSON content stored as `JSONB` on PostgreSQL, `LONGTEXT` on MySQL, `TEXT` on SQLite
- **Use Case:** Self-hosted production environments where Vertex AI is not in scope

```python
from google.adk.memory import DatabaseMemoryService

memory = DatabaseMemoryService(db_url="postgresql://user:pass@host/db")
```

---

## 3. The Memory Lifecycle

### Saving to Memory

When a session concludes, commit it to long-term memory. The service indexes every event in the completed session.

```python
# Index all events from a completed session
await memory_service.add_session_to_memory(completed_session)

# Index an explicit slice of events (streaming ingestion)
await memory_service.add_events_to_memory(
    app_name="my_app",
    user_id="user_123",
    events=event_slice,
)
```

### Retrieving from Memory

Agents or tools search memory during an active turn.

```python
results = await memory_service.search_memory(
    app_name="my_app",
    user_id="user_123",
    query="what did we decide about the pricing model?",
)
# Returns list of MemoryEntry objects with relevant event snippets
```

### Full API Surface

| Method | Description |
|---|---|
| `add_session_to_memory(session)` | Index every event in a completed session |
| `add_events_to_memory(app_name, user_id, events, ...)` | Index an explicit event slice (streaming ingestion) |
| `search_memory(app_name, user_id, query)` | Return `MemoryEntry` objects scoped to app + user |

---

## 4. State vs. Memory

| Feature | [[adk-session-service\|Session State]] | Memory Service |
|---|---|---|
| **Duration** | Single session (or scoped by prefix) | Cross-session archive |
| **Scope** | Current conversation | All past conversations for a user |
| **Access** | Direct key-value (`context.state`) | Searchable (`search_memory`) |
| **Storage** | Session Service | Memory Service (persistent) |
| **Use Case** | Working memory, pipeline data handoff | User recall, long-horizon personalization |

---

## 5. Choosing a Service

```
Local development / testing    → InMemoryMemoryService
Self-hosted / open-source      → DatabaseMemoryService (SQLAlchemy)
Production + Google Cloud      → VertexAiMemoryBankService
```

`VertexAiMemoryBankService` is the only option with semantic (embedding) search; the others use keyword matching. For most production workloads requiring cross-session recall, the Vertex AI service is the correct choice.

---

*Source: [[lit-adk-documentation]]*

## Related

- [[adk-session-service]]
- [[adk-artifact-service]]
- [[agent-development-kit]]
