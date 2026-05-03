---
title: Artifact Schema Discussion (2026-05-03)
author: codex
date: 2026-05-03
status: active
type: fleeting
aliases:
  - artifact-schema-debate
  - frontmatter-schema-discussion
  - note-dimensions-discussion
---

# Artifact Schema Discussion

This document is a turn-based discussion artifact for pressure-testing the vault's artifact schema.

The goal is to explore which note dimensions are genuinely load-bearing, which should be explicit in frontmatter, which should be derived or generated, and how the vault should think about `type`, `status`, `role`, and any other candidate axes.

This is not yet a final spec. It is a structured discussion surface.

## Core Question

Do not assume `type`, `status`, and `role` are the only meaningful axes.

Ask instead:

- What are the most real note dimensions that emerge from actual use?
- Which dimensions are discovered through repeated failure modes versus merely chosen by convention?
- Which dimensions belong in frontmatter because they sit on the golden path between human composability and machine computability?
- Which dimensions are real but should instead be derived, inferred, or stored in database/generated state?

## Current Candidate Dimensions

- identity
- kind
- lifecycle
- function
- provenance
- scope
- trust

## Current Candidate Frontmatter Core

- `title`
- `aliases`
- `type`
- `status`
- `author`
- `date`
- maybe `role`

## Desired Output

We want:

1. the smallest defensible set of frontmatter fields
2. the strongest case for any additional explicit field
3. the strongest case against schema inflation
4. examples from the vault where the current model breaks down
5. a recommendation for what should live in frontmatter versus database state versus generated views

## Discussion Protocol

This document is append-only during the discussion.

Rules:

1. Agents read the whole document before appending.
2. Agents do not rewrite earlier turns.
3. Each turn is appended under a new heading using the exact format:
   `## Turn N — [AgentName]`
4. Each turn should include these subheadings:
   - `### Claims`
   - `### Challenges`
   - `### Proposed Distinctions`
   - `### Open Questions`
5. Use real vault examples where possible.
6. Push against the current framing where needed. Agreement is not the goal.
7. Avoid bloated prose. Favor sharp distinctions and concrete examples.

## Turn Instructions

When it is your turn:

1. Read the current document.
2. Append one new turn only.
3. Do not resolve the whole debate by yourself.
4. Respond to prior turns where relevant, but add genuinely new pressure.
5. If you think a dimension is derivative rather than primary, say so explicitly.
6. If you think a field belongs in frontmatter, justify why human authors will actually maintain it correctly.
7. If you think a field belongs outside frontmatter, name the better layer: database state, generated view, note body, or inferred metadata.

## Suggested Turn Count

Default structure:

- Turn 1: Codex seed
- Turn 2: Claude response
- Turn 3: Gemini response
- Turn 4: Codex synthesis / challenge
- Turn 5: Claude or Gemini follow-up
- Final appended summary after the discussion reaches diminishing returns

This can be shortened or extended by HITL.

## Final Summary Protocol

When the discussion is complete, append:

`## Summary — [AgentName or Human]`

Include:

- `### Stable Agreements`
- `### Live Disagreements`
- `### Recommended Schema Direction`
- `### Fields To Keep Explicit`
- `### Fields To Derive Or Relocate`

## Seed Position

My starting position is:

- the most plausible deep dimensions are identity, kind, lifecycle, function, provenance, scope, and trust
- not all of those belong in frontmatter
- the strongest current frontmatter core is still `title`, `aliases`, `type`, `status`, `author`, and `date`
- `role` is the most promising next explicit field because it answers a different question than `type` or `status`
- the biggest design risk is conflating epistemic kind, operational function, and lifecycle in one field

## Turn 1 — Codex

### Claims

- `type` is currently overloaded. It mixes epistemic class (`permanent`, `literature`), operational artifact (`handoff`), and publication family (`spec`, `community`).
- `status` is also overloaded. It partly describes maturity, partly completion, and partly retirement condition.
- `role` is promising because it answers "what is this artifact doing?" rather than "what kind of artifact is this?"
- A frontmatter field is only good if humans can apply it consistently without frequent repair passes.

### Challenges

- `literature` and `permanent` are both durable and load-bearing in practice, which suggests durability alone is not a useful discriminator.
- `handoff` may not belong as a top-level `type` at all; it may be an operational role of a fleeting note.
- The vault's internal docs and validators are not yet aligned, so any schema theory that ignores actual practice is suspect.

### Proposed Distinctions

- `type` should probably answer: what family of artifact is this?
- `status` should probably answer: where is it in its lifecycle?
- `role` should probably answer: what job is it doing in the workflow or graph?
- Many other useful dimensions may be real but should remain outside frontmatter unless they are both stable and human-maintainable.

### Open Questions

- Is `literature` a durable epistemic kind, or really a source-orientation that could be represented some other way?
- Should `handoff` remain a `type`, or become a `role` on a fleeting / process artifact?
- Which current fields are truly on the golden path of both human usability and machine computability?
