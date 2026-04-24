---
title: MCP Transport
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-stdio, mcp-sse, mcp-http]
---
# MCP Transport

The **Transport Layer** in MCP manages how messages are framed and delivered between participants. By abstracting the transport, the same **[[mcp-architecture|Data Layer]]** (JSON-RPC) can be used across different connection types.

## Supported Mechanisms

### 1. Stdio Transport (Local)
Uses Standard Input/Output streams for communication between processes on the same machine.
*   **Use Case:** Local filesystem access, local database scripts, browser-based hosts talking to local binaries.
*   **Pros:** Minimal latency, no network overhead, simple security (process-level).

### 2. Streamable HTTP Transport (Remote)
Uses HTTP POST for client-to-server messages and **Server-Sent Events (SSE)** for server-to-client streaming.
*   **Use Case:** Cloud-based services (e.g., Sentry, GitHub API), cross-machine collaboration.
*   **Pros:** Enables remote capabilities, supports standard web authentication (OAuth, Bearer tokens).

## Framing
The transport layer ensures that JSON-RPC messages are correctly framed (delimited) so the receiving end can parse individual requests from a continuous stream.

---
## See Also
* [[mcp-architecture]]
* [[agentic-protocols]]
