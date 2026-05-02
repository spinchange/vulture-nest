---
title: "Handoff: lit-mcp-security-best-practices Graph Integration"
author: "claude-sonnet-4-6"
date: "2026-05-01"
status: "active"
type: "fleeting"
targets: [gemini]
aliases:
  - "mcp-security-bp-handoff-2026-05-01"
---

# Handoff: lit-mcp-security-best-practices Graph Integration

**To:** Gemini (The Librarian)
**From:** Claude (The Chronicler)
**Session date:** 2026-05-01
**Priority:** Standard — graph/index integration only

---

## 1. Target Note Created

| Item | Value |
|---|---|
| Path | `01_Wiki/lit-mcp-security-best-practices.md` |
| Title | Literature: MCP Security Best Practices |
| Type | `literature` |
| Status | `active` |
| Author | `claude-sonnet-4-6` |
| Commit | `503353ed` |

---

## 2. Source Provenance

| Field | Value |
|---|---|
| Originally proposed URL | `https://modelcontextprotocol.io/specification/2025-11-25/basic/security_best_practices` |
| Resolved indexed URL | `https://modelcontextprotocol.io/docs/tutorials/security/security_best_practices` |
| Supabase `page_id` | `eede9071-46f4-4463-a392-acea3b7000c0` |
| Crawl job | `019de5f7-b8d3-7580-8bed-dc7d3db35b18` |
| Indexed chunks | 13 total; 12 retrieved |

The spec URL redirected to the docs/tutorials path at crawl time. This is noted in the
note's `source_note` frontmatter field. **Do not alter provenance** unless you find an
actual mismatch between a chunk's content and the section it supports.

**chunk_ids used (all from page_id eede9071):**
```
2a5a73f7-5483-466a-a7f1-bd83efa758a6   # Purpose and Scope
49d4cae6-cb2d-46d1-9a95-faf3a18b959b   # Confused Deputy: terminology, vulnerable conditions
c7bd1a10-95cd-48f6-ae41-7a721f0e2310   # Confused Deputy: attack steps + required mitigations
8dfd84d9-a24b-47ba-bf21-0b954f303aa6   # Confused Deputy: state parameter validation invariant
d6f28c8d-ffec-4bc2-b846-7aa94f01f4ff   # Token Passthrough: definition, risks, mitigation
4b8d2f91-2025-4c88-9916-de7c65163aa0   # SSRF: attack description + primary mitigations
c6afbfd3-cc9e-4e03-98f8-5119ab5eec95   # SSRF: egress proxies, DNS TOCTOU, OWASP references
508b45ed-d535-4018-9822-a39e3b23488a   # Session Hijacking: attack flows + mitigations
d5884eb8-9f29-4237-817d-35b88a01d6bb   # Session Hijacking: user-id binding continuation
00ef3e2c-ea96-44fe-a97d-0a309afc7a4b   # Local MCP Server Compromise: intro + attack description
cee699d5-922d-4371-b558-ba75bfa4696b   # Local MCP Server: risks + privilege escalation mitigation
52ba0232-bf91-4ee6-9d47-6a4ea58d46a8   # Scope Minimization: risks, mitigation model, common mistakes
```

The missing 13th chunk (chunk_index: 0) was not returned by any semantic query at threshold
≥ 0.35. It is likely the page preamble/table-of-contents chunk. Coverage of all required
topic areas is complete from the 12 retrieved chunks.

---

## 3. Summary of Main Claims

The note covers six areas of the MCP Security Best Practices document:

1. **Purpose and scope** — companion document to the MCP Authorization spec; focuses on
   attack vectors and mitigations for developers, operators, and security reviewers; references
   RFC 9700 (OAuth 2.0 Security BCP).

2. **Confused deputy** — requires all four conditions (static client ID + DCR + consent cookie
   + absent per-client consent gate). Attack bypasses user consent via cookie reuse across a
   malicious dynamically-registered client. Mitigation: per-client consent registry, `__Host-`
   cookie prefix, exact redirect URI matching, cryptographically random `state` set only after
   consent approval.

3. **Token passthrough** — explicitly forbidden anti-pattern. Four risk dimensions: bypasses
   downstream security controls, destroys audit trail, enables exfiltration via proxy, breaks
   trust boundaries. MCP servers must obtain separate tokens for every upstream API they call.

4. **SSRF** — malicious MCP server poisons `resource_metadata`, `authorization_servers`,
   `token_endpoint` URLs with internal addresses. Mitigations: enforce HTTPS, block private IP
   ranges per RFC 9728 §7.7 (including `169.254.0.0/16` cloud metadata range), validate redirect
   chains, use egress proxy (Smokescreen pattern), pin DNS to defeat TOCTOU rebinding.

5. **Session hijacking and event injection** — two variants: prompt injection via shared queue
   in multi-server deployments (exploits resumable streams + `notifications/tools/list_changed`),
   and direct impersonation. Mitigation: `<user_id>:<session_id>` binding where `user_id` is
   derived from the verified token, not supplied by the client.

6. **Scope minimization** — broad up-front scopes expand blast radius and enable privilege
   chaining. Correct model: minimal baseline + targeted `WWW-Authenticate` step-up challenges.
   Six-entry antipattern table (wildcard scopes, returning full catalog in every challenge,
   trusting token claims without server-side authorization logic, etc.).

---

## 4. Wikilinks Present in the Note

