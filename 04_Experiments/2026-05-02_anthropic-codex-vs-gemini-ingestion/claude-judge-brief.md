# Claude Judge Brief

You are the evaluator for an experiment comparing two independent executions of the same Anthropic documentation-ingestion task.

## Goal

Inspect both worktrees and judge:

1. which output is stronger overall
2. whether Codex materially crossed the intended role boundary
3. whether Gemini's rerun produced a meaningfully better result or just a differently shaped one

## Worktrees

- **Codex baseline worktree:** `C:\Users\executor\Documents\vulture-nest`
- **Gemini clean rerun worktree:** `C:\Users\executor\Documents\vulture-nest\.tmp\gemini-anthropic-compare`

## Primary context files

In the Codex baseline worktree:

- `01_Wiki/codex-anthropic-docs-ingestion-handoff-2026-05-02.md`
- `01_Wiki/gemini-anthropic-docs-ingestion-handoff-2026-05-02.md`
- `01_Wiki/protocol-source-ingestion-runbook.md`
- `04_Experiments/2026-05-02_anthropic-codex-vs-gemini-ingestion/entry.md`
- `04_Experiments/2026-05-02_anthropic-codex-vs-gemini-ingestion/gemini-brief.md`
- `04_Experiments/2026-05-02_anthropic-codex-vs-gemini-ingestion/artifacts/codex-worktree/`

## Scope to inspect

Focus on the Anthropic ingestion lane only:

- `00_Raw/anthropic/`
- `01_Wiki/lit-anthropic-messages-api.md`
- `01_Wiki/anthropic-messages-api.md`
- `01_Wiki/anthropic-tool-use.md`
- `01_Wiki/anthropic-streaming-patterns.md`
- `01_Wiki/anthropic-error-handling.md`
- `01_Wiki/anthropic-prompt-caching.md`
- any edits to:
  - `01_Wiki/index.md`
  - `01_Wiki/agentic-frameworks-moc.md`
  - `01_Wiki/agent-tools.md`
  - `01_Wiki/function-calling.md`

## Evaluation criteria

Judge both worktrees on:

1. **Role adherence**
   - Did the agent stay inside the intended split between ingestion, synthesis, and graph integration?
   - If not, was the boundary-crossing harmful, neutral, or useful?

2. **Scope discipline**
   - Did the output stay bounded to the requested Anthropic API fundamentals?
   - Did either agent broaden the batch beyond the evidence?

3. **Source handling**
   - Is the raw corpus attributable, narrow, and operationally useful?
   - Did the note set preserve concrete provider-specific behaviors?

4. **Synthesis quality**
   - Are the literature and permanent notes implementation-facing?
   - Do they distinguish documented Anthropic behavior from local recommendation or inference?

5. **Graph integration quality**
   - Are the MOC/index/tooling note edits minimal and high-signal?
   - Did either agent make noisy or unnecessary graph edits?

6. **Verification**
   - Check whether `audit-yanp.ps1` and `check-broken-links.ps1` passed in each worktree.
   - Treat clean verification as necessary but not sufficient.

## Deliverable format

Produce a concise judgment with:

1. **Verdict**
   - one paragraph naming the stronger output and why

2. **Findings**
   - ordered by severity
   - include concrete file references

3. **Boundary judgment**
   - explicit answer on whether Codex did Gemini's task, or a Gemini/Claude-combined task, or something else

4. **Comparison summary**
   - what Codex did better
   - what Gemini did better
   - what was materially different vs. merely stylistic

5. **Final recommendation**
   - which output should be kept as the canonical basis, or whether the best result is a merge of both

## Important constraint

Do not rewrite the notes. This is an evaluation pass, not an editing pass.
