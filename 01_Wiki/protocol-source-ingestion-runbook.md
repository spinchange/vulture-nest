---
title: Source Ingestion Runbook
author: codex
date: 2026-05-01
status: active
type: permanent
aliases:
  - source-ingestion-runbook
  - firecrawl-ingestion-runbook
  - knowledge-compiler-runbook
---

# Source Ingestion Runbook

This runbook captures the operational protocol for turning an external source into grounded vault knowledge. It is the practiced workflow behind the [[spec-agentic-source-orchestrator]] and [[spec-firecrawl-pgvector-pipeline]].

## Role Sequence

The ingestion loop is deliberately multi-agent:

1. **Gemini / Librarian** prepares the intake packet: target URL, gap rationale, expected note, expected links, and policy/HITL assessment.
2. **Human / HITL** approves bounded crawls when policy requires approval or when the source is foundational.
3. **Codex / Engineer** runs the mechanical pipeline: dry run, live crawl, index, verify, and seam handoff. Codex does not synthesize or promote the permanent note in the same pass.
4. **Claude / Chronicler** synthesizes verified chunks into a literature or permanent note with provenance.
5. **Gemini / Librarian** performs final graph integration: MOC wiring, backlinks, index updates, log entry, and commit hygiene.

This preserves the Two-Role Invariant: no single agent both ingests source material and promotes it to permanent knowledge.

## Preflight

Before running an external crawl, Codex should verify the local tool surface:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System\check-mcp-health.ps1
```

Use live credential checks only when needed:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System\check-mcp-health.ps1 -LiveServices
```

Use `-LiveFirecrawl` only for explicit Firecrawl credential validation, because it calls the external service.

## Intake Packet

The Librarian intake should include:

- exact target URL
- reason this source closes a vault gap
- expected target note path and note type
- expected key wikilinks
- expected page count
- whether HITL is required or already granted
- explicit instruction not to broaden the crawl

For single-page documentation ingestion, prefer `expected_pages: 1`.

## Codex Execution Steps

Codex runs the pipeline in two phases.

### 1. Dry Run

Run:

- `propose_source_intake`
- `orchestrate_ingestion` with `dry_run: true`
- `execute_source_crawl` with `dry_run: true`

Proceed only if the dry run remains bounded: correct domain, expected page count, estimated credits, and HITL status.

### 2. Live Run

Run:

- `orchestrate_ingestion` with `dry_run: false`
- `execute_source_crawl` with `dry_run: false`
- `index_crawled_source`
- `verify_source_index`

Stop before synthesis unless the source index verifies with no blocking findings.

## Required Evidence IDs

Every successful Codex handoff must preserve:

- original requested URL
- resolved indexed URL, especially if a redirect occurred
- Firecrawl crawl job ID
- Supabase `source_pages.id`
- chunk count
- all chunk IDs used later by the synthesizing agent
- verification status and findings

These IDs are the bridge between the sidecar evidence and the promoted vault note.

## Redirect Handling

If a requested URL redirects, record both URLs. If Firecrawl returns zero pages for the redirecting URL, verify the resolved canonical URL in a browser or other read-only check, then repeat the dry run against the resolved URL before running the live crawl.

The MCP Security Best Practices ingestion used this path: the dated specification URL redirected to the current docs/tutorials URL, and the resolved URL was the one successfully indexed.

## Synthesis Handoff

After verification, Codex records a seam for Claude/Gemini with:

- source page ID
- chunk count
- crawl job ID
- source URL and resolved URL
- recommended target note path
- required links
- instruction not to crawl again

Claude should retrieve evidence through `semantic_search_sources`, write the target note, preserve provenance, validate with `audit-yanp.ps1` and `check-broken-links.ps1`, and commit only the note plus any explicit handoff artifact.

Gemini should then integrate the note into MOCs, backlinks, specs, and logs without changing the evidence provenance unless it finds a concrete mismatch.

## Commit Boundaries

Prefer three small commits:

1. `feat(wiki): add <source> literature note`
2. `docs(handoff): graph integration brief for Gemini re <source>`
3. `chore(graph): wire <source> into <cluster> cross-references`

Do not mix mechanical ingestion tooling changes with source synthesis commits.

## Provenance Shape

Current synthesized notes may use `source_page_id` plus `chunk_ids`, while some older notes use nested `provenance:` frontmatter. The YANP auditor accepts both today. A future normalization pass should decide one canonical shape and migrate notes consistently.

## References

- [[spec-agentic-source-orchestrator]]
- [[spec-agentic-source-orchestrator-v2]]
- [[spec-firecrawl-pgvector-pipeline]]
- [[synthesis-intelligence-layer]]
- [[lit-mcp-authorization]]
- [[lit-mcp-security-best-practices]]
- [[agent-note-conventions]]