All required cross-links are in the "See Also" section of `lit-mcp-security-best-practices.md`:

```
[[lit-mcp-authorization]]
[[lit-mcp-security-and-auth]]
[[mcp-moc]]
[[capability-lattice-spec]]
[[pattern-capability-gating]]
[[spec-agentic-source-orchestrator-v2]]
```

---

## 5. MOC/Index Integration Tasks for Gemini

Files already updated in commit `503353ed`:
- `01_Wiki/index.md` — entry added under Literature Notes
- `01_Wiki/lit-mcp-security-and-auth.md` — `[[lit-mcp-security-best-practices]]` back-reference added to See Also

Remaining integration work for you as Librarian:

### 5a. `01_Wiki/mcp-moc.md` — ADD entry (REQUIRED)

Add under **Deployment & Security**:

```markdown
* [[lit-mcp-security-best-practices]] - Literature: MCP Security Best Practices (confused deputy, token passthrough, SSRF, session hijacking, scope minimization)
```

The MOC already has `[[mcp-security]]` and `[[mcp-authorization]]` in that section, plus
`[[lit-mcp-authorization]]` from the previous handoff. This note completes the literature
coverage for the security cluster.

Also add to the **See Also** block at the bottom:

```markdown
* [[lit-mcp-security-best-practices]] - Threat model and mitigations (attack-vector level)
```

### 5b. `01_Wiki/lit-mcp-authorization.md` — ADD back-reference (REQUIRED)

The authorization spec note's See Also currently lists `[[lit-mcp-security-and-auth]]` but
not the new threats note. Add:

```markdown
- [[lit-mcp-security-best-practices]] — companion threat model: confused deputy, SSRF, session hijacking attack flows and mitigations
```

### 5c. `01_Wiki/pattern-capability-gating.md` — OPTIONAL enrichment

Scope minimization maps directly to capability gating: the pattern's lattice rule
(`Required ⊆ Caps(B) ∩ Scope(A)`) is violated when broad omnibus scopes are granted.
Consider adding to References:

```markdown
- [[lit-mcp-security-best-practices]] — scope minimization as the runtime enforcement of least-privilege gating
```

### 5d. `01_Wiki/spec-agentic-source-orchestrator-v2.md` — OPTIONAL enrichment

The orchestrator exposes a tool surface over HTTP. The threats documented here (token
passthrough, session hijacking, SSRF during discovery) apply directly to how the orchestrator's
MCP tools should be hardened. Consider adding a reference in Section 4 (Policy Enforcement):

```markdown
See [[lit-mcp-security-best-practices]] for the full threat model applicable to HTTP-exposed MCP tool surfaces.
```

---

## 6. Validation Results

| Check | Result |
|---|---|
| YANP audit (`audit-yanp.ps1`) | **PASSED** — "All notes are YANP compliant!" |
| Broken-link check (`check-broken-links.ps1`) | **PASSED** — "No broken links found. Graph integrity is 100%." |

**Note:** An initial YANP run failed because the `source_note` frontmatter field used a YAML
folded scalar (`>`), which the audit script's parser rejected as "Invalid frontmatter line."
Fixed by converting to a single-line quoted string before the final commit.

---

## 7. Commit Status

| Item | Value |
|---|---|
| Committed | **Yes** |
| Commit hash | `503353ed` |
| Branch | `main` |
| Files in commit | `01_Wiki/lit-mcp-security-best-practices.md` (new), `01_Wiki/index.md` (modified), `01_Wiki/lit-mcp-security-and-auth.md` (modified) |
| Pushed to remote | No — push when your integration work is ready |

After your integration edits (§5a–5d), commit with:
```
chore(graph): wire lit-mcp-security-best-practices into MCP MOC and cross-references
```

---

## 8. Remaining Risks and Open Questions

1. **13th chunk not retrieved** — chunk_index 0 (likely the page TOC/preamble) was not returned
   by any query at threshold ≥ 0.35. If you identify a topic gap in the note, query
   `semantic_search_sources` with a targeted term to retrieve it. Do not re-crawl.

2. **Spec URL redirect** — The canonical spec URL now redirects to the docs/tutorials path.
   This may reflect a deliberate re-homing of the content from the spec to the docs site.
   The `source_note` field documents this. If MCP ever publishes a versioned spec-path
   equivalent at the original URL, the note's `source` field should be updated to point there.

3. **`mcp-best-practices` note** — `lit-mcp-security-and-auth.md` links `[[mcp-best-practices]]`
   in its See Also. This note was not verified to exist during this session. Confirm it is a
   valid target or flag it as a broken link.

4. **Confused deputy state param invariant** — Chunk `8dfd84d9` documents a subtle but critical
   invariant: the consent cookie/session storing the OAuth `state` value MUST NOT be set until
   after the user approves the MCP consent screen. This is an implementation trap that existing
   MCP proxy servers may have wrong. Consider whether this warrants a dedicated implementation
   warning in `[[mcp-authorization]]` or a new permanent note.

5. **Overlap with `lit-mcp-security-and-auth`** — The existing Gemini-authored security note
   covers confused deputy, SSRF, token passthrough, and session hijacking at a summary level.
   The new note goes substantially deeper on each. The two notes are complementary, not
   redundant; the existing one is better as a quick-reference, the new one as an attack-vector
   reference. Consider whether the existing note should explicitly label itself as the
   quick-reference and link the new note as the deep-dive.
