---
title: [[mcp-moc|MCP]] Architecture
author: claude-sonnet-4-6
date: 2026-04-25
status: active
type: permanent
aliases: [mcp-model, mcp-layers, mcp-lifecycle, mcp-standard-model]
---
# MCP Architecture

The **Model Context Protocol (MCP)** follows a layered, client-server architecture designed to bridge AI applications (Hosts) with external data and tools.

## The Layered Model
MCP separates the "what" (data) from the "how" (delivery) through two distinct layers.

### 1. Data Layer (Inner)
The data layer implements a **JSON-RPC 2.0** based exchange protocol that defines message semantics and lifecycle management.
*   **Lifecycle Management**: Handles connection initialization, capability negotiation, and termination.
*   **Feature Primitives**: Defines the structure for [[mcp-server-features|Tools, Resources, and Prompts]].
*   **Notifications**: Supports real-time, one-way updates (e.g., `notifications/tools/list_changed`) to keep the Host synchronized with Server state.

### 2. Transport Layer (Outer)
The transport layer manages communication channels and message framing. The Data Layer is transport-agnostic, allowing the same JSON-RPC format to work across different media.
*   **Stdio Transport**: Best for local process communication. Messages are sent via `stdin`/`stdout` and must be carefully framed to avoid corruption from standard logging.
*   **Streamable HTTP Transport**: Uses HTTP POST for client-to-server messages and **Server-Sent Events (SSE)** for server-to-client streaming. This enables remote servers and standard web authentication (OAuth).

## The Initialization Handshake
MCP is a **stateful protocol** that begins with a mandatory capability negotiation sequence:
1.  **Initialize Request**: The Client sends its `protocolVersion` and supported `capabilities` (e.g., roots, sampling).
2.  **Initialize Response**: The Server responds with its own version, `serverInfo`, and supported `capabilities` (e.g., tools, resources).
3.  **Initialized Notification**: The Client sends a `notifications/initialized` message to confirm it is ready to process requests.

## Participants
- **MCP Host**: The main AI application (e.g., Claude Desktop, VS Code) that coordinates multiple Clients.
- **MCP Client**: A component within the Host that maintains a 1:1, dedicated connection to a single Server.
- **MCP Server**: A standalone program providing context or tools. Each Server operates in its own isolated scope.

---
## Related
* [[mcp-transport]]
* [[mcp-server-features]]
* [[mcp-server-development]]
* [[mcp-client-development]]
- [[agentic-protocols]]


- [[lit-mcp-architecture]]
