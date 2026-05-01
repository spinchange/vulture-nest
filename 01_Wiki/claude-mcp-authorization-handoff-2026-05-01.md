---
title: "Handoff: lit-mcp-authorization Graph Integration"
author: "claude-sonnet-4-6"
date: "2026-05-01"
status: "active"
type: "fleeting"
targets: [gemini]
aliases:
  - "mcp-authorization-handoff-2026-05-01"
---

# Handoff: lit-mcp-authorization Graph Integration

**To:** Gemini (The Librarian)
**From:** Claude (The Chronicler)
**Session date:** 2026-05-01
**Priority:** Standard — graph/index integration only

---

## 1. Target Note Created

| Item | Value |
|---|---|
| Path | `01_Wiki/lit-mcp-authorization.md` |
| Title | Literature: MCP Authorization Specification |
| Type | `literature` |
| Status | `active` |
| Author | `claude-sonnet-4-6` |
| Commit | `f9e44dca` |

---

## 2. Provenance Block

All evidence was retrieved via `semantic_search_sources` from the indexed page. No Firecrawl was run.

| Field | Value |
|---|---|
| Source URL | `https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization` |
| Supabase `page_id` | `7ee79878-c9a7-4984-a76a-dda8a60c25d6` |
| Crawl job | `019de5e4-67e2-706a-ad95-5140bec54677` |
| Indexed chunks used | 20 (see list below) |

**chunk_ids (in YAML frontmatter of the note):**
```
0381ccba-2ba5-4eba-bba3-cfd0167dc0e3   # Protocol requirements (HTTP vs stdio)
1c83398d-6371-446d-ab20-7bfd896f1fa0   # Standards compliance (RFC list)
bde0e47e-08ea-45a6-8303-ad6c54847870   # Overview requirements
fc803a77-47ee-4adc-9cc1-f49c3bb484bb   # Roles
d2f3ba4d-c501-4a0b-a5cd-72bb1de3d1cc   # Authorization Server Location
e17634fa-af31-471e-8716-e835d0042801   # Protected Resource Metadata Discovery
090fa786-0a93-4de9-aee9-c55a1707d0e6   # Discovery sequence diagram
93fe278f-1686-42e9-aa9e-c5acf925d990   # Authorization Flow steps
a76323b7-6890-4d1a-ab00-d8e3e1600a5d   # Scope Selection Strategy
bbd168a5-97da-4e39-b25f-2e2e8f286a75   # Resource Parameter (RFC 8707)
f2249947-2a77-495a-91d2-fce27250351f   # Token Requirements (Bearer header)
0232a602-2ac7-4e88-92c7-484aec47dbf4   # Token Handling (audience validation)
6e992755-3928-4103-bc58-2aed7ebde93f   # Error Handling table (401/403/400)
36c5e4bc-bff7-4c45-a1a8-eba3c3d4b577   # Scope Challenge / Step-Up flow
5175649a-50eb-4769-b07d-1ff9c1ac3243   # Access Token Privilege Restriction
7e11433a-df67-45d7-a3dc-0c41f0aeeb24   # Authorization Code Protection / PKCE
86dd1b3d-e783-471a-897f-11d53c2879fa   # Open Redirection
af17d094-431b-4714-888f-fabe27f1a73e   # Confused Deputy Problem
84584256-b1d1-483b-951f-2a135f897a50   # Client ID Metadata Doc Security / Localhost risks
f65807b7-a86e-4dd2-8f1e-46d6456458a0   # Token Theft
```

**Do not alter provenance** unless you find an actual mismatch between a chunk's content and the section it supports.

---

## 3. Summary of Main Claims

The note covers seven areas of the MCP Authorization Specification (2025-11-25):

1. **Transport split** — Authorization is optional; HTTP transports SHOULD use this OAuth 2.1 spec; STDIO SHOULD NOT (use environment credentials instead).
2. **Standards stack** — OAuth 2.1 + RFC 9728 (protected resource metadata) + RFC 8414 (AS metadata) + RFC 7591 (DCR) + RFC 8707 (resource indicators). The spec implements a selected subset only.
3. **Two-stage discovery** — Clients first resolve Protected Resource Metadata (via `WWW-Authenticate` header or well-known URI), then use the contained AS URL to discover authorization server endpoints.
4. **Access token audience binding** — The `resource` parameter (RFC 8707) must be included in both the authorization request and token request; servers must reject tokens whose `aud` does not include them; servers must not forward client tokens to upstream APIs.
5. **Scope challenge / step-up** — Runtime `403 insufficient_scope` triggers a re-authorization flow with an expanded scope set; `scopes_supported` in PRM is the minimal baseline; challenged scopes in `WWW-Authenticate` are authoritative for the current request.
6. **Security risks** — Token theft (short-lived tokens, refresh rotation), open redirect (exact URI validation + state param), localhost impersonation (Client ID Metadata Docs cannot prevent port-binding attacks), auth code interception (PKCE S256 mandatory), confused deputy (per-client consent required for proxies), token passthrough / audience failure (servers must validate `aud` and never transit tokens).
7. **Error codes** — 401 (no/invalid token), 403 (insufficient scope), 400 (malformed request).

---

## 4. Wikilinks Already Present in the Note

All five required cross-links are in the "See Also" section of `lit-mcp-authorization.md`:

```
[[lit-mcp-security-and-auth]]
[[mcp-moc]]
[[capability-lattice-spec]]
[[spec-agentic-source-orchestrator-v2]]
[[pattern-capability-gating]]
```

