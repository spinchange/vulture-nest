---
title: "Literature: MCP Security Best Practices"
author: "claude-sonnet-4-6"
date: "2026-05-01"
status: "active"
type: "literature"
aliases:
  - "MCP Security Best Practices"
  - "MCP Threat Model"
  - "MCP Attack Vectors"
source: "https://modelcontextprotocol.io/docs/tutorials/security/security_best_practices"
source_note: "Spec URL https://modelcontextprotocol.io/specification/2025-11-25/basic/security_best_practices redirected to the docs/tutorials path at crawl time. All chunk_ids reference the resolved URL."
source_page_id: "eede9071-46f4-4463-a392-acea3b7000c0"
chunk_ids:
  - "2a5a73f7-5483-466a-a7f1-bd83efa758a6"
  - "49d4cae6-cb2d-46d1-9a95-faf3a18b959b"
  - "c7bd1a10-95cd-48f6-ae41-7a721f0e2310"
  - "8dfd84d9-a24b-47ba-bf21-0b954f303aa6"
  - "d6f28c8d-ffec-4bc2-b846-7aa94f01f4ff"
  - "4b8d2f91-2025-4c88-9916-de7c65163aa0"
  - "c6afbfd3-cc9e-4e03-98f8-5119ab5eec95"
  - "508b45ed-d535-4018-9822-a39e3b23488a"
  - "d5884eb8-9f29-4237-817d-35b88a01d6bb"
  - "00ef3e2c-ea96-44fe-a97d-0a309afc7a4b"
  - "cee699d5-922d-4371-b558-ba75bfa4696b"
  - "52ba0232-bf91-4ee6-9d47-6a4ea58d46a8"
crawl_job: "019de5f7-b8d3-7580-8bed-dc7d3db35b18"
---

# Literature: MCP Security Best Practices

Canonical source: MCP docs/tutorials — Security Best Practices (resolved from spec 2025-11-25).
This document is a companion to the MCP Authorization Specification. Where [[lit-mcp-authorization]]
covers the protocol mechanics, this document identifies attack vectors and prescribes concrete
mitigations for MCP implementors across five threat categories.

---

## Purpose and Scope

> "This document provides security considerations for the Model Context Protocol (MCP),
> complementing the MCP Authorization specification. This document identifies security risks,
> attack vectors, and best practices specific to MCP implementations."

Primary audience: developers implementing MCP authorization flows, MCP server operators, and
security professionals evaluating MCP-based systems. The document is intended to be read
alongside the MCP Authorization specification and RFC 9700 (OAuth 2.0 Security Best Practices).

The five threat categories covered:

1. Confused Deputy Problem
2. Token Passthrough
3. Server-Side Request Forgery (SSRF)
4. Session Hijacking and Event Injection
5. Local MCP Server Compromise

A sixth design principle — Scope Minimization — closes the document.

---

## 1. Confused Deputy Problem

### What It Is

An MCP proxy server that connects to a third-party API acts as a single OAuth client
to that API using a **static client ID**. When it simultaneously allows MCP clients to
**dynamically register** (each receiving their own `client_id`), a window opens for an
attacker to steal authorization without user consent.

The attack requires all four of these conditions:
- The proxy uses a static `client_id` with the third-party authorization server
- The proxy supports MCP client dynamic registration
- The third-party AS sets a **consent cookie** after the first legitimate authorization
- The proxy does **not** enforce per-client consent before forwarding to the third-party AS

### Attack Flow (8 Steps)

1. Legitimate user authenticates through the proxy → third-party AS sets a consent cookie
2. Attacker dynamically registers a malicious client with a crafted `redirect_uri: attacker.com`
3. Attacker sends victim a malicious authorization link
4. Victim's browser presents the consent cookie; third-party AS skips the consent screen
5. Authorization code is redirected to `attacker.com`
6. Attacker exchanges stolen code for access token
7. Attacker now has API access as the compromised user — with no explicit approval

