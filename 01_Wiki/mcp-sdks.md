---
title: MCP SDKs
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-libraries, python-mcp-sdk, typescript-mcp-sdk]
---
# MCP SDKs

The Model Context Protocol (MCP) provides official SDKs to streamline the development of servers and clients. These SDKs are categorized into tiers based on their feature completeness and maintenance level.

## SDK Tiering System
*   **Tier 1 (Core)**: Full feature parity, protocol compliance, and primary maintenance commitment.
*   **Tier 2 (Advanced)**: High feature support, active maintenance.
*   **Tier 3 (Emerging)**: Essential protocol support, community or specialized maintenance.

## Available SDKs

| Language | Tier | Repository |
| :--- | :--- | :--- |
| **TypeScript** | 1 | [modelcontextprotocol/typescript-sdk](https://github.com/modelcontextprotocol/typescript-sdk) |
| **Python** | 1 | [modelcontextprotocol/python-sdk](https://github.com/modelcontextprotocol/python-sdk) |
| **C#** | 1 | [modelcontextprotocol/csharp-sdk](https://github.com/modelcontextprotocol/csharp-sdk) |
| **Go** | 1 | [modelcontextprotocol/go-sdk](https://github.com/modelcontextprotocol/go-sdk) |
| **Java** | 2 | [modelcontextprotocol/java-sdk](https://github.com/modelcontextprotocol/java-sdk) |
| **Rust** | 2 | [modelcontextprotocol/rust-sdk](https://github.com/modelcontextprotocol/rust-sdk) |
| **Swift** | 3 | [modelcontextprotocol/swift-sdk](https://github.com/modelcontextprotocol/swift-sdk) |
| **Ruby** | 3 | [modelcontextprotocol/ruby-sdk](https://github.com/modelcontextprotocol/ruby-sdk) |
| **PHP** | 3 | [modelcontextprotocol/php-sdk](https://github.com/modelcontextprotocol/php-sdk) |

## Standard Capabilities
Regardless of the language, all official MCP SDKs support:
*   **Server Creation**: Exposing [[mcp-primitives|Tools, Resources, and Prompts]].
*   **Client Integration**: Connecting to any valid MCP server.
*   **Transport Protocols**: Support for both Stdio and HTTP/SSE.
*   **Type Safety**: Native language-specific typing for protocol messages.

---
## References
* Source: `00_Raw/mcp/SDKs.md`
* [[mcp-server-development]]
* [[mcp-client-development]]
- [[mcp-example-servers]]
- [[mcp-example-clients]]
- [[csharp-mcp-sdk]]
