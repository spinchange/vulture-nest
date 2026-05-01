---
title: "Literature: MCP Server Development"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/mcp/Build and MCP Server.md", "00_Raw/mcp/Understanding MCP Servers.md"]
aliases: ["MCP Server Guide", "FastMCP Tutorial", "Server Capabilities"]
---

# Literature: MCP Server Development

This literature note covers the technical implementation and conceptual framework for building **Model Context Protocol (MCP)** servers.

## Core Capabilities
MCP servers provide functionality through three primary building blocks:

| Feature | Control | Description |
| :--- | :--- | :--- |
| **Tools** | Model | Executable functions with JSON schemas. Interrogated by LLMs to perform actions (API calls, DB writes). |
| **Resources** | Application | Passive, read-only data (file contents, DB schemas, API docs) exposed via unique URIs (`file:///`, `travel://`). |
| **Prompts** | User | Standardized templates for tasks (e.g., "Plan a vacation"), facilitating structured workflows. |

## Implementation Patterns

### 1. FastMCP (Python)
- **High-level Abstraction**: Uses type hints and docstrings to auto-generate tool definitions.
- **Entry Point**: `FastMCP("server-name")`.
- **Registration**: Decorated functions via `@mcp.tool()`.

### 2. TypeScript SDK
- **Type Safety**: Utilizes `zod` for robust input schema validation.
- **Registration**: `server.registerTool(name, schema, handler)`.

## Critical Logging Rules (STDIO)
When using the **Stdio transport**, servers must follow strict logging hygiene to avoid corrupting the JSON-RPC message stream:
- **❌ DO NOT use `print()` or `console.log()`**: These write to `stdout`, which is reserved for protocol messages.
- **✅ USE `sys.stderr` or `console.error()`**: Errors and logs must be directed to `stderr` to remain visible without breaking the connection.

## Development Workflow
1.  **Prerequisites**: Python 3.10+ (uv) or Node.js 16+.
2.  **Initialization**: Handshake exchange defines protocol version and capabilities.
3.  **Discovery**: Host discovers server features via `tools/list` and `resources/list`.
4.  **Notifications**: Servers can emit `list_changed` events to trigger host-side refreshes.

---
## See Also
- [[mcp-server-development]] (Permanent Note)
- [[mcp-moc]]
- [[lit-mcp-architecture]]
- [[mcp-best-practices]]
