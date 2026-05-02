---
title: "Literature: MCP Authorization Specification"
author: "claude-sonnet-4-6"
date: "2026-05-01"
status: "active"
type: "literature"
aliases:
  - "MCP Authorization Spec"
  - "MCP OAuth 2.1"
  - "MCP Token Authorization"
source: "https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization"
source_page_id: "7ee79878-c9a7-4984-a76a-dda8a60c25d6"
chunk_ids:
  - "0381ccba-2ba5-4eba-bba3-cfd0167dc0e3"
  - "1c83398d-6371-446d-ab20-7bfd896f1fa0"
  - "bde0e47e-08ea-45a6-8303-ad6c54847870"
  - "fc803a77-47ee-4adc-9cc1-f49c3bb484bb"
  - "d2f3ba4d-c501-4a0b-a5cd-72bb1de3d1cc"
  - "e17634fa-af31-471e-8716-e835d0042801"
  - "090fa786-0a93-4de9-aee9-c55a1707d0e6"
  - "93fe278f-1686-42e9-aa9e-c5acf925d990"
  - "a76323b7-6890-4d1a-ab00-d8e3e1600a5d"
  - "bbd168a5-97da-4e39-b25f-2e2e8f286a75"
  - "f2249947-2a77-495a-91d2-fce27250351f"
  - "0232a602-2ac7-4e88-92c7-484aec47dbf4"
  - "6e992755-3928-4103-bc58-2aed7ebde93f"
  - "36c5e4bc-bff7-4c45-a1a8-eba3c3d4b577"
  - "5175649a-50eb-4769-b07d-1ff9c1ac3243"
  - "7e11433a-df67-45d7-a3dc-0c41f0aeeb24"
  - "86dd1b3d-e783-471a-897f-11d53c2879fa"
  - "af17d094-431b-4714-888f-fabe27f1a73e"
  - "84584256-b1d1-483b-951f-2a135f897a50"
  - "f65807b7-a86e-4dd2-8f1e-46d6456458a0"
crawl_job: "019de5e4-67e2-706a-ad95-5140bec54677"
---

# Literature: MCP Authorization Specification

Canonical source: MCP Specification 2025-11-25, Base Protocol — Authorization.
Covers the full OAuth 2.1-based authorization framework for HTTP-transported MCP servers,
from discovery through token usage through security mitigations.

---

## Purpose and Scope

Authorization is **OPTIONAL** in MCP. Its scope is explicitly transport-scoped:

| Transport | Authorization Handling |
|---|---|
| HTTP-based | **SHOULD** follow this specification (OAuth 2.1 flow) |
| STDIO | **SHOULD NOT** follow this spec; retrieve credentials from environment |
| Alternative transports | **MUST** follow established security best practices for that protocol |

The design goal is to allow MCP servers to act as OAuth 2.1 resource servers protecting
their tool and resource endpoints, without dictating the authorization server implementation.

---

## Standards Compliance

The specification implements a selected subset of:

- **OAuth 2.1** (`draft-ietf-oauth-v2-1-13`) — core grant flows, token validation, PKCE mandate
- **RFC 8414** — OAuth 2.0 Authorization Server Metadata (discovery)
- **RFC 7591** — OAuth 2.0 Dynamic Client Registration
- **RFC 9728** — OAuth 2.0 Protected Resource Metadata (server-side discovery anchor)
- **RFC 8707** — Resource Indicators for OAuth 2.0 (audience binding via `resource` parameter)
- **`draft-ietf-oauth-client-id-metadata-document-00`** — Client ID Metadata Documents

Implementors build against this subset, not against the full OAuth 2.x surface.

---

## Roles

Three principals participate in every authorized MCP interaction:

- **MCP Server** — acts as an *OAuth 2.1 resource server*; accepts and validates Bearer tokens
- **MCP Client** — acts as an *OAuth 2.1 client*; obtains tokens on behalf of a resource owner
- **Authorization Server** — issues tokens; may be co-located with the resource server or external;
  its implementation details are outside this specification's scope

---

## Authorization Server Discovery

Discovery is a two-stage process: locate the resource metadata, then use it to locate the
authorization server.

### Stage 1 — Protected Resource Metadata (RFC 9728)

MCP servers **MUST** implement RFC 9728. The metadata document **MUST** include an
`authorization_servers` field. Clients select from multiple listed authorization servers per
RFC 9728 §7.6.

Servers expose this document via **one or both** mechanisms:

