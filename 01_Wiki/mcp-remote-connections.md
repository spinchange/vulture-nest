---
title: MCP Remote Connections
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-sse, remote-mcp-server, custom-connectors]
---
# MCP Remote Connections

Remote MCP connections use the **HTTP/SSE transport**, allowing AI applications to connect to internet-hosted tools and data sources that reside outside the local environment.

## Architecture
*   **Host**: The AI application (e.g., Claude.ai) acts as the client.
*   **Server**: A web-hosted service that implements the MCP protocol over HTTP.
*   **Bridge**: Custom Connectors act as the secure link between the host and the remote server.

## Connection Process
1.  **URL Registration**: Provide the host application with the HTTPS URL of the remote MCP server.
2.  **Authentication**: Remote servers typically require secure authentication, such as:
    *   **OAuth**: Redirecting the user to a third-party provider.
    *   **API Keys**: Provided during the setup phase.
3.  **Capability Handshake**: Once authenticated, the host and server negotiate features via the protocol.

## Use Cases
*   **SaaS Integration**: Connecting to project management tools (Linear), repositories (GitHub), or communication platforms (Slack) that are not local to the machine.
*   **Shared Infrastructure**: Centralized servers that provide context or tools to an entire team or organization.

## Security Considerations
*   **Encryption**: All remote traffic must be encrypted via TLS/SSL.
*   **Authorization**: Hosts can granularly enable or disable specific tools from the remote server.
*   **Trust**: Only connect to remote servers from trusted sources, as they receive context from your conversations.

---
## References
* Source: `00_Raw/mcp/Connect to remote MCP Servers.md`
* [[mcp-transport]]
* [[mcp-authorization]]
- [[mcp-local-connections]]
- [[mcp-architecture]]
- [[mcp-security]]
