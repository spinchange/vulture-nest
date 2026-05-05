---
title: RFC — Frontmatter Schema Refresh
author: codex
date: 2026-05-04
status: active
type: fleeting
aliases:
  - frontmatter-schema-rfc
  - kind-phase-rfc
  - note-frontmatter-refresh
---

# RFC — Frontmatter Schema Refresh

This RFC proposes a narrower refresh of the Nest's note frontmatter.

It does not attempt to solve the full write protocol. It only addresses the frontmatter layer for `01_Wiki/` notes.

## Objective

Replace the current overloaded frontmatter language with a cleaner, more honest schema that:

- separates note kind from temporal standing
- separates authorship provenance from source citation
- stays permissive where the vault is still learning
- remains simple enough for humans and agents to maintain

## Why This RFC Exists

The current frontmatter model mixes multiple axes into too few fields.

In practice:

- `type` mixes epistemic class, artifact family, and workflow intent
- `status` mixes lifecycle, maturity, retirement, and completion signals
- `author` compresses human and model provenance into one field
- source citation exists, but its shape has drifted across notes

The Nest is now large enough that this drift is worth correcting.

## Working Model

This RFC proposes a three-layer model:

### 1. Frontmatter

Authored, coarse classification and provenance.

### 2. Note Body

Authored, note-specific structure such as findings, evidence, claims, review notes, or resolution logs.

### 3. Database / Generated Views

Computed or index-oriented properties such as graph centrality, hub-ness, link counts, source joins, crawl metadata, and derived trust signals.

This RFC only specifies layer 1.

## Proposed Field Shifts

### `type` -> `kind`

The current `type` field name is overloaded by YAML language itself and by the vault's own mixed use of note categories.

`kind` is a better name for coarse artifact classification.

### `status` -> `phase`

The current `status` field is trying to express temporal standing.

`phase` is a better name for that axis in YAML than `status`, and less misleading than `lifecycle`.

### `author` -> `users` and `models`

The current `author` field collapses human and model provenance.

The Nest is now multi-human and multi-model enough that this should be split.

### `source` / `source_url` / variants -> `sources`

Source grounding should remain separate from authorship provenance.

The outer shape should be stabilized now:

- `sources` MUST be a list

The inner object shape can remain permissive for now.

## Proposed Core Schema

### Required

- `title`
- `date`
- `kind`
- `phase`

### Strongly Recommended

- `aliases`
- `users`
- `models`

### Conditional

- `sources`
  Required for documentary notes and any note whose claims materially depend on external sources.

## Proposed Meanings

### `kind`

What the note is primarily about right now.

Candidate values:

- `documentary`
- `conceptual`
- `operational`

Working distinction:

- `documentary` = primarily about someone else's artifact, text, repo, spec, corpus, or claim-world
- `conceptual` = primarily about the vault's own synthesis, model, distinction, protocol, or idea
- `operational` = primarily about doing, coordinating, handing off, reviewing, planning, or resuming work

### `phase`

How the note stands in time.

`phase` should be permissive for now and MAY be scalar or list-shaped.

Examples:

- `active`
- `fleeting`
- `archived`
- `superseded`
- `dormant`
- combinations where needed

This RFC does not freeze the final phase vocabulary.

### `users`

Humans who materially directed, owned, or shaped the artifact.

`users` SHOULD be a list.

### `models`

Models that materially contributed to the artifact's current form.

`models` SHOULD be a list.

### `sources`

External grounding for the note.

`sources` MUST be a list.

The vault does not yet need to freeze the item schema beyond that requirement.

Examples:

```yaml
sources:
  - https://example.com
```

```yaml
sources:
  - title: Symphony announcement
    url: https://openai.com/index/open-source-codex-orchestration-symphony/
```

## Example Shapes

### Documentary Note

```yaml
---
title: Literature: OpenAI Symphony Service Specification
date: 2026-05-04
kind: documentary
phase:
  - active
users:
  - executor
models:
  - claude-sonnet-4-6
  - codex
sources:
  - title: OpenAI Symphony announcement
    url: https://openai.com/index/open-source-codex-orchestration-symphony/
  - title: openai/symphony SPEC.md
    url: https://github.com/openai/symphony/blob/main/SPEC.md
---
```

### Conceptual Note

```yaml
---
title: OpenAI Symphony
date: 2026-05-04
kind: conceptual
phase:
  - active
users:
  - executor
models:
  - gemini-cli
aliases:
  - symphony
---
```

### Operational Note

```yaml
---
title: Claude OpenAI Symphony Synthesis Handoff
date: 2026-05-04
kind: operational
phase:
  - fleeting
  - archived
users:
  - executor
models:
  - codex
sources:
  - 01_Wiki/lit-openai-symphony-spec.md
---
```

## What This RFC Does Not Settle

- the final closed vocabulary for `phase`
- whether `phase` should eventually be list-only
- whether `documentary` is the final best word, even if it is currently the strongest candidate
- migration mechanics from `type` / `status` / `author`
- whether some notes should support additional specialized fields beyond this core

## Migration Direction

This RFC does not require immediate vault-wide migration.

The intended order is:

1. pressure-test the proposed schema against real notes
2. identify failure cases and mixed cases
3. revise the RFC if needed
4. only then define migration and validator changes

## Review Questions

Please pressure-test this against the actual Nest, not schema theory alone.

Questions:

1. Does `kind = documentary | conceptual | operational` fit the real note population?
2. Which existing notes fail or blur under that split?
3. Is `phase` the right field name and is list-shaped permissiveness acceptable for now?
4. Are `users` and `models` enough to replace `author` at the coarse frontmatter layer?
5. Is requiring `sources` as a list the right level of stabilization right now?
6. What should remain in note body structure or Supabase/index state rather than frontmatter?

## Feedback Protocol

Append feedback under a new heading:

`## Review — [AgentName or Human]`

Use these subheadings:

- `### Agreements`
- `### Breakpoints`
- `### Suggested Revisions`
- `### Open Questions`

Keep the focus on:

- real-note fit
- schema simplicity
- migration pain
- automation consequences
