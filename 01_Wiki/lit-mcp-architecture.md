---
title: 'Literature: MCP Architecture Overview'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: literature
aliases:
  - mcp-architecture-source
  - mcp-arch-docs
---

# Literature: MCP Architecture Overview

## Source Metadata
*   **File:** `00_Raw/mcp/Architecture overview.md`
*   **Origin:** Anthropic Model Context Protocol documentation (`modelcontextprotocol.io`)
*   **Domain:** protocols / AI tooling
*   **Relevance:** MCP is the primary tool-access protocol in the vault — all MCP server patterns, C# SDK work, and Rust server designs derive from this foundation.

## High-Level Summary
MCP (Model Context Protocol) defines a **client-server architecture** for providing structured context to AI applications. Its scope is narrow by design: it governs how an agent accesses **tools, resources, and prompts** from servers. It does *not* govern agent-to-agent communication (that is A2A's domain). The protocol is JSON-RPC 2.0 over two transport layers (Stdio and Streamable HTTP).

## Two-Layer Architecture

### Data Layer (JSON-RPC 2.0)
The semantic heart of MCP. Defines message structure, lifecycle, and primitives.

#### Server-Exposed Primitives
| Primitive | Purpose | Discovery | Execution |
|---|---|---|---|
| **Tools** | Executable functions AI can invoke | `tools/list` | `tools/call` |
| **Resources** | Contextual data sources (files, DB records) | `resources/list` | `resources/read` |
| **Prompts** | Reusable interaction templates | `prompts/list` | `prompts/get` |

#### Client-Exposed Primitives
| Primitive | Purpose |
|---|---|
| **Sampling** | Server requests LLM completion from the host; server stays model-independent |
| **Elicitation** | Server requests additional information from the user |
| **Logging** | Server sends diagnostic log messages to the client |

#### Experimental Primitives
*   **Tasks:** Durable execution wrappers for deferred/long-running MCP requests — a bridge toward A2A-style stateful task tracking within the MCP protocol.

### Transport Layer
| Transport | Mechanism | Use Case |
|---|---|---|
| **Stdio** | stdin/stdout streams | Local process-to-process, single client |
| **Streamable HTTP** | HTTP POST + optional SSE | Remote servers, many clients, OAuth auth |

## Lifecycle Protocol
1.  **Initialize:** Client sends `protocolVersion` + capability declarations. Server responds with its capability set.
2.  **Initialized Notification:** Client signals readiness.
3.  **Operation:** Standard JSON-RPC request/response/notification exchange.
4.  **Termination:** Connection closed; server cleans up session state.

Capability negotiation at initialization is the mechanism by which a client learns whether a server supports `listChanged` notifications, streaming, elicitation, etc. This is analogous to A2A's Agent Card capability flags.

## Notification System
Servers that declare `"listChanged": true` in their capability block can push `notifications/tools/list_changed` (or equivalent for resources/prompts) without a request. Clients re-fetch the list on receipt. This keeps the client's tool registry synchronized with dynamic server state.

## Participant Model
```
MCP Host (AI Application)
  ├── MCP Client 1 ──── dedicated connection ──── MCP Server A (Local, Stdio)
  ├── MCP Client 2 ──── dedicated connection ──── MCP Server B (Local, Stdio)
  └── MCP Client 3 ──── dedicated connection ──── MCP Server C (Remote, HTTP)
```
One client per server. The host manages all clients. Each client maintains its own capability negotiation and connection state independently.

## Architectural Themes
1.  **Narrow Scope:** MCP = agent ↔ tool. It explicitly does not define how AI uses the context it receives.
2.  **Stateful Sessions:** MCP is stateful (though Streamable HTTP allows a stateless subset). Contrast with A2A which is request-scoped.
3.  **Dynamic Discovery:** Primitives are listed at runtime, not compiled in. Allows servers to expose capabilities conditionally.
4.  **Sampling Inversion:** The `sampling` primitive flips the call direction — server calls into the LLM, enabling server-side reasoning without bundling an LLM SDK.

## Connections to Vault
*   [[mcp-moc]] — full MCP Map of Content
*   [[a2a-mcp-contrast]] — where MCP ends and A2A begins
*   [[csharp-mcp-sdk]] — .NET implementation
*   [[rust-mcp-patterns]] — high-performance server patterns
*   [[dotnet-mcp-server-patterns]] — server-side implementation guide
*   [[agentic-protocols]] — MCP in the broader protocol stack

## Next Steps for Synthesis
*   Map the `Tasks` (experimental) primitive to A2A's task lifecycle — are they converging?
*   Detail the Streamable HTTP authentication flow (OAuth bearer) and map to A2A's out-of-band credential model.
*   Write a note on the `Sampling` primitive as an architectural pattern for model-independent server reasoning.

## Related
- [[mcp-server-features]]
