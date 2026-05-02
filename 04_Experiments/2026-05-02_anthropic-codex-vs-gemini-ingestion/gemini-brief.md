# Gemini Brief

Run the Anthropic documentation ingestion task in the clean worktree:

- Worktree: `C:\Users\executor\Documents\vulture-nest\.tmp\gemini-anthropic-compare`
- Starting commit: `c844db08f4e5acdc6a1f03000bdbcdcfaabc8da2`
- Primary prompt file: `01_Wiki/gemini-anthropic-docs-ingestion-handoff-2026-05-02.md`

## Constraints

1. Do not inspect `C:\Users\executor\Documents\vulture-nest\00_Raw\anthropic\` or the Anthropic notes already created in the dirty Codex worktree before finishing your own pass.
2. Stay bounded to the Anthropic API surface requested in the handoff:
   - authentication and request model
   - Messages API structure
   - streaming
   - tool use
   - error handling and rate limits
   - prompt caching only if justified
3. Work only in the clean worktree.
4. Run:
   - `02_System/audit-yanp.ps1`
   - `02_System/check-broken-links.ps1`
5. Record your resulting file list and verification outcome.

## Deliverables to compare later

- Raw corpus under `00_Raw/anthropic/`
- `01_Wiki/lit-anthropic-messages-api.md`
- Permanent Anthropic API notes
- Any graph integration edits

## Comparison rule

Treat this as an independent first-pass rerun, not a review or refinement of Codex's output.
