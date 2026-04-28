---
title: Productivity Roadmap — April 2026
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: fleeting
aliases: [roadmap-2026-04, fleet-roadmap-april]
---

# Productivity Roadmap — April 2026

Generated from a new-computer setup session. Four pillars, each with an owner and concrete deliverables. Handoffs for Codex and Gemini are linked below.

---

## Pillar 1 — Seam Tightening
**Problem:** Handoff seams are prose-only. The next agent has to read and interpret context rather than query it. PoShWiKi is underused as the structured memory layer.

**Goal:** `New-WikiSeam` writes a structured SQLite row in addition to the markdown note. Goal, blockers, next-step, and target-agent become discrete queryable columns — not a prose blob.

**Owner:** Codex (schema + implementation) → Gemini (visitor-directives.md update)
**Handoff:** [[codex-roadmap-sprint-handoff-2026-04-27]]

---

## Pillar 2 — Experiment Capture Pipeline
**Problem:** Experimental artifacts (scripts, debate transcripts, sampling runs) are untracked or buried in `00_Raw/` and `02_System/`. No convention for hypothesis → run → result → note.

**Goal:** A `04_Experiments/` directory with a lightweight YANP variant and a `New-Experiment` scaffolding script. Every experiment gets a dated directory with a structured entry note.

**Owner:** Codex (scaffold script) → Gemini (directory, convention doc, index update)
**Handoff:** [[codex-roadmap-sprint-handoff-2026-04-27]], [[gemini-roadmap-sprint-handoff-2026-04-27]]

---

## Pillar 3 — Adversarial Debate Logging
**Problem:** Adversarial debates between agents (Claude vs. Gemini, etc.) produce valuable longitudinal signal — which positions hold, where models diverge, what framings cause capitulation — but the results live only in conversation history.

**Goal:** A structured debate log format stored in PoShWiKi. Each debate gets: topic, participants, opening positions, key pivot points, outcome/verdict, and a link to the raw transcript if captured. Queryable over time.

**Owner:** Claude (format spec — see [[experiment-capture-protocol]]) → Codex (PoShWiKi table + `New-DebateLog` script)
**Handoff:** [[codex-roadmap-sprint-handoff-2026-04-27]]

---

## Pillar 4 — Git Commit Attribution
**Problem:** Every commit in the vault is attributed to `gemini-cli@yanp.internal`. Human commits are indistinguishable from agent commits. The audit trail loses the human/agent distinction.

**Goal:** A convention (and optional PS7 wrapper or git hook) that tags human-authored commits differently — either via a distinct author name or a consistent message prefix like `[human]`. Agent commits continue as-is.

**Owner:** Codex (implementation)
**Handoff:** [[codex-roadmap-sprint-handoff-2026-04-27]]

---

## Immediate Actions (This Session)
- [x] Created `CLAUDE.md` in vulture-nest (persistent agent context)
- [x] Cleaned up `.claude/settings.local.json` (pattern-based permissions)
- [x] Saved persistent memory (user profile, project, feedback)
- [ ] Commit untracked files: `verbalized-sampling.ps1`, `verify_db.ps1`, `02_System/prototypes/` → delegate to Codex

---

## References
- [[experiment-capture-protocol]]
- [[codex-roadmap-sprint-handoff-2026-04-27]]
- [[gemini-roadmap-sprint-handoff-2026-04-27]]
- [[inter-agent-handoff-protocol]]
- [[visitor-directives]]
- [[experiments-moc]]
