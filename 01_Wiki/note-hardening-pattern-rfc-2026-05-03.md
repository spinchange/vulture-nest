---
title: RFC — Note Hardening Pattern
author: codex
date: 2026-05-03
status: active
type: fleeting
aliases:
  - note-hardening-rfc
  - hub-hardening-rfc
  - collaborative-hardening-spec-seed
---

# RFC — Note Hardening Pattern

This RFC is a seed document for formalizing the pattern the vault has been using to turn thin but central notes into durable routing surfaces. It is not the final spec. Its job is to expose the current house style, the open questions around it, and the merge discipline for collaborative review.

## Objective

Produce a vault-representative spec for note hardening that captures how thin but important notes should be strengthened without losing graph shape, overwriting useful existing content, or drifting into generic essay-writing.

The target is a durable pattern that explains:

- what kind of note should be hardened
- what the hardened note must do
- what kinds of edits are in-bounds vs. out-of-bounds
- how collaborative review on the pattern should be mediated

## Why This RFC Exists

The vault now has a visible house style across notes like [[rust]], [[python]], [[powershell]], [[typescript]], [[graph-orchestration]], [[code-agents]], and [[agent-development-kit]]. Those notes were not merely expanded. They were turned into routing surfaces.

That pattern is real and repeatable, but it is not yet explicitly specified.

## Working Thesis

The note-hardening pattern is not "add more text." It is:

1. preserve useful existing framing
2. add vault-local role and decision logic
3. make the note route readers into the right nearby notes
4. clarify relationship to adjacent clusters and architectural layers
5. avoid turning the note into a bloated survey

## Proposed Scope

This pattern applies primarily to:

- root notes with high centrality but low routing value
- MOCs that act like link lists instead of navigational hubs
- execution or protocol notes that are conceptually important but operationally thin

This pattern does not automatically apply to:

- literature notes whose main job is source-grounded summarization
- narrow leaf notes that do not need to route readers elsewhere
- archival or fleeting handoff artifacts

## Draft Pattern

### 1. Preserve What Already Works

Do not rewrite a note from scratch unless the existing frame is actively wrong. Keep valid framing, links, and useful language where possible.

### 2. Add Vault-Local Framing

A hardened note should answer: why does this concept matter in the Vulture Nest specifically?

This usually means adding a section such as:

- `## Core Opinion`
- vault-local role
- architectural placement
- practical split against adjacent concepts

### 3. Add a Decision Rule

A hardened note should help the reader decide when to start there versus somewhere nearby.

This usually means adding:

- `## Decision Rule`
- "start here when your question sounds like..."
- explicit redirection to adjacent notes when the question belongs elsewhere

### 4. Add Route Selection

A hardened note should guide movement through its cluster rather than merely listing links.

This usually means adding:

- grouped reading paths
- `## Start Here`
- track-based navigation such as fundamentals / applications / theory / operations

### 5. Clarify Relationships

A hardened note should name its relationship to neighboring layers rather than assuming the graph will make that obvious.

This usually means adding:

- `## Relationship to the Rest of the Vault`
- explicit contrast with nearby frameworks, languages, or protocol layers

### 6. Stay Bounded

Hardening is not full-cluster synthesis.

Out of bounds unless explicitly requested:

- spawning many new notes
- broad research or ingestion
- replacing several nearby notes instead of strengthening one hub
- writing a mini-book inside the root note

## Draft Structural Expectations

A hardened note does not require identical section names every time, but it should usually end up with most of these functions:

- vault-local framing
- decision rule
- route selection / start-here guidance
- relationship mapping
- concise references or see-also closure

## Candidate Review Questions

These are the questions I recommend sending to Claude and Gemini:

1. Does this RFC accurately describe the pattern already visible in the vault, or is it overfitting to a few recent passes?
2. Which required function is missing, overstated, or incorrectly scoped?
3. Should this pattern treat permanent root notes, MOCs, and execution-pattern notes as one family or as separate hardening modes?
4. What is the clearest stop condition for a hardening pass so it does not sprawl into general expansion?
5. Which existing note is the best positive example, and which existing note would be a counterexample where this pattern should not be applied?

## Suggested Collaboration Model

This RFC assumes a HITL-mediated review flow.

Acceptable model:

1. Codex authors the seed RFC.
2. Claude and Gemini read the seed.
3. They append bounded feedback to a shared review surface or separate review artifacts.
4. HITL and Codex mediate the merge into a revised draft.
5. Only after mediation does a new draft overwrite or supersede the seed.

Not recommended:

- multiple agents editing the spec text concurrently without review boundaries
- free-form rewrites that mix review, resolution, and authorship in one pass
- using comments that do not distinguish findings from proposed text

## Suggested Merge Protocol

### Rule 1: Separate Draft From Review

The RFC seed should remain the current draft. Reviewers should append feedback into a review lane, not rewrite the draft directly.

### Rule 2: Require Section-Scoped Feedback

Each reviewer comment should identify:

- target section
- finding type: `gap`, `overreach`, `ambiguity`, `missing-example`, `scope-risk`, or `wording`
- proposed change
- optional example note from the vault

### Rule 3: Merge By Resolution Pass

Codex performs a synthesis pass after reviews land:

- accept
- reject
- partially accept

Each decision should be justified briefly in a resolution log or revision note.

### Rule 4: Preserve Disagreement Until Resolved

If Claude and Gemini disagree materially, do not flatten the disagreement silently. Carry it into a short `Open Questions` or `Resolution Log` section until mediated.

### Rule 5: Promote Only After Convergence

Do not promote the RFC into a permanent spec until:

- reviewers agree on scope
- the stop condition is clear
- at least 2-3 example notes in the vault fit the pattern cleanly

## Proposed Review Surface

My default recommendation:

- draft note: this RFC
- review lane: a separate fleeting note such as `note-hardening-pattern-review-2026-05-03`
- merge output: either update this note in place or create `spec-note-hardening-pattern`

That keeps authorship, review, and promotion distinct.

## Open Questions

- Is "note hardening" the right durable name, or should this be framed as a hub-note or routing-surface pattern?
- Should MOCs have their own variant of the pattern instead of sharing one with root permanents?
- Should this become a permanent note under `01_Wiki/`, or a system standard under a more explicitly operational name?

## Stop Condition

This RFC is ready for external review when:

- the draft pattern is explicit enough to critique
- the review questions are stable
- the merge protocol is clear enough to keep collaboration disciplined

---

## Related

- [[language-root-hardening-plan-2026-05-02]]
- [[programming-languages-moc]]
- [[agent-development-kit]]
- [[graph-orchestration]]
- [[rust]]
- [[python]]
