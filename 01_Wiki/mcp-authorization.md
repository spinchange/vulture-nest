---
title: [[mcp-moc|MCP]] Authorization
author: gemini-cli
date: 2026-05-02
status: active
type: permanent
aliases: [mcp-oauth, mcp-permissions, user-consent]
---
# MCP Authorization

Authorization in MCP secures access to sensitive resources and operations, particularly for remote HTTP-based servers. It strictly follows the **OAuth 2.1** standard.

## The OAuth 2.1 Flow
1.  **Handshake**: Client receives a `401 Unauthorized` response with a `resource_metadata` pointer to a **Protected Resource Metadata (PRM)** document.
2.  **Metadata Discovery**: Client fetches the PRM (from `.well-known/oauth-protected-resource`) to identify the authorization server and supported scopes.
3.  **Client Registration**: Client registers with the authorization server, often using **Dynamic Client Registration (DCR)**.
4.  **User Consent**: User logs in via a browser and grants permissions.
5.  **Token Exchange**: Client exchanges the authorization code for an `access_token` and `refresh_token`.
6.  **Authenticated Access**: Client includes the `Bearer` token in the `Authorization` header of MCP requests.

## Critical Security Mitigations
### Confused Deputy Prevention
In proxy scenarios, a malicious client could trick a user into granting consent for an attacker-controlled redirect URI. 
-   **Mitigation**: MCP proxy servers **must** implement a per-client consent page *before* forwarding to the third-party authorization server.

### Token Passthrough
Servers must not accept tokens that weren't explicitly issued for them.
-   **Mitigation**: Validate the `aud` (audience) claim in the token to ensure it matches the MCP server's resource URL.

### SSRF Protection
Malicious servers can use discovery URLs to probe internal networks.
-   **Mitigation**: Clients must enforce HTTPS, block private IP ranges (10.0.0.0/8, etc.), and validate redirect targets.

## Implementation Guidelines
-   **Local Servers**: Servers using the **STDIO transport** do not require OAuth; they should use environment-based credentials or embedded libraries.
-   **Scope Minimization**: Avoid "catch-all" scopes. Use precise, capability-based scopes to reduce the blast radius of a compromised token.
-   **State Validation**: Always use and validate the OAuth `state` parameter to prevent CSRF and code interception.

---
## See Also
* [[mcp-security]]
* [[mcp-best-practices]]
* [[mcp-remote-connections]]
* [[mcp-moc]]
* [[agentic-protocols]]
