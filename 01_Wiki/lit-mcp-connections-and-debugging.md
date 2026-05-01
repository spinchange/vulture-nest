---
title: "Literature: MCP Connections & Debugging"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/mcp/Connect to local MCP servers.md", "00_Raw/mcp/Connect to remote MCP Servers.md", "00_Raw/mcp/Debugging.md", "00_Raw/mcp/MCP Inspector.md"]
aliases: ["MCP Debugging Guide", "Claude Desktop Configuration", "MCP Inspector Tutorial"]
---

# Literature: MCP Connections & Debugging

This literature note covers the practical workflows for connecting, configuring, and troubleshooting **Model Context Protocol (MCP)** servers and clients.

## Connection Patterns

### 1. Local (Stdio)
Local servers are launched by the host application (e.g., Claude Desktop) as child processes.
- **Configuration**: Managed via `claude_desktop_config.json`.
- **Requirements**: Absolute paths are mandatory for commands and arguments to ensure reliability across different launch contexts.
- **Windows AppData**: On Windows, the `%APPDATA%` environment variable may need to be explicitly passed in the `env` key if servers fail to locate global npm modules.

### 2. Remote (HTTP/SSE)
Remote servers are hosted on the internet and connected via **Custom Connectors**.
- **Handshake**: Requires a secure URL (`https://`) and often involves authentication (OAuth, API Keys).
- **Permissions**: Remote connectors allow granular control over which tools the model is permitted to use.

## Debugging Toolkit

### MCP Inspector
An interactive testing UI for transport-agnostic server validation.
- **Launch**: `npx @modelcontextprotocol/inspector <command> <args>`.
- **Features**: Direct invocation of Tools, Prompts, and Resources; real-time notification stream monitoring.

### Log Locations
Host-level logs are critical for identifying connection failures:
- **macOS**: `~/Library/Logs/Claude/mcp*.log`
- **Windows**: `%APPDATA%\Claude\logs\mcp*.log`
- **Note**: `mcp.log` contains connection events; `mcp-server-SERVERNAME.log` contains `stderr` output from specific servers.

## Common Issues & Mitigations
- **Working Directory**: Defaults to root (`/`) or undefined. **Solution**: Use absolute paths in all configs.
- **Environment Variables**: Stdio servers inherit limited variables. **Solution**: Explicitly define required keys (e.g., `API_KEYS`) in the `env` configuration block.
- **Standard Output Pollution**: `print()` or `console.log()` in a Stdio server will corrupt the JSON-RPC stream. **Solution**: Redirect all logging to `stderr`.
- **Capability Mismatch**: Error `-32602` (Invalid params) often indicates a server trying to use a feature (like `sampling`) that the client has not negotiated.

---
## See Also
- [[mcp-debugging]] (Permanent Note)
- [[mcp-moc]]
- [[lit-mcp-architecture]]
- [[lit-mcp-server-development]]
