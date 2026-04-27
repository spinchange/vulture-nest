---
title: [[agent-development-kit|ADK]] Long-Term Memory
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - adk-memory
  - MemoryService
  - long-term-knowledge
  - InMemoryMemoryService
  - VertexAiMemoryBankService
type: permanent
---

# ADK Long-Term Memory

While [[adk-session-service|Session State]] manages short-term conversational context, the **Memory Service** in [[agent-development-kit|ADK]] provides agents with long-term recall across multiple sessions. It acts as a searchable archive of past interactions and external knowledge.

## 1. Core Concepts
*   **Long-Term Knowledge:** Information that persists even after a session is closed.
*   **Semantic Search:** The ability to retrieve past context based on meaning (using embeddings) rather than just keyword matching.
*   **Memory Integration:** Like other services, a `MemoryService` is provided to the `Runner` at initialization.

## 2. Service Implementations

### `InMemoryMemoryService`
Stores memory in the application's RAM.
*   **Search Method:** Basic keyword matching.
*   **Use Case:** Prototyping and simple local testing.
*   **Persistence:** Data is lost on restart.

### `VertexAiMemoryBankService`
A production-grade service using Google Cloud's Vertex AI.
*   **Search Method:** Semantic (vector) search using embeddings.
*   **Use Case:** Applications requiring robust, persistent, and "intelligent" recall across thousands of sessions.

### `DatabaseMemoryService`
A community-supported persistent memory service for [[python]] (backed by SQLAlchemy/Postgres).

## 3. The Memory Lifecycle

### Saving to Memory
When a session concludes, it can be "committed" to long-term memory.
```python
# Python Example
await memory_service.add_session_to_memory(completed_session)
```

### Retrieving from Memory
Agents (or tools) can search memory during an active turn.
*   **Input:** A query string.
*   **Output:** A list of `MemoryResult` objects, containing relevant event snippets or session data.

## 4. State vs. Memory

| Feature | Session State | Memory Service |
| :--- | :--- | :--- |
| **Duration** | Single Session | Cross-Session |
| **Scope** | Current conversation | Archive of all past conversations |
| **Access** | Direct Key/Value (`context.state`) | Searchable (`memory_service.search`) |
| **Storage** | Volatile (Session Service) | Persistent (Memory Service) |

---
*Source: [[lit-adk-documentation]]*

