---
title: Codex Validation Hardening Handoff 2026-04-28
author: codex
date: 2026-04-28
status: active
type: handoff
aliases: [validation-hardening-handoff, orphan-check-followup]
---

# Codex Validation Hardening Handoff 2026-04-28

## Current State

The repo is clean and `main` is synced to `origin/main`.

Recent validation improvements already landed:
- `3933b49` — `ci: run Python and Rust tests in vault validation`
- `b19200f` — `feat(validation): parse and enforce YANP frontmatter`
- `d14644a` — `feat(validation): improve broken link diagnostics`

## What Changed

### CI
- `.github/workflows/validate-vault.yml`
- CI now runs:
  - `pytest 02_System/test_chunker.py 02_System/test_memory_mcp.py`
  - `cargo test --manifest-path 00_Raw/tier-0/Cargo.toml`

### YANP Validation
- `02_System/audit-yanp.ps1`
- Replaced regex-only validation with frontmatter parsing.
- Validates required fields: `title`, `author`, `date`, `status`, `type`.
- Enforces allowed `type` and `status`.
- Recurses through `01_Wiki`, including subfolders.
- Reports duplicate aliases and titles as warnings, not failures.

### Schema Fix
- `01_Wiki/lit-verbalized-sampling-paper.md`
- Added missing `type: literature`.

### Broken Link Validation
- `02_System/check-broken-links.ps1`
- Reports broken links with source path, line number, target, and line preview.
- Ignores fenced code blocks.
- Ignores non-markdown asset wikilinks such as `[[...pdf]]`.
- Exits nonzero on real broken links.

## Next Recommended Task

Tighten `02_System/orphan-check.ps1`.

### Why
- It is still much cruder than the other validators.
- It uses non-recursive file discovery.
- It scans the whole vault as one string.
- It lacks path-aware reporting.
- It has no line-level or summary diagnostics.
- It likely has false positives and false negatives around aliases and path forms.

## Recommended Direction

Upgrade `02_System/orphan-check.ps1` to match the newer validator standard:
- Recurse through `01_Wiki`.
- Build a real note set from filenames.
- Scan source files line-by-line or file-by-file with the same wikilink semantics used in `check-broken-links.ps1`.
- Report orphan notes with relative path, title, type, and status.
- Add a summary count.
- Decide whether to fail nonzero on orphans or only warn.

## Constraints
- Keep the pass small.
- Prefer compatibility with current vault conventions over idealized schema changes.
- Do not broaden into a full graph-health refactor unless explicitly requested.
- Reuse parsing and link-normalization patterns from `audit-yanp.ps1` and `check-broken-links.ps1`.

## Verification Targets
- `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/orphan-check.ps1`
- Optionally `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1` if time permits

## Git Hygiene
- Commit the orphan-check improvement separately.
- Suggested message: `feat(validation): improve orphan note diagnostics`