---

## 5. MOC/Index Integration Tasks for Gemini

These are your integration targets. The note was committed but the cross-file wikilink additions below were deliberately left for you as Librarian.

### 5a. `01_Wiki/mcp-moc.md` — ADD entry

The note is not yet listed in the MCP MOC. Add it under **Deployment & Security**:

```markdown
* [[lit-mcp-authorization]] - Literature: MCP Authorization Specification (OAuth 2.1, RFC 9728, audience binding, step-up flow)
```

The MOC already has `[[mcp-authorization]]` (the permanent concept note). This literature note is a separate artifact — keep both.

Also add to the **See Also** section at the bottom:

```markdown
* [[lit-mcp-authorization]] - Specification-level grounding for OAuth 2.1 authorization
```

### 5b. `01_Wiki/lit-mcp-security-and-auth.md` — ADD back-reference

The existing security note's **See Also** currently links `[[mcp-authorization]]` (permanent). Add a companion link to the new literature note:

```markdown
- [[lit-mcp-authorization]] - Specification-level coverage: discovery flow, audience binding, step-up, security risks
```

### 5c. `01_Wiki/capability-lattice-spec.md` — OPTIONAL enrichment

The lattice spec covers JSON-schema-to-type mapping and capability derivation via set intersection. The MCP authorization spec's `aud` claim + `scope` enforcement is the concrete runtime instantiation of this model for HTTP servers: the `resource` parameter binds a token to a specific lattice node; `insufficient_scope` triggers elevation. Consider adding to the spec's "See Also" or a new "Protocol Instantiations" section:

```markdown
- [[lit-mcp-authorization]] — OAuth `aud` + `scope` as the runtime lattice gate for HTTP-transported MCP servers
```

This is **optional** — add only if it fits the spec's existing framing. Do not alter the spec's formal content.

### 5d. `01_Wiki/spec-agentic-source-orchestrator-v2.md` — OPTIONAL enrichment

The orchestrator's 8-tool MCP surface is exposed over HTTP. The spec currently says nothing about which connections require authorization. Consider adding a note under **Section 3 (MCP Tool Surface)** or **Section 4 (Policy Enforcement)**:

```markdown
Tools exposed via HTTP transport MUST be protected per [[lit-mcp-authorization]]; the
`propose_source_intake` and `promote_synthesis_candidate` gates are highest-privilege and
SHOULD require scope validation before execution.
```

This is **optional** — only add if you judge it improves the spec's completeness without overreaching.

### 5e. `01_Wiki/pattern-capability-gating.md` — OPTIONAL back-reference

The pattern currently references `[[capability-lattice-spec]]` and framework implementations (A2A, ADK, Swarm) but not MCP's OAuth scope model. Consider adding to **References**:

```markdown
- [[lit-mcp-authorization]] — MCP's concrete implementation: OAuth `scope` as the capability declaration, `aud` as the gate boundary
```

This is **optional**.

### 5f. `01_Wiki/index.md` — ALREADY UPDATED

The index was updated in the same commit (`f9e44dca`). Entry is under **Literature Notes (Grounded Sources)**:

```markdown
* [[lit-mcp-authorization]] - Literature: MCP Authorization Specification (OAuth 2.1, RFC 9728, audience binding, step-up)
```

No further action needed on index.md.

---

## 6. Validation Results

| Check | Result |
|---|---|
| YANP audit (`audit-yanp.ps1`) | **PASSED** — "All notes are YANP compliant!" |
| Broken-link check (`check-broken-links.ps1`) | **PASSED** — "No broken links found. Graph integrity is 100%." |

Both checks were run post-write, pre-commit. The new note did not introduce any orphan links.

---

## 7. Commit Status

| Item | Value |
|---|---|
| Committed | **Yes** |
| Commit hash | `f9e44dca` |
| Branch | `main` |
| Files in commit | `01_Wiki/lit-mcp-authorization.md` (new), `01_Wiki/index.md` (modified) |
| Pushed to remote | No — push when your integration work is ready |

The graph integration edits (§5a–5e above) are not yet committed. After you make those changes, commit them separately with a message like:

```
chore(graph): wire lit-mcp-authorization into MCP MOC and cross-references
```

---

## 8. Remaining Risks and Open Questions

1. **`[[mcp-authorization]]` permanent note** — The MCP MOC already links a permanent note at `[[mcp-authorization]]`. I did not read that note. You should verify it does not duplicate the literature note's content to a degree that warrants merging or adding a disambiguation comment. If they overlap substantially, consider adding a frontmatter `see_also` cross-reference in the permanent note pointing to `[[lit-mcp-authorization]]` as the specification-level source.

2. **8 chunks not retrieved** — The index reports 28 chunks for this page; I retrieved evidence from 20. The 8 missing chunks were not returned by any semantic query at threshold ≥ 0.35. They likely cover: dynamic client registration flow details, canonical server URI construction, and MCP Authorization Extensions section. The note's coverage is comprehensive for all required topics, but if Gemini identifies a gap topic, those chunks can be retrieved via `semantic_search_sources` with a targeted query.

3. **`spec-agentic-source-orchestrator-v2` authorization scope** — The orchestrator spec does not currently specify which of its 8 tools require authenticated MCP connections. This is a real design gap (not just a documentation gap). Consider flagging it for Codex as a spec hardening task.

4. **Spec version pinning** — The literature note is pinned to `2025-11-25`. MCP authorization is under active development. The note should be reviewed against any newer spec version before being used as an implementation reference.
