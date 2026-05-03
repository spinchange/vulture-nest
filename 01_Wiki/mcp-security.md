---
title: [[mcp-moc|MCP]] Security and Authorization
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-security]
---
# MCP Security and Authorization

Security in the **Model Context Protocol (MCP)** is built on a "Host-mediated" trust model, where the **Host** (the application the user interacts with) is responsible for enforcing security boundaries and managing user consent.

## Core Opinion

MCP security is mostly about **where trust is allowed to accumulate**. The protocol does not magically make tool use safe; it gives hosts, clients, and servers a structured place to enforce boundaries. The host remains the primary policy owner.

The key split is:

- **Local / stdio MCP:** security is dominated by process boundaries, local execution risk, and host-mediated approval.
- **Remote / HTTP MCP:** security is dominated by OAuth, audience binding, scope control, SSRF defense, and session integrity.

## Security Model

MCP does not assume one universal authorization mechanism. Instead:

1. **Host Control:** The host decides which servers to connect to, which capabilities to expose, and how user approval is surfaced.
2. **User Consent:** Sensitive tool use and data access should be explicitly approved at the host layer.
3. **Capability Negotiation:** During `initialize`, clients and servers advertise capabilities, but capability advertisement is not equivalent to authorization.
4. **Transport-Specific Enforcement:** Remote servers rely on stronger network and token controls; local servers rely more on process isolation and sandboxing.

## Main Threat Categories

The practical MCP threat model in this vault breaks into five recurring classes:

- **Confused deputy:** a proxy or intermediary obtains consent or tokens in ways the user did not actually intend.
- **Token misuse:** audience failures or token passthrough let one service reuse another service's trust.
- **SSRF and metadata abuse:** discovery URLs become a path into internal networks or cloud metadata endpoints.
- **Session hijacking / event injection:** stateful transports expose replay or impersonation surfaces.
- **Local server compromise:** one-click or lightly reviewed local server execution becomes arbitrary code execution.

## Authorization Boundary

For remote MCP, authorization is not an optional implementation detail once sensitive capabilities are exposed.

- [[mcp-authorization]] is the permanent concept note for the OAuth 2.1 flow and audience-bound tokens.
- [[lit-mcp-authorization]] is the specification-level source for discovery, step-up scope challenges, and token handling requirements.
- Local stdio servers typically do **not** use this OAuth flow; they inherit a different trust model and should instead emphasize local credential hygiene and execution isolation.

## Operational Security Guidance

- **Treat all model-provided input as untrusted.** Tool parameters, resource requests, and prompt arguments all need validation.
- **Prefer least privilege.** Do not request or grant broad scopes up front if narrower scopes or delayed elevation are possible.
- **Use sandboxing and root restriction.** Especially for local servers that touch files, shells, or generated code.
- **Separate discovery from trust.** A server being discoverable does not make it trustworthy.
- **Bind sessions to identity.** Session identifiers are coordination aids, not authentication mechanisms.

## Transport Security

### Stdio / Local

- Lower network exposure, but higher risk of local arbitrary code execution
- Best when paired with explicit install/launch review, root restrictions, and sandboxing
- Appropriate for trusted local tooling where the host can closely mediate execution

### HTTP / Remote

- Requires normal web security controls plus MCP-specific authorization handling
- Should use TLS, strong metadata validation, audience-bound tokens, and scope challenges
- Needs explicit defenses against SSRF, token passthrough, and session hijacking

## Relationship to the Rest of the Vault

- [[mcp-best-practices]] covers operational patterns like progressive discovery; security determines how safely those patterns can be deployed.
- [[mcp-remote-connections]] and [[mcp-local-connections]] explain the transport split that drives most security decisions.
- [[docker-sandbox]] and [[rust-tier-0-patterns]] are useful adjacent notes when the question becomes "how do we enforce the boundary in practice?"

---
## References
* Source: `00_Raw/mcp/Secuirty Best Practices.md`, `00_Raw/mcp/Understanding Authorization in MCP.md`
* [[mcp-architecture]]
* [[mcp-primitives]]
- [[mcp-local-connections]]
- [[mcp-remote-connections]]
- [[mcp-authorization]]
- [[mcp-best-practices]]
- [[docker-sandbox]]
- [[lit-mcp-architecture]]
* [[lit-mcp-security-and-auth]]
* [[lit-mcp-security-best-practices]]
* [[lit-mcp-authorization]]