1. **`WWW-Authenticate` header** — included in `401 Unauthorized` responses under the
   `resource_metadata` attribute:
   ```
   HTTP/1.1 401 Unauthorized
   WWW-Authenticate: Bearer resource_metadata="https://mcp.example.com/.well-known/oauth-protected-resource", scope="files:read"
   ```
2. **Well-Known URI** — served at `/.well-known/oauth-protected-resource[/<path>]`

Clients **MUST** support both; prefer the header when present, fall back to well-known URI probing.

The `scope` parameter in the `WWW-Authenticate` challenge gives clients immediate guidance on
least-privilege scope selection. Clients **MUST** treat challenged scopes as authoritative for
satisfying the current request (they are not guaranteed to match `scopes_supported`).

### Stage 2 — Authorization Server Metadata

Once the resource metadata URL is resolved, clients locate the authorization server and then
discover its endpoints via at least one of:

- **RFC 8414** — `/.well-known/oauth-authorization-server`
- **OpenID Connect Discovery 1.0** — `/.well-known/openid-configuration`

Clients **MUST** support both discovery mechanisms.

---

## Client Registration

Three paths exist for a client to establish a client identity with an authorization server:

1. **Client ID Metadata Documents** — client uses an HTTPS URL as its `client_id`; the
   authorization server fetches and validates the JSON metadata document at that URL. This is
   the preferred path for public, general-purpose MCP clients.
2. **Dynamic Client Registration (RFC 7591)** — client POSTs to `/register`; supported as an
   optional alternative.
3. **Preregistration** — client uses a hardcoded or user-supplied client ID; required as a
   fallback for authorization servers that do not support DCR or Client ID Metadata Documents.

---

## Authorization Flow

The full flow after the initial `401` challenge:

1. Client extracts `resource_metadata` URL from `WWW-Authenticate` (or probes well-known URI)
2. Client fetches Protected Resource Metadata → extracts authorization server URL(s)
3. Client fetches Authorization Server Metadata (RFC 8414 / OIDC)
4. Client resolves identity (Client ID Metadata Document, DCR, or preregistration)
5. Client generates PKCE `code_verifier` + `code_challenge` (S256 required when capable)
6. Client opens browser authorization URL with `code_challenge` + `resource` parameter
7. User consents; authorization server redirects to callback with authorization code
8. Client POSTs token request with `code_verifier` + `resource` → receives access token (+ optional refresh token)
9. Client attaches `Authorization: Bearer <token>` to every subsequent MCP request

---

## Access Token Usage and Audience Binding

### Token Transport Requirements

- Tokens **MUST** be sent in the `Authorization: Bearer <token>` HTTP header on every request,
  even within the same logical session
- Tokens **MUST NOT** be embedded in URI query strings

### Resource Parameter (RFC 8707) — Audience Binding

Clients **MUST** include the `resource` parameter in both the authorization request and token
request. It **MUST** be set to the canonical URI of the target MCP server. This binds the issued
token to that specific resource, making cross-service token reuse detectable and rejectable.

### Server-Side Token Validation

MCP servers **MUST** (per OAuth 2.1 §5.2):
- Validate the token before processing any request
- Verify the token's `aud` claim (or equivalent) includes the MCP server itself
- Return `HTTP 401` for invalid or expired tokens
- **NOT** accept tokens intended for other resources
- **NOT** accept or transit tokens that were originally issued to the client for the MCP server
  when making upstream API calls — the MCP server **MUST** obtain a separate token for any
  upstream resource it calls

---

## Scope Challenge and Step-Up Authorization

### Initial Scope Selection

During the initial authorization handshake, clients apply this priority order:

1. Use the `scope` parameter from the `WWW-Authenticate` 401 response if present
2. Otherwise use all `scopes_supported` from Protected Resource Metadata; omit `scope`
   if `scopes_supported` is undefined

General-purpose MCP clients typically lack domain knowledge to make finer-grained scope choices;
requesting all advertised scopes lets the authorization server and user determine appropriate
permissions at consent time.

### Runtime Step-Up Flow

When a client holds a valid token but attempts an operation that requires additional scopes,
the server **SHOULD** return:

```
HTTP/1.1 403 Forbidden
WWW-Authenticate: Bearer error="insufficient_scope",
  scope="files:read files:write user:profile",
  resource_metadata="https://mcp.example.com/.well-known/oauth-protected-resource",
  error_description="Additional file write permission required"
```

