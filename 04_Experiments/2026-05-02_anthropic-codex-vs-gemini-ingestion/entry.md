---
title: Anthropic Ingestion Boundary Test
author: codex
date: '2026-05-02'
status: complete
type: experiment
experiment-type: evaluation
participants: ['codex', 'gemini', 'human']
hypothesis: Re-running the Anthropic API ingestion lane in a clean Gemini worktree will expose whether Codex crossing the role boundary materially changes note shape, graph edits, or verification outcomes.
result: Codex baseline judged stronger; Gemini produced useful minor deltas but failed the raw-corpus and compliance bar
verdict: confirmed
aliases: []
---

# Anthropic Ingestion Boundary Test

## Hypothesis
Re-running the Anthropic API ingestion lane in a clean Gemini worktree will expose whether Codex crossing the role boundary materially changes note shape, graph edits, or verification outcomes.

## Setup

- **Original handoff:** `01_Wiki/codex-anthropic-docs-ingestion-handoff-2026-05-02.md`
- **Parallel lane reference:** `01_Wiki/gemini-anthropic-docs-ingestion-handoff-2026-05-02.md`
- **Dirty Codex worktree:** `C:\Users\executor\Documents\vulture-nest`
- **Clean Gemini worktree:** `C:\Users\executor\Documents\vulture-nest\.tmp\gemini-anthropic-compare`
- **Base commit for clean worktree:** `c844db08f4e5acdc6a1f03000bdbcdcfaabc8da2`
- **Codex snapshot artifacts:** `artifacts/codex-worktree/`
- **Gemini execution brief:** `gemini-brief.md`

## Evaluation rubric

Compare the Codex and Gemini outputs on:

1. **Boundary adherence**: Did the agent stay inside its intended role, or combine ingestion, synthesis, and graph integration?
2. **Corpus discipline**: Was the raw-source set bounded to the requested Anthropic API surface?
3. **Note shape**: How many notes were created, and were they literature/permanent/handoff types appropriate to the evidence?
4. **Provider specificity**: Did the notes preserve Anthropic-specific semantics instead of flattening them into generic function-calling language?
5. **Graph edits**: Were backlinks and MOC/index changes minimal and high-signal, or broad and noisy?
6. **Verification**: Did `audit-yanp.ps1` and `check-broken-links.ps1` pass cleanly?
7. **Interesting deltas**: What did one agent notice or preserve that the other missed?

## Run Log

### Run A — Codex boundary-crossing baseline

- Codex executed the Anthropic ingestion batch directly in the primary worktree.
- This combined raw corpus staging, literature synthesis, permanent-note creation, and graph wiring in one pass.
- Verification passed:
  - `02_System/audit-yanp.ps1`
  - `02_System/check-broken-links.ps1`
- The resulting worktree was preserved instead of reverted.

### Run B — Gemini clean rerun

- Gemini executed the same lane independently in the clean worktree.
- Claude then inspected both worktrees using `claude-judge-brief.md` and produced a comparative judgment.

## Results

- **Claude judgment:** Codex is the stronger output by a clear margin.
- **Critical delta:** Gemini did not commit a real `00_Raw/anthropic/` corpus, even though the handoff made it a first-class deliverable.
- **Compliance failures on Gemini side:** missing or malformed literature-note provenance/frontmatter, malformed source wikilinks in permanent notes, and a structural defect in `agentic-frameworks-moc.md`.
- **Technical completeness:** Codex covered the documented Anthropic error surface more fully and captured higher-risk implementation details such as tool-result ordering and streaming terminal-state handling.
- **Useful Gemini additions worth preserving:**
  - `tool_choice` behavior in `anthropic-tool-use.md`
  - rate-limit response header note in `anthropic-error-handling.md`
  - prompt-caching minimum threshold and high-level cost-savings note in `anthropic-prompt-caching.md`
- **Known confound:** the original Codex handoff itself asked Codex to synthesize notes, which already departs from the stricter separation described in `01_Wiki/protocol-source-ingestion-runbook.md`

## Outcome

- Codex did in fact cross the intended role boundary from the runbook.
- That crossing was still in-scope relative to the explicit Codex handoff, so the experiment measures a real process conflict between runbook purity and task-local authorization.
- The empirical result favored the boundary-crossing Codex pass: it produced the more complete and compliant Anthropic batch.
- Canonical basis: keep the Codex output, add only the three targeted Gemini details listed above, and discard the rest of the Gemini pass after extraction.