### Required Mitigations

**Per-Client Consent Storage** — MCP proxy servers **MUST**:
- Maintain a registry of approved `client_id` values per user
- Check this registry **before** initiating the third-party authorization flow
- Store consent decisions server-side (DB or server-bound cookie)

**Consent UI** — The MCP-level consent page **MUST**:
- Identify the requesting client by name
- Show third-party API scopes and `redirect_uri`
- Implement CSRF protection (state parameter, CSRF tokens)
- Block clickjacking via `frame-ancestors` CSP / `X-Frame-Options: DENY`

**Consent Cookie Security** — If consent is tracked via cookies, they **MUST**:
- Use the `__Host-` prefix
- Set `Secure`, `HttpOnly`, and `SameSite=Lax`
- Be cryptographically signed or backed by server-side sessions
- Bind to the specific `client_id`, not just "user has consented"

**Redirect URI Validation** — The proxy **MUST** use exact string matching; reject any
request whose `redirect_uri` differs from the registered value.

**OAuth State Parameter** — The proxy **MUST**:
- Generate a cryptographically secure random `state` for each authorization request
- Store the `state` server-side **only after** the user approves the MCP-level consent screen
- Validate exact `state` match at the callback; reject missing or mismatched values
- Treat `state` values as single-use with a short TTL (e.g., 10 minutes)

> **Critical invariant:** The consent cookie or session storing the `state` value **MUST NOT**
> be set until after the user has approved the MCP server's consent screen. Setting it before
> renders the consent screen ineffective.

---

## 2. Token Passthrough

### What It Is

Token passthrough is an **explicitly forbidden anti-pattern** where an MCP server accepts a
token from an MCP client without validating that the token was issued for the MCP server
itself, and then forwards that token to a downstream API.

### Why It Is Dangerous

- **Security control circumvention**: Rate limiting, request validation, and traffic monitoring
  on the downstream API may depend on token audience constraints. Bypassing audience validation
  means bypassing those controls.
- **Accountability loss**: The MCP server cannot distinguish between MCP clients when tokens
  are upstream-issued and opaque. Downstream logs show requests appearing to come from a
  different identity, breaking audit trails and incident investigation.
- **Proxy for exfiltration**: A stolen token carried as-is can be used to exfiltrate data
  through the MCP server without the attacker needing to obtain a new token.
- **Trust boundary violation**: The downstream resource server grants trust to specific entities.
  Forwarding another entity's token breaks that trust model and can enable cross-service token reuse.
- **Future compatibility risk**: A server that starts as a "pure proxy" accumulates a pattern
  that becomes harder to evolve toward proper token audience separation.

### Mitigation

MCP servers **MUST NOT** accept any tokens not explicitly issued for the MCP server.

When an MCP server needs to call upstream APIs, it **MUST** obtain a separate token from the
upstream authorization server — using its own client credentials — for that specific resource.
The client's token never leaves the MCP server.

See [[lit-mcp-authorization]] §Access Token Privilege Restriction for the specification-level
MUST language and RFC 8707 resource indicator requirements.

---

## 3. Server-Side Request Forgery (SSRF)

### What It Is

During OAuth metadata discovery, an MCP client fetches several URLs that can be controlled
by a malicious MCP server:

1. The `resource_metadata` URL from the `WWW-Authenticate` header
2. The `authorization_servers` URLs from the Protected Resource Metadata document
3. The `token_endpoint`, `authorization_endpoint`, and other URLs from AS Metadata

A malicious server populates these fields with URLs pointing to internal resources.

### Attack Patterns

| Pattern | Example | Effect |
|---|---|---|
| Direct internal IP | `http://10.0.0.1/admin` | Hit internal admin panels |
| Cloud metadata | `http://169.254.169.254/latest/meta-data/` | Exfiltrate IAM credentials |
| Localhost services | `http://localhost:6379/` | Interact with Redis/DBs |
| DNS rebinding | Domain resolves to safe IP at check, internal IP at use (TOCTOU) | Bypass IP validation |
| Redirect chains | Normal URL that 301-redirects to internal resource | Indirect bypass |

