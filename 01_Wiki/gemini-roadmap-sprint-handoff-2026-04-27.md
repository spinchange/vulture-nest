---
title: Gemini Handoff — Roadmap Sprint 2026-04-27
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: fleeting
targets: [gemini]
aliases: [gemini-roadmap-handoff-april]
---

# Gemini Handoff — Roadmap Sprint

Hey Gemini. This handoff comes after Codex completes [[codex-roadmap-sprint-handoff-2026-04-27]]. Wait for Codex's seam before starting. Your work is structure, protocol, and index — no implementation.

---

## Context

A new-computer setup session produced a four-pillar roadmap ([[productivity-roadmap-2026-04-27]]). Codex handles implementation (SQLite schema, scripts, git tooling). You handle the vault's structural response: new directories, protocol updates, and index maintenance.

---

## Task 1 — Create 04_Experiments/

The vault currently has no `04_Experiments/` tier. Create it:

```powershell
New-Item -ItemType Directory -Path "04_Experiments" -Force
```

Then create `04_Experiments/README.md`:

```markdown
# 04_Experiments

Dated experiment directories. Each contains an `entry.md` following the [[experiment-capture-protocol]].

Use `02_System/new-experiment.ps1` to scaffold a new experiment.

## Convention
- Directory name: `YYYY-MM-DD_<slug>`
- Required file: `entry.md` with experiment frontmatter
- Completed experiments with durable findings → ingest to `01_Wiki/` via normal pipeline
```

---

## Task 2 — Update visitor-directives.md

Add a new section **6. Experiment Capture** after the existing Section 5 (The Handoff):

```markdown
## 6. Experiment Capture
All experimental work (scripts, debates, sampling runs) is captured in `04_Experiments/` using the [[experiment-capture-protocol]].

- Use `02_System/new-experiment.ps1` to scaffold a new experiment directory.
- For adversarial debates, use `New-DebateLog` from `poshwiki-tools.ps1` to write a structured SQLite record.
- Completed experiments with durable findings should be ingested into `01_Wiki/` via the normal pipeline.
```

Also update **Section 5 (The Handoff)** to note that `New-WikiSeam` now writes to SQLite and that `Get-LastSeam -Target <agent>` can be used to retrieve the prior seam without reading markdown.

---

## Task 3 — Update index.md

Add two new entries to the appropriate sections:

Under **System / Protocol:**
- `[[experiment-capture-protocol]]` — Lightweight YANP variant for 04_Experiments/; covers runs and adversarial debates

Under **Maps of Content:**
- `[[experiments-moc]]` already exists — add a note that it now covers the 04_Experiments/ pipeline

Under **Roadmaps / Active Work:**
- `[[productivity-roadmap-2026-04-27]]` — April 2026 fleet roadmap: seam tightening, experiment capture, debate logging, git attribution

---

## Task 4 — Run Full Maintenance Cycle

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/audit-yanp.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/check-broken-links.ps1
```

Fix any YANP violations or broken links introduced by this sprint before committing.

---

## Task 5 — Commit and Push

```powershell
git add 04_Experiments/
git add 01_Wiki/index.md
git add 02_System/visitor-directives.md
git add -A  # pick up any Codex artifacts not yet staged
git commit -m "feat(structure): 04_Experiments tier, protocol updates, index maintenance"
git push
git -C 00_Raw/PoShWiKi push  # advance submodule if PoShWiKi changed
```

---

## Task 6 — Write Seam

Use the newly enhanced `New-WikiSeam` (now with SQLite) to close the sprint:

```powershell
New-WikiSeam `
  -Agent "gemini" `
  -Target "human" `
  -Goal "Complete April 2026 productivity roadmap sprint" `
  -Seam "All four pillars implemented and indexed. 04_Experiments/ live. Seam protocol upgraded." `
  -NextStep "Begin first experiment using new pipeline — suggest running verbalized-sampling.ps1 as the inaugural 04_Experiments/ entry."
```

---

## References
- [[productivity-roadmap-2026-04-27]]
- [[experiment-capture-protocol]]
- [[codex-roadmap-sprint-handoff-2026-04-27]]
- [[experiments-moc]]
- [[visitor-directives]]
- [[inter-agent-handoff-protocol]]
