---
title: [[mcp-moc|MCP]] Authorization
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-oauth, mcp-permissions, user-consent]
---
# MCP Authorization

Authorization in MCP secures access to sensitive resources and operations. It primarily follows the **OAuth 2.1** standard for remote connections.

## Core Flow
1.  **Handshake**: Client connects; Server responds with `401 Unauthorized`.
2.  **Discovery**: Client fetches PRM to identify the authorization server.
3.  **Authorization**: User grants permission.
4.  **Access**: Client receives a Bearer token.

## Best Practices
*   **Encrypted Storage**: Cache tokens in secure, encrypted local storage.
*   **No Credential Logging**: Ensure that tokens and secrets are redacted from logs.

## See Also
* [[index]]
* [[mcp-security]]
* [[mcp-remote-connections]]
* [[mcp-moc]]