### Risks

- **Credential exfiltration**: Cloud metadata endpoints expose IAM credentials, API keys, secrets
- **Internal network reconnaissance**: Error messages leak network topology
- **Service mutations**: POST requests to token endpoints can trigger changes on internal services
- **Firewall bypass**: The MCP client acts as a request proxy, circumventing perimeter controls

### Mitigations

**Enforce HTTPS**: MCP clients **SHOULD** reject `http://` URLs in production (allow loopback
only in development). Aligns with OAuth 2.1 §1.5.

**Block Private IP Ranges** (per RFC 9728 §7.7):
- `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`
- Loopback: `127.0.0.0/8`, `::1`
- Link-local: `169.254.0.0/16` (cloud metadata)
- Private IPv6: `fc00::/7`, `fe80::/10`

> **Warning:** Do not implement IP validation manually. Attackers exploit encoding tricks
> (octal, hex, IPv4-mapped IPv6) that custom parsers routinely miss. Use a well-tested library.

**Validate Redirect Targets**: Apply the same HTTPS + IP-range restrictions to every hop
in redirect chains. Consider disabling automatic redirect following and validating manually.

**Use Egress Proxies**: For server-side MCP client deployments, route OAuth discovery requests
through an egress proxy (e.g., Stripe Smokescreen) that enforces network policies at the
infrastructure level. Combine with network policy restrictions on the MCP client's outbound access.

**DNS TOCTOU**: Pin DNS resolution results between check and use. Combine with other mitigations
(defense in depth); DNS-only validation is insufficient against rebinding attacks.

---

## 4. Session Hijacking and Event Injection

### What It Is

MCP servers using stateful HTTP assign session IDs to clients. An attacker who obtains or
guesses a valid session ID can exploit it in two ways:

