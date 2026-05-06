---
title: [[mcp-moc|MCP]] Transport
author: claude-sonnet-4-6
date: 2026-05-06
status: active
type: permanent
aliases: [mcp-stdio, mcp-sse, mcp-http, mcp-tasks, mcp-v2-transport]
---
# MCP Transport

The **Transport Layer** in MCP manages how messages are framed and delivered between participants. By abstracting the transport, the same **[[mcp-architecture|Data Layer]]** (JSON-RPC) can be used across different connection types.

## MCP v2 Transport Landscape

The **2025-03-26** spec revision (MCP v2) canonicalized **Streamable HTTP** as the production transport for all remote connections and deprecated the earlier dedicated SSE endpoint pattern. Any new remote MCP server should implement Streamable HTTP; Stdio remains the correct choice for local in-process servers.

| Transport | Deployment | MCP v2 Status |
|---|---|---|
| Stdio | Same machine, child process | Production — unchanged |
| Streamable HTTP | Any network boundary | Production — canonical remote transport |
| Legacy HTTP+SSE | Separate POST + SSE endpoints | Deprecated in MCP v2 |

## Supported Mechanisms

### 1. Stdio Transport (Local)
Uses Standard Input/Output streams for communication between processes on the same machine.
*   **Mechanism**: The Host spawns the Server as a child process.
*   **Framing**: Messages are delimited by newlines. Each line must be a valid JSON-RPC 2.0 object.
*   **Constraint**: Servers must **never** log to `stdout` — it corrupts the protocol stream. All logging goes to `stderr`.
*   **Auth**: Not required — process isolation is the trust boundary. Use environment variables or embedded credentials.

### 2. Streamable HTTP Transport (Remote)
Single-endpoint transport that unifies request/response and server push over HTTP.
*   **Client-to-Server**: Messages sent via **HTTP POST** to a single MCP endpoint (e.g., `/mcp`).
*   **Server-to-Client**: Server can respond with either a standard JSON body (for short operations) or an **SSE stream** (`Content-Type: text/event-stream`) for incremental results and push notifications.
*   **Security**: OAuth 2.1 with Bearer tokens is the mandated auth scheme. See [[mcp-authorization]].
*   **Key improvement over legacy SSE**: The server can choose response mode per-request — immediate JSON or streaming SSE — without the client needing a separate subscription endpoint.

## MCP v2 Tasks Primitive

MCP v2 introduced a **Tasks** resource type, enabling servers to model long-running operations explicitly rather than forcing callers to poll external state. A tool call may return a `task` reference instead of an immediate result:

```json
{
  "type": "task",
  "id": "task_abc123",
  "status": "submitted",
  "statusUrl": "https://server.example.com/tasks/task_abc123"
}
```

Task lifecycle states mirror the A2A pattern (see [[a2a-protocol]]):

```
submitted → working → completed
                    ↘ failed
                    ↘ canceled
```

The client polls `statusUrl` or subscribes via SSE for `TaskStatusUpdateEvent` frames. This closes the gap between MCP's stateless tool model and real-world long-running operations (batch jobs, file exports, model inference queues) without requiring a separate A2A peer relationship.

## Message Framing
In Stdio: line-delimited JSON. In Streamable HTTP: standard HTTP body for JSON responses, `data:` prefix with double-newline terminator for SSE frames. The framing layer is transport-specific; the JSON-RPC payload above it is identical.

---
## See Also
* [[mcp-architecture]]
* [[mcp-authorization]]
* [[mcp-server-development]]
* [[a2a-protocol]]
* [[agentic-protocols]]
* [[lit-mcp-architecture]]