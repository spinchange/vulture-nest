---
title: [[agent-development-kit|ADK]] Session Service
author: claude-sonnet-4-6
date: '2026-05-19'
status: active
aliases:
  - session-service
  - adk-sessions
  - adk-state
  - InMemorySessionService
  - VertexAiSessionService
type: permanent
---

# ADK Session Service

The **Session Service** in the [[agent-development-kit|ADK]] is responsible for managing the lifecycle of an agent's interaction, including its conversation history and short-term working memory.

## Core Responsibilities

- **Conversation History:** Tracks `Events` (user messages, agent replies, tool calls) in chronological order.
- **State Management:** Manages the `State` object — a key-value store used as the agent's short-term working memory within and across sessions (via prefix scoping).
- **Persistence:** Provides the interface for saving and loading session data.

---

## Key Concepts

### Session

A `Session` object contains:

- `appName`, `userId`, `sessionId`: Unique identifiers
- `events`: Chronological list of interactions
- `state`: Current working memory (key-value)

> `getSession()` returns a **copy** of the session; direct modification of the returned object does not persist. State changes must go through `state_delta` in an `EventAction` or through a `ToolContext` / `CallbackContext`.

### State

`State` is a key-value store scoped by namespace prefix. Agents read state via `context.state`; tools update it through the `ToolContext`.

#### State Prefix Scoping

| Prefix | Scope | Example Use |
|---|---|---|
| `app:` | Shared across **all users** of the application | Feature flags, app-wide config |
| `user:` | Shared across **all sessions** for a given user | User preferences, long-lived personalization |
| *(no prefix)* | Current session only | Per-conversation working memory |
| `temp:` | Current invocation only — not persisted | Passing data between sub-agents in a single turn |

```python
# Reading and writing scoped state in a tool
def my_tool(tool_context: ToolContext):
    # App-wide preference
    app_mode = tool_context.state.get("app:mode", "default")
    # User preference (persists across sessions)
    unit = tool_context.state.get("user:temperature_unit", "Celsius")
    # Session scratch
    tool_context.state["last_city_checked"] = "London"
    # Ephemeral in-turn pass-through (not saved)
    tool_context.state["temp:raw_result"] = raw_data
```

> `temp:` and `secret:` prefixed keys are automatically redacted in structured logging (e.g., BigQuery plugin) — never persisted in audit trails.

#### Initializing State at Session Creation

```python
initial_state = {"user_preference_temperature_unit": "Celsius"}
session = await session_service.create_session(
    app_name=APP_NAME,
    user_id=USER_ID,
    session_id=SESSION_ID,
    state=initial_state,
)
```

---

## Key Access Patterns

### ToolContext (Primary)

Tools accept a `ToolContext` object (automatically provided by ADK if declared as the last argument). This gives direct access to `tool_context.state`.

```python
async def get_weather_stateful(city: str, tool_context: ToolContext) -> dict:
    unit = tool_context.state.get("user:temperature_unit", "Celsius")
    tool_context.state["last_city_checked"] = city
    return fetch_weather(city, unit)
```

### `output_key` (Auto-Save Agent Response)

An `LlmAgent` configured with `output_key="some_key"` will automatically save its final textual response to `session.state["some_key"]` after each turn. This is the idiomatic way to pipe agent output downstream in a `SequentialAgent` pipeline.

```python
root_agent = LlmAgent(
    ...,
    output_key="last_weather_report",  # auto-saved to state
)
```

### Shared `InvocationContext` & `temp:` Namespace

When a parent agent invokes a sub-agent, both share the same `InvocationContext`. The `temp:` state namespace is ideal for passing data that is only relevant for the current turn — it propagates through the sub-agent tree without being committed to durable session storage.

---

## Service Implementations

### `InMemorySessionService`

Stores session data in local memory.

- **Best For:** Development, testing, transient sessions
- **Note:** Data is lost when the process stops
- **Direct access for testing:** `session_service.sessions[APP][USER][SESSION_ID]` (implementation detail, not stable API)

```python
session_service = InMemorySessionService()
session = await session_service.create_session(
    app_name="my_app", user_id="user_123", session_id="session_abc"
)
```

### `VertexAiSessionService`

Integrates with Google Cloud's Vertex AI Agent Engine for persistent session management.

- **Best For:** Production applications requiring durability and scalability
- **Note:** Requires Vertex AI credentials; tied to a Reasoning Engine / Agent Engine instance

```go
// Go Example
sessionService := session.InMemoryService()
runnerConfig := &launcher.Config{
    SessionService: sessionService,
}
```

---

## State vs. Memory

| Feature | Session State | [[adk-long-term-memory|Memory Service]] |
|---|---|---|
| **Duration** | Single session (or scoped by prefix) | Cross-session |
| **Access** | Direct key-value (`context.state`) | Searchable (`memory_service.search_memory`) |
| **Storage** | Session Service | Memory Service |
| **Use Case** | Working memory, pipeline data handoff | Recall across conversation history |

---

*Source: [[lit-adk-documentation]]*

## Related

- [[adk-artifact-service]]
- [[adk-long-term-memory]]
- [[agent-development-kit]]
