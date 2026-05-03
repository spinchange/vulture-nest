---
title: PowerShell
author: codex
date: '2026-04-27'
status: active
type: permanent
aliases:
  - pwsh
  - powershell-7
---

# PowerShell

**PowerShell** is the vault's primary shell and automation substrate for system-facing work. In the Vulture Nest it occupies the practical operations layer: maintenance scripts, graph sync, dashboard generation, deployment glue, and terminal-native workflows are all written to run under `pwsh`, not legacy Windows PowerShell.

The important distinction in this vault is that PowerShell is not just a shell. It is a programmable object pipeline and the default execution environment for many Tier-2 automation tasks. Commands pass structured .NET objects rather than plain text, which is why patterns like `Select-Object`, calculated properties, and custom objects appear throughout the vault's maintenance scripts. That makes PowerShell the bridge between the knowledge graph and executable maintenance.

## PowerShell in the Nest

PowerShell appears here in two closely related roles:

**Operational runtime.** The vault's maintenance lane is defined in PowerShell: audits, orphan checks, broken-link scans, dashboard and registry generation, note scaffolding, and search tooling all run through `pwsh`. For the executable standards that govern scripts in this repo, start with [[ps-automation-spec]] and [[ps-vault-maintenance]].

**Language for object-shaped automation.** The reason PowerShell works well for the Nest is not only shell access. It is the object pipeline model: commands emit records with fields, downstream commands transform those records, and scripts can stay structured all the way to JSON, SQLite, or formatted output. That is the practical foundation behind [[powershell-objects]], [[ps-custom-objects]], and [[ps-calculated-properties]].

## Reading the Cluster

The PowerShell cluster is easiest to navigate in two tracks depending on whether you are learning the language or trying to operate the vault.

### Track 1 — Language and Data Flow

Start here if you are writing a new script or need to understand why the existing maintenance code is structured the way it is.

- **[[powershell-objects]]** — the core mental model. PowerShell moves objects through the pipeline, not strings.
- **[[ps-custom-objects]]** — how scripts emit stable, machine-readable records for downstream steps.
- **[[ps-calculated-properties]]** — the common pattern for reshaping object output without losing structure.
- **[[ps-classes]]** — use when a script grows beyond simple pipeline composition and needs more explicit state or behavior.
- **[[powershell-moc]]** — the broader map once the object pipeline model is clear.

### Track 2 — Vault Operations

Start here if your goal is to run, extend, or debug the Nest's maintenance and memory tooling.

- **[[ps-automation-spec]]** — the canonical rules for agent-runnable scripts in this repo.
- **[[ps-vault-maintenance]]** — the top-level maintenance runner; the quickest way to understand the operational workflow.
- **[[ps-yanp-audit]]**, **[[ps-orphan-check]]**, **[[ps-broken-link-checker]]** — the core health checks for note quality and graph integrity.
- **[[ps-tool-registry-generator]]** and **[[ps-vault-stats]]** — metadata and observability outputs for the vault.
- **[[ps-note-creator]]** — scaffolding path for adding new notes without drifting from conventions.
- **[[ps-vulture-search]]** — retrieval tooling that connects note content to operational search.
- **[[poshwiki]]** and **[[poshwiki-tools]]** — the SQLite-backed memory layer and the higher-level script interface agents actually use.

## Where to Start

If you are new to PowerShell in this vault:

1. Read [[powershell-objects]] first.
2. Then read [[ps-custom-objects]] and [[ps-calculated-properties]] to understand the data-shaping patterns used in real scripts.
3. Then read [[ps-automation-spec]] before editing or creating any repo automation.

If you are here to modify maintenance behavior specifically, start with [[ps-vault-maintenance]], then follow its supporting tools into [[ps-yanp-audit]] or [[ps-broken-link-checker]] as needed.

## See Also
- [[powershell-moc]]
- [[ps-automation-spec]]
- [[ps-vault-maintenance]]
- [[poshwiki]]
- [[programming-languages-moc]]
