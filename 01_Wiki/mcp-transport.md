---
title: [[mcp-moc|MCP]] Transport
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
*   **Mechanism**: The Host spawns the Server as a child process.
*   **Framing**: Messages are typically delimited by newlines. Each line must be a valid JSON-RPC 2.0 object.
*   **Constraint**: Servers must **never** log to `stdout` (standard output) as it corrupts the protocol stream. All logging must be redirected to `stderr`.

### 2. Streamable HTTP Transport (Remote)
Enables communication over a network, allowing the Host and Server to reside on different machines.
*   **Client-to-Server**: Messages are sent via standard **HTTP POST** requests.
*   **Server-to-Client**: Messages are streamed using **Server-Sent Events (SSE)**. This allows the server to push notifications or results without a preceding request.
*   **Security**: Supports standard web authentication (OAuth 2.1, Bearer tokens, API keys).

## Message Framing
The transport layer ensures that the continuous stream of bytes is correctly parsed into individual JSON-RPC messages. In Stdio, this is line-based; in SSE, it follows the `data:` prefix and double-newline terminator specified by the SSE standard.

---
## See Also
* [[mcp-architecture]]
* [[mcp-server-development]]
- [[agentic-protocols]]

- [[lit-mcp-architecture]]