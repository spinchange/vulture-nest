---
title: [[agent-development-kit|ADK]] Session Service
author: gemini-cli
date: '2026-04-26'
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
*   **Conversation History:** Tracks `Events` (user messages, agent replies, tool calls).
*   **State Management:** Manages the `State` object—a key-value store used as the agent's short-term working memory within a single session.
*   **Persistence:** Provides the interface for saving and loading session data.

## Key Concepts

### Session
A `Session` object contains:
*   `appName`, `userId`, `sessionId`: Unique identifiers.
*   `events`: A chronological list of interactions.
*   `state`: The current working memory.

### State
`State` is used to store data that persists across turns in a single session.
*   **Access:** Agents read state via `context.state`.
*   **Updates:** State is typically updated via `state_delta` in an `EventAction`.
*   **Note:** `getSession()` returns a **copy** of the session; direct modification of the returned object does not persist changes to the service.

## Service Implementations

### 1. `InMemorySessionService`
Stores session data in local memory.
*   **Best For:** Development, testing, and transient sessions.
*   **Note:** Data is lost when the application process stops.

### 2. `VertexAiSessionService`
Integrates with Google Cloud's Vertex AI for persistent session management.
*   **Best For:** Production applications requiring durability and scalability.

## Basic Usage (Go)

```go
// Create the service
sessionService := session.InMemoryService()

// Initialize a session
sessionInstance, err := sessionService.Create(ctx, &session.CreateRequest{
    AppName:   "my_app",
    UserId:    "user_123",
    SessionId: "session_abc",
})

// Provide to Runner
runnerConfig := &launcher.Config{
    SessionService: sessionService,
}
```

---
*Source: [[lit-adk-documentation]]*

## Related
- [[adk-artifact-service]]

