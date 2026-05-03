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

## Core Opinion

The important SDK question is usually not "which language is supported?" but "which runtime should own this MCP boundary?" SDK choice follows the same tier logic as the rest of the vault:

- choose a high-level SDK for speed of integration and tool ergonomics
- choose a systems-level SDK when the MCP surface is performance-sensitive, operationally critical, or part of a hardened trust boundary

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

## What Actually Varies

Even when two SDKs support the same protocol surface, they differ materially in:

- **Ergonomics:** decorator-heavy vs. builder-style APIs
- **Schema expression:** how naturally the language maps to MCP tool/resource definitions
- **Operational fit:** local scripting, web service deployment, background daemon, IDE integration
- **Host vs. server emphasis:** some ecosystems are stronger on client/host integration, others on server construction
- **Type discipline:** whether the runtime encourages fast prototyping or stricter interface design

## Strategic Choice

- **[[python]]**: best for fast prototyping, ingestion pipelines, and agent-side glue. FastMCP-style ergonomics make tool definition cheap.
- **[[typescript]]**: strong for editor integrations, web-adjacent hosts, and applications already living in Node/browser-adjacent ecosystems.
- **[[csharp-mcp-sdk]] / C#**: strong for enterprise integration, long-lived services, and typed application environments.
- **[[rust-mcp-patterns]] / Rust**: strongest when MCP is part of a hardened infrastructure or performance-sensitive service boundary.
- **Go**: good fit for compact operational services and simple deployment stories when low overhead matters more than rich framework ergonomics.

## Start Here

1. If you are building quickly inside the vault, start with [[python]] and [[mcp-server-development]].
2. If you are wiring MCP into an IDE, desktop shell, or web-facing host, inspect [[typescript]] and the TypeScript SDK first.
3. If the MCP surface is part of a durable backend or trust boundary, compare [[csharp-mcp-sdk]] and [[rust-mcp-patterns]].
4. If the real question is protocol semantics rather than language choice, go back to [[mcp-primitives]] and [[mcp-architecture]].

## Relationship to Other MCP Notes

- [[mcp-server-development]] and [[mcp-client-development]] explain how SDK choice changes implementation shape.
- [[mcp-best-practices]] explains how larger tool surfaces should be staged regardless of SDK.
- [[mcp-security]] matters more as SDKs become part of remote or production-facing deployments.

---
## See Also
- [[mcp-moc]]
- [[mcp-server-development]]
- [[mcp-client-development]]
- [[mcp-primitives]]
- [[mcp-security]]
- [[rust-mcp-patterns]]
- [[csharp-mcp-sdk]]