Clients **SHOULD** respond by:
1. Parsing the `insufficient_scope` error and required scopes
2. Initiating re-authorization with the expanded scope set (step-up flow)
3. Retrying the original request with the new token (with retry limits to avoid infinite loops)

`client_credentials` clients **MAY** abort rather than attempt step-up.

---

## Security Risks and Mitigations

### Token Theft

Attackers who obtain stored or cached tokens can make legitimate-looking requests.

**Mitigations:**
- Clients and servers **MUST** implement secure token storage (OAuth 2.1 §7.1 best practices)
- Authorization servers **SHOULD** issue short-lived access tokens
- For public clients, authorization servers **MUST** rotate refresh tokens (OAuth 2.1 §4.3.1)

### Open Redirect

Attackers craft malicious redirect URIs to capture authorization codes via phishing.

**Mitigations:**
- Clients **MUST** register redirect URIs with the authorization server
- Authorization servers **MUST** validate redirect URIs against exact pre-registered values
- Clients **SHOULD** use and verify `state` parameters; discard responses with missing or
  mismatched state
- Authorization servers **SHOULD** warn or block untrusted redirect URIs (OAuth 2.1 §7.12.2)

### Localhost Redirect URI Risks

Client ID Metadata Documents cannot prevent localhost impersonation. An attacker can:
1. Claim the legitimate client's metadata URL as their `client_id`
2. Bind to any available localhost port and provide it as `redirect_uri`
3. Receive the authorization code when the user approves — the server sees the legitimate
   client's metadata, so the attack is difficult to detect

**Mitigations:**
- Authorization servers **SHOULD** display additional warnings for localhost-only redirect URIs
- Authorization servers **MUST** clearly display the redirect URI hostname during authorization
- Authorization servers **MAY** require additional attestation for localhost clients

### Authorization Code Interception (PKCE)

Attackers who intercept an authorization code can exchange it for a token.

**Mitigations:**
- Clients **MUST** implement PKCE (OAuth 2.1 §7.5.2) using S256 when technically capable
- Clients **MUST** verify `code_challenge_methods_supported` is present in AS metadata before
  proceeding; if absent, authorization **MUST** be refused

### Confused Deputy Problem

MCP proxy servers acting as intermediaries to third-party APIs may allow attackers to obtain
tokens using stolen authorization codes without the user's knowledge.

**Mitigations:**
- MCP proxy servers using static client IDs **MUST** obtain user consent for each dynamically
  registered downstream client before forwarding to third-party authorization servers

### Token Passthrough and Audience Validation Failures

Two related vulnerabilities when a server is careless about token scope:

1. **Audience validation failure** — server accepts tokens not specifically issued for it
   (e.g., missing `aud` check per RFC 9068), allowing token reuse across services
2. **Token passthrough** — server forwards the client's MCP token unmodified to a downstream
   API, which may incorrectly trust it as if validated by the MCP server

**Mitigations:**
- Servers **MUST** reject tokens that do not include them in the audience claim
- Servers **MUST NOT** pass client tokens to upstream APIs; each upstream call requires a
  separate token obtained from the upstream authorization server
- Clients **MUST** implement the RFC 8707 `resource` parameter to bind tokens to their
  intended recipient at issuance time

### Authorization Server Abuse (SSRF)

When a server fetches metadata from a client-supplied URL (Client ID Metadata Document flow),
a malicious client can trigger requests to private admin endpoints.

**Mitigations:**
- Authorization servers **SHOULD** apply SSRF mitigations when fetching metadata documents
  (per `draft-ietf-oauth-client-id-metadata-document-00` §SSRF)

---

## Error Handling Reference

| HTTP Status | Meaning | When Used |
|---|---|---|
| `401 Unauthorized` | Authorization required or token invalid | Initial unauthenticated access; expired token |
| `403 Forbidden` | Invalid scopes or insufficient permissions | `insufficient_scope` runtime failures |
| `400 Bad Request` | Malformed authorization request | Structural errors in OAuth requests |

---
## See Also

- [[lit-mcp-security-and-auth]] — companion note covering security best practices, SSRF, session hijacking
- [[lit-mcp-security-best-practices]] — companion threat model: confused deputy, SSRF, session hijacking attack flows and mitigations
- [[mcp-moc]] — MCP Map of Content: full protocol reference
- [[capability-lattice-spec]] — lattice enforcement model; authorization gates map to lattice tiers
- [[spec-agentic-source-orchestrator-v2]] — orchestrator design; authorization constraints on agentic tool calls
- [[pattern-capability-gating]] — pattern: enforcing capability checks at delegation edges
