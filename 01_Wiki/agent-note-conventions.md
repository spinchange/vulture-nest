---
title: Agent Note Conventions
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [note-conventions, agent-metadata-standards]
---
# Agent Note Conventions

Canonical standards for agent-written notes within the vault to ensure readability, interoperability, and durability across human and AI workflows.

## Metadata Standards (Frontmatter)
Every standalone agent-authored note must include:
* `author`: The specific agent or person name (e.g., `gemini-cli`, `human`).
* `hostname`: The system where the note was originally authored.
* `date`: Authorship date (YYYY-MM-DD).
* `status`: Current lifecycle state (`draft`, `active`, `archived`).

### Frontmatter Immutability
Metadata fields are generally written once and not overwritten, preserving the provenance of the original authorship. The `status` field is the exception, updated alongside a `status_log`.

## Append Protocol
When adding new content to an existing note, use dated appendix headings to preserve context and history.
**Format:** `## YYYY-MM-DD HH:mm · Hostname · Author`

## Status Management
* **Spec Values**: `draft` (default), `active`, `archived`.
* **Workflow Signals**: `in-progress`, `blocked`, `done`.
* **Status Log**: An append-only list in frontmatter tracking every transition.

## Structural Principles
* **Atomicity**: Keep notes focused on a single concept or entity.
* **Readability**: Human-first prose; avoid decorative metadata or transcript noise.
* **Wikilinks**: Use `[[Wikilink]]` for all internal connections.

---
## References
* Source: `00_Raw/agent-note-conventions.md`
* [[core-patterns-moc]]
* [[yanp-for-agentic-workflows]]
