---
title: MCP Authorization
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-oauth, mcp-permissions, user-consent]
---
# MCP Authorization

Authorization in MCP secures access to sensitive resources and operations. It primarily follows the **OAuth 2.1** standard for remote connections and provides flexible options for local integrations.

## Core Flow (Remote HTTP/SSE)
1.  **Handshake**: Client connects; Server responds with `401 Unauthorized` and a `WWW-Authenticate` header pointing to **Protected Resource Metadata (PRM)**.
2.  **Discovery**: Client fetches PRM (RFC 9728) to identify the authorization server and supported scopes (e.g., `mcp:tools`).
3.  **Registration**: Client registers with the Auth Server, either via **Dynamic Client Registration (DCR)** or pre-registration.
4.  **Authorization**: User logs in via a browser and grants permission.
5.  **Access**: Client receives a Bearer token and includes it in the `Authorization` header of subsequent MCP requests.

## Local Authorization (Stdio)
For servers running locally, OAuth is often overkill. Instead:
*   **Environment Variables**: Pass API keys or credentials via the client's `env` configuration.
*   **Local Secret Managers**: The server can interact directly with the OS keychain or local credential stores.

## Implementation Principles
*   **Audience Enforcement**: Tokens must include an `aud` claim matching the MCP server's URI to prevent token passthrough attacks.
*   **Least-Privilege Scopes**: Scopes should be granular (e.g., `mcp:tools:read-only`) rather than broad.
*   **Token Validation**: Servers should use token introspection (RFC 7662) or local JWT validation libraries to verify signatures and expiration.

## Best Practices
*   **Encrypted Storage**: Cache tokens in secure, encrypted local storage.
*   **No Credential Logging**: Ensure that tokens and secrets are redacted from server and client logs.
*   **HTTPS Only**: Enforce TLS for all remote transport and callback URLs.

---
## References
* Source: `00_Raw/mcp/Understanding Authorization in MCP.md`
* [[mcp-security]]
* [[mcp-remote-connections]]
