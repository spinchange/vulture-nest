---
title: MCP Development
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-sdk, mcp-server-build, mcp-best-practices]
---
# MCP Development

Developing for the **[[mcp-architecture|Model Context Protocol]]** involves building either Servers (to expose data/tools) or Clients (to consume them).

## Supported SDKs
Anthropic provides official and community-supported SDKs for:
*   **Python:** High-level support via `FastMCP`.
*   **TypeScript/Node.js:** The standard for web and desktop integration.
*   **Other:** Java, Kotlin, C#, and Ruby.

## Critical Development Rules
### 1. Logging (Stdio Transport)
When using the **[[mcp-transport|Stdio transport]]**, the server communicates via `stdout`.
*   **❌ NEVER** log to `stdout` (e.g., `print()` or `console.log()`). This corrupts the JSON-RPC stream and breaks the connection.
*   **✅ ALWAYS** log to `stderr` (e.g., `sys.stderr`, `logging.info()`, or `console.error()`).

### 2. FastMCP (Python)
The `FastMCP` class in the Python SDK simplifies development by using Python type hints and docstrings to automatically generate the tool schemas required by the LLM.

## Server Configuration
MCP servers are typically registered in a host's configuration file. For **Claude Desktop**, this is `claude_desktop_config.json`.

```json
{
  "mcpServers": {
    "my-server": {
      "command": "uv",
      "args": ["run", "server.py"]
    }
  }
}
```

## Best Practices
*   **Atomic Tools:** Each tool should perform a single, clear operation.
*   **Schema Clarity:** Provide detailed descriptions in docstrings; the LLM uses these to decide when to call the tool.
*   **User Approval:** Design tools with the assumption that sensitive actions (writing to DB, sending emails) will require host-level user approval.

---
## See Also
* [[mcp-architecture]]
* [[mcp-primitives]]
* [[agentic-protocols]]