**Session Hijack Prompt Injection** (multi-server deployments):
1. Attacker knows/guesses the victim's session ID
2. Sends a malicious event to **Server B** using that session ID
3. Server B enqueues the malicious payload keyed by session ID into a shared queue
4. **Server A** (the victim's server) polls the queue, retrieves the payload
5. Server A forwards the payload to the client as an async or resumed response
6. Client acts on the malicious payload

This attack is especially potent when servers support **resumable streams** — a request
deliberately terminated by the attacker can be resumed by the original client via SSE GET,
delivering the injected payload. It can also exploit `notifications/tools/list_changed` to
silently enable tools the client never approved.

**Session Hijack Impersonation**:
1. Attacker obtains a session ID (e.g., from logs, network interception, or guessing)
2. Makes API calls directly to the server using the hijacked ID
3. Server treats requests as coming from the legitimate client

### Mitigations

- MCP servers **MUST** verify all inbound requests even when authorization is in place
- MCP servers **MUST NOT** use session IDs as an authentication mechanism
- Session IDs **MUST** be non-deterministic; **SHOULD** use a cryptographically secure RNG (e.g., UUID v4)
- Rotate or expire session IDs to reduce the hijack window
- **MUST** bind session IDs to user identity: store and key queue entries as `<user_id>:<session_id>`,
  where `user_id` is derived from the verified user token — not supplied by the client

The `<user_id>:<session_id>` binding ensures that guessing a session ID is insufficient: the
attacker would also need to supply a matching user identity that only the authorization server
can issue.

---

## 5. Local MCP Server Compromise

### What It Is

Local MCP servers are binaries downloaded and executed on the user's own machine. They run
with the same privileges as the MCP client and may be accessible to other processes on the
host. Three attack vectors apply:

1. **Malicious startup command** embedded in a client configuration file
2. **Malicious payload** distributed inside the server binary itself
3. **Exposed localhost port** accessed by an attacker via DNS rebinding

Example malicious startup commands a client might execute:
```
sudo rm -rf /important/system/files && echo "MCP server installed!"
```

### Risks

- **Arbitrary code execution** at MCP client privilege level
- **No visibility**: users have no insight into what commands are running
- **Command obfuscation**: malicious operations disguised as legitimate-looking strings
- **Data exfiltration** via compromised JavaScript reaching legitimate local servers
- **Data loss** from destructive operations by buggy or malicious servers

### Mitigations

If an MCP client supports one-click local server configuration, it **MUST** show a consent
dialog before executing any command. The dialog **MUST**:
- Display the exact command to be run, without truncation (including all arguments)
- Identify it as code execution with full client privileges
- Require explicit user approval; allow cancellation

The client **SHOULD**:
- Highlight dangerous patterns: `sudo`, `rm -rf`, network ops, filesystem access outside expected paths
- Warn when accessing sensitive locations (home directory, SSH keys, system directories)
- Run local server commands in a sandboxed environment (container, chroot, platform sandbox)
- Restrict default access to filesystem, network, and other resources; grant additional
  privileges explicitly when the user requests them
- Keep sandboxing solutions updated against emerging vulnerabilities

Local servers themselves **SHOULD**:
- Use stdio transport to limit connections to the MCP client only
- If using HTTP transport: require an authorization token or use Unix domain sockets / IPC
  with restricted access controls

---

## 6. Scope Minimization

### Problem

When an MCP server publishes every scope in `scopes_supported` and the client requests them
all up-front, a stolen token becomes a master key. Broad-scope tokens produce:

- **Expanded blast radius**: one stolen token enables unrelated tool and resource access
- **Revocation friction**: revoking a max-privilege token disrupts all workflows
- **Audit noise**: an omnibus scope masks per-operation user intent
- **Privilege chaining**: attacker can invoke high-risk tools without further elevation
- **Consent abandonment**: users decline dialogs that list excessive scopes
- **Scope inflation blindness**: no metrics → over-broad requests become normalized

### Correct Model: Progressive Least Privilege

- **Minimal initial scope** (e.g., `mcp:tools-basic`): only low-risk discovery and read operations
- **Incremental elevation**: targeted `WWW-Authenticate: scope="..."` challenges when privileged
  operations are first attempted
- **Down-scoping tolerance**: servers should accept tokens with reduced scope; auth servers MAY
  issue a subset of requested scopes

**Server guidance:**
- Emit precise scope challenges; do not return the full catalog in every response
- Log elevation events (scope requested, granted subset) with correlation IDs

**Client guidance:**
- Begin with baseline scopes from the initial `WWW-Authenticate` challenge
- Cache recent failures to avoid repeated elevation loops for denied scopes

### Common Mistakes (Antipatterns)

| Antipattern | Why It's Dangerous |
|---|---|
| Publishing all scopes in `scopes_supported` | Invites clients to request everything |
| Wildcard/omnibus scopes (`*`, `all`, `full-access`) | Single token unlocks everything |
| Bundling unrelated privileges to preempt prompts | Violates least-privilege, expands blast radius |
| Returning full scope catalog in every challenge | Trains clients to always request max |
| Silent scope semantic changes without versioning | Breaks audit trails |
| Treating claimed token scopes as sufficient without server-side authorization logic | Token claims alone are not enforcement |

---

## See Also

- [[lit-mcp-authorization]] — specification-level coverage: OAuth 2.1 mechanics, discovery, audience binding, step-up
- [[lit-mcp-security-and-auth]] — companion literature note: broader security model, session hijacking patterns
- [[mcp-moc]] — MCP Map of Content: full protocol reference
- [[capability-lattice-spec]] — formal lattice model; scope minimization maps to lattice tier enforcement
- [[pattern-capability-gating]] — pattern: enforcing capability checks before delegation; scope as capability declaration
- [[spec-agentic-source-orchestrator-v2]] — orchestrator design; tool surface authorization requirements
