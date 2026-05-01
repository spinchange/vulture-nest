---
title: [[mcp-moc|MCP]] Debugging
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-troubleshooting, mcp-logs, server-initialization-errors]
---
# MCP Debugging

Effective debugging of MCP integrations requires monitoring the communication between the Host (Client) and the Server across different layers.

## Key Debugging Tools
1.  **[[mcp-inspector]]**: An interactive, transport-agnostic web UI for testing tools, resources, and prompts.
2.  **Server Logs**: 
    *   **Stdio**: Logs to `stderr` are automatically captured by the host.
    *   **HTTP**: Requires server-side aggregation or checking browser Network panels.
3.  **Client Developer Tools**: Most hosts (like Claude Desktop) provide logs and connection status.

## Implementing Logging
*   **❌ NEVER** log to `stdout` in stdio servers (it breaks the JSON-RPC stream).
*   **✅ ALWAYS** log to `stderr`.
*   **Protocol Logging**: Use `notifications/message` to send structured logs to the client.
    *   [[python]]: `ctx.session.send_log_message(level="info", data="...")`
    *   [[typescript|TypeScript]]: `server.sendLoggingMessage({ level: "info", data: "..." })`

## Common Issues
### 1. Working Directory & Paths
Servers launched via config files often have an undefined working directory.
*   **Rule**: Always use **absolute paths** for executable commands, file arguments, and `.env` locations.

### 2. Environment Variables
Stdio servers do not inherit all system environment variables.
*   **Fix**: Explicitly define required variables (like API keys) in the `env` section of the client configuration.

### 3. Capability Mismatches
Errors like `-32602` (Invalid params) often occur when a server tries to use a feature (like `sampling`) that the client hasn't enabled.
*   **Fix**: Inspect the initial `initialize` handshake to verify negotiated capabilities.

## Host-Specific: Claude Desktop
*   **Logs**: 
    *   Windows: `%APPDATA%\Claude\logs\mcp.log`
    *   macOS: `~/Library/Logs/Claude/mcp.log`
*   **DevTools**: Enable via `developer_settings.json` (`{"allowDevTools": true}`) and press `Ctrl+Alt+I`.

---
## References
* Source: `00_Raw/mcp/Debugging.md`
* [[mcp-inspector]]
* [[mcp-transport]]
- [[mcp-server-development]]
- [[mcp-best-practices]]
- [[mcp-client-development]]

