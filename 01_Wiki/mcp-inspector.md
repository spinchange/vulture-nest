---
title: MCP Inspector
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-testing-tool, mcp-interactive-debug]
---
# MCP Inspector

The **MCP Inspector** is an interactive developer tool used to test and debug MCP servers in isolation before integrating them into a full host application.

## Quick Start
Run via `npx` (requires Node.js):
```bash
npx @modelcontextprotocol/inspector <command> <args>
```

### Examples
*   **Inspecting a Python Server**:
    `npx @modelcontextprotocol/inspector uv run server.py`
*   **Inspecting an npm Package**:
    `npx -y @modelcontextprotocol/inspector npx @modelcontextprotocol/server-filesystem /path/to/test`

## Core Features
1.  **Resources Tab**: Browse all exposed resources and inspect their content/metadata.
2.  **Prompts Tab**: Test parameterized templates with custom arguments.
3.  **Tools Tab**: Manually trigger tool calls and view JSON execution results.
4.  **Notifications Pane**: Real-time stream of server logs and protocol events.

## Development Workflow
1.  **Launch**: Start the Inspector with your server command.
2.  **Verify**: Check that all tools/resources are listed with correct schemas.
3.  **Iterate**: Modify server code, rebuild, and use the "Reconnect" button in the Inspector UI.
4.  **Edge Cases**: Input invalid arguments to ensure your server handles errors gracefully according to the protocol.

---
## References
* Source: `00_Raw/mcp/MCP Inspector.md`
* [[mcp-debugging]]
* [[mcp-server-development]]
