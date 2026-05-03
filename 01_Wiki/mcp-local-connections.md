---
title: [[mcp-moc|MCP]] Local Connections
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [local-mcp-server, claude-desktop-config]
---
# MCP Local Connections

Local MCP connections use the **Stdio transport**, where the host application (e.g., Claude Desktop) starts the MCP server as a local subprocess and communicates via standard input/output streams.

## Configuration (Claude Desktop)
Local servers are configured in the `claude_desktop_config.json` file.
*   **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
*   **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

### Example Configuration
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:\\Users\\username\\Desktop"
      ]
    }
  }
}
```

## How it Works
1.  **Lifecycle**: The Host starts the server process on launch and terminates it on exit.
2.  **Communication**: JSON-RPC messages are sent over `stdin` (to server) and `stdout` (to client).
3.  **Permissions**: The server runs with the same user permissions as the Host application. It can access any local file or resource that the user can.

## Security Best Practices
*   **Scoped Access**: Only grant the server access to specific directories (roots).
*   **User Approval**: The Host application should intercept tool calls (e.g., `write_file`) and require explicit user consent before execution.

---
## References
* Source: `00_Raw/mcp/Connect to local MCP servers.md`
* [[mcp-transport]]
* [[mcp-security]]
- [[mcp-remote-connections]]

