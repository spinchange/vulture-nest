---
title: PoShWiKi
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [powershell-wiki, posh-wiki, agent-memory-db]
---
# PoShWiKi

**PoShWiKi** is a minimalist, cross-platform wiki system built on **PowerShell 7** and **SQLite**. It is specifically designed as a "scriptable memory" for agents and terminal-centric workflows.

## Core Philosophy
Unlike file-based wikis (like YANP), PoShWiKi stores pages in an SQLite database, providing:
- **Concurrency:** Safer simultaneous access than plain text files.
- **Queryability:** Fast searching and metadata retrieval via SQL/LINQ patterns.
- **Atomicity:** Updates to specific sections (via `upsert-section`) ensure that only intended changes are committed.

## Technical Architecture
- **Language:** PowerShell 7.x (cross-platform).
- **Database:** SQLite via the `Microsoft.Data.Sqlite` library.
- **Interface:** `wiki.ps1` CLI with JSON support for agent integration.

## Interaction Patterns
PoShWiKi introduces several "agent-optimized" commands:
- **`upsert-section`**: Updates a `##` heading's content or creates it if missing. This is highly efficient for maintaining "Decisions" or "Next Steps" lists.
- **`append-section`**: Adds content to the end of a section, ideal for chronological "Actions" logs.
- **`-JSON` Flag**: Ensures all read/list operations return machine-parseable data.

## Integration with YANP
In this vault, PoShWiKi serves as a **Sidekick Database**. While the primary knowledge is stored in `01_Wiki/` as YANP-compliant Markdown, PoShWiKi can be used for:
- **Session Logs:** Tracking step-by-step progress during a task.
- **Transient State:** Storing temporary variables or findings that don't yet warrant a permanent note.
- **Tooling Metadata:** Managing the `TOOL_REGISTRY` or other system-level lists.

## Agent Governance
The `PoShWiKi` project includes a formal **Agent Governance** framework (`docs/tracking/agent-governance.md`) that defines roles and rules for agentic collaboration:
- **Roles:** Distinguishes between the `Tracking Owner`, `Verifier`, and `Documentarian`.
- **Verification:** Emphasizes that "Done" requires explicit validation against the project brief and spec, not just execution output.
- **State Management:** Uses a strict lifecycle (`Ready`, `Now`, `Blocked`, `Done`) for tracking work.
- **Seams:** Prioritizes identifying "clean seams" for safe pauses or handoffs between agents or human sessions.

---
## References
- [[ms-repo-poshwiki]] (Source)
- [[powershell-moc]]
- [[dotnet-moc]]
- [[ef-core-basics]] (The underlying technology)
