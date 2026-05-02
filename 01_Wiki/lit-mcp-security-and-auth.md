---
title: "Literature: MCP Security & Authorization"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/mcp/Secuirty Best Practices.md", "00_Raw/mcp/Understanding Authorization in MCP.md"]
aliases: ["MCP Security Guide", "MCP OAuth Flow", "Confused Deputy Mitigation"]
---

# Literature: MCP Security & Authorization

This literature note covers the security model and authorization frameworks for the **Model Context Protocol (MCP)**, with a focus on mitigating common attack vectors and implementing OAuth 2.1 correctly.

## Core Security Principles
- **Explicit Consent**: Users must authorize every sensitive action (tool execution, data access).
- **Least Privilege**: Servers and clients should operate with the minimum scopes required for their tasks.
- **Transport Security**: HTTPS is mandatory for all remote connections; Stdio provides process-level isolation for local servers.

## Threat Model & Mitigations

### 1. Confused Deputy Problem
Occurs when an MCP proxy server uses a static client ID for multiple downstream clients, allowing an attacker to reuse a valid consent cookie to bypass user approval.
- **Mitigation**: MCP proxies **MUST** implement per-client consent registries and validate `redirect_uri` against exact strings.

### 2. Server-Side Request Forgery (SSRF)
Malicious servers can provide URLs in metadata (e.g., `resource_metadata`) that point to internal IPs (169.254.169.254) or localhost services.
- **Mitigation**: Clients **MUST** block private/reserved IP ranges and require HTTPS for all OAuth discovery URLs.

### 3. Token Passthrough
The anti-pattern where a server accepts a token from a client and forwards it to a downstream API without validation.
- **Mitigation**: Servers **MUST NOT** accept tokens not explicitly issued for their specific audience (`aud` claim).

### 4. Session Hijacking
Attackers guessing or stealing `Mcp-Session-Id` to impersonate clients.
- **Mitigation**: Use non-deterministic IDs (UUIDs) and bind them to user-specific tokens (e.g., `<user_id>:<session_id>`).

## Authorization Flow (OAuth 2.1)
MCP follows the OAuth 2.1 standard for protecting remote resources:
1.  **Handshake**: Server returns `401 Unauthorized` with a `resource_metadata` pointer.
2.  **Discovery**: Client fetches **Protected Resource Metadata (PRM)** to find authorization server URLs.
3.  **Registration**: Client uses **Dynamic Client Registration (DCR)** or pre-registration.
4.  **Authorization**: User consents via browser; client receives an auth code.
5.  **Token Exchange**: Client exchanges code for an Access Token (JWT) with restricted scopes and audience.
6.  **Authenticated Request**: Client calls server with `Authorization: Bearer <token>`.

## Local Server Security (Stdio)
For servers running over Stdio, OAuth is typically replaced by:
- **Environment-based credentials**: Passed via the host's configuration.
- **Process Isolation**: The connection is private to the host application and the server process.

---
## See Also
- [[mcp-authorization]] (Permanent Note)
- [[lit-mcp-authorization]] - Specification-level coverage: discovery flow, audience binding, step-up, security risks
- [[lit-mcp-security-best-practices]] - Deep-dive threat model: confused deputy, token passthrough, SSRF, session hijacking, local compromise
- [[mcp-best-practices]]
- [[lit-mcp-architecture]]
- [[mcp-moc]]
