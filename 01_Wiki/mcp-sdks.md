---
title: "MCP SDKs"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "permanent"
source: "00_Raw/mcp/SDKs.md"
aliases: ["MCP SDK Tiers", "Model Context Protocol SDKs"]
---

# MCP SDKs

The **Model Context Protocol (MCP)** provides official SDKs across multiple languages to facilitate the development of servers and clients. SDKs are categorized into tiers based on their feature completeness and support status.

## SDK Tiers

### Tier 1 (Canonical & Feature-Complete)
- **TypeScript**: `modelcontextprotocol/typescript-sdk`
- **Python**: `modelcontextprotocol/python-sdk`
- **C#**: `modelcontextprotocol/csharp-sdk`
- **Go**: `modelcontextprotocol/go-sdk`

### Tier 2 (Stable & Actively Maintained)
- **Java**: `modelcontextprotocol/java-sdk` (utilizes Spring AI auto-configuration)
- **Rust**: `modelcontextprotocol/rust-sdk`

### Tier 3 (Community / Incubating)
- **Swift**, **Ruby**, **PHP**, **Kotlin**

## Feature Parity
All Tier 1 and Tier 2 SDKs support the core protocol primitives:
- Creating servers with **Tools**, **Resources**, and **Prompts**.
- Implementing both **Stdio** (local) and **HTTP/SSE** (remote) transports.
- Handling the **Initialization Handshake** and capability negotiation.
- Type-safe schema definition and validation.

## Strategic Choice
- **Fast Prototyping**: Python (FastMCP) is recommended for its high-level decorators and automatic schema generation.
- **Enterprise Scale**: C# or TypeScript are preferred for their robust typing and integration with established IDE/Web ecosystems.
- **Systems Engineering**: Rust or Go provide high performance and low-latency execution for infrastructure-level bridges.

---
## See Also
- [[mcp-moc]]
- [[mcp-server-development]]
- [[mcp-client-development]]
