---
title: Experiment Capture Protocol
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases: [experiment-logging, debate-log-format, lab-notebook-protocol]
---

# Experiment Capture Protocol

A lightweight YANP variant for the `04_Experiments/` directory. Covers two experiment types: **runs** (scripts, sampling, pipelines) and **debates** (adversarial multi-agent exchanges).

---

## Directory Structure

```
04_Experiments/
  YYYY-MM-DD_<slug>/
    entry.md          # structured entry note (required)
    transcript.md     # raw conversation/output (optional)
    *.ps1 / *.py      # scripts used or produced
    results/          # output artifacts
```

Each experiment lives in its own dated directory. The `entry.md` is the canonical record.

---

## Entry Note Schema (YANP Variant)

```yaml
---
title: <human-readable experiment name>
author: <agent or "human">
date: YYYY-MM-DD
status: active | complete | abandoned
type: experiment
experiment-type: run | debate | evaluation
participants: [claude, gemini, codex, human]  # who was involved
hypothesis: <one sentence — what you expected to happen>
result: <one sentence — what actually happened>
verdict: confirmed | refuted | inconclusive | ongoing
aliases: []
---
```

The `hypothesis` and `result` fields are mandatory even if approximate. They are the minimum unit of compounding value.

---

## Debate Log Format

For adversarial agent debates, `entry.md` also includes:

```markdown
## Opening Positions
| Agent | Position |
|---|---|
| Claude | ... |
| Gemini | ... |

## Key Pivot Points
- [timestamp or turn N] Claude conceded X when presented with Y
- [timestamp or turn N] Gemini held on Z despite Claude's counterargument

## Outcome
**Verdict:** [which position held / split / inconclusive]
**Why:** [one paragraph — the deciding argument or evidence]

## Longitudinal Tags
#topic/type-safety #format/debate #verdict/split
```

Tags enable cross-debate queries: "all debates on type safety where verdict was split."

---

## PoShWiKi Integration

Debates and runs are also logged to SQLite via `New-DebateLog` (Codex to implement):

```powershell
New-DebateLog `
  -Topic "PS7 vs bash for agentic tooling" `
  -Participants @("claude", "gemini") `
  -Hypothesis "Claude will favor bash; Gemini will favor PS7" `
  -Verdict "split" `
  -EntryPath "04_Experiments/2026-04-27_ps7-bash-debate/entry.md"
```

This writes a row to the `Debates` table in `wiki.db`, making debate history queryable without reading markdown.

---

## New-Experiment Scaffolding

Codex will implement `02_System/new-experiment.ps1`:

```powershell
New-Experiment -Slug "verbalized-sampling-v2" -Type "run" -Participants @("claude", "human")
# Creates: 04_Experiments/2026-04-27_verbalized-sampling-v2/entry.md
```

---

## Relationship to Main Vault

- `04_Experiments/` notes do NOT require the full YANP frontmatter set (no `aliases` required if not cross-linked)
- Completed experiments with durable findings SHOULD produce a permanent note in `01_Wiki/` via the normal ingestion pipeline
- The experiments MOC ([[experiments-moc]]) is updated by Gemini after each new experiment directory is created

---

## References
- [[experiments-moc]]
- [[verbalized-sampling]]
- [[productivity-roadmap-2026-04-27]]
- [[yanp-for-agentic-workflows]]
