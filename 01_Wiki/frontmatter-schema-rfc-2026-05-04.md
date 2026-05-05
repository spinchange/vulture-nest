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

Make the smallest useful improvements to the current frontmatter contract while preserving the live vault's working note ecology.

Specifically:

- keep `type` and `status`
- preserve the working `literature`, `permanent`, and `fleeting` distinctions
- standardize `author` as a list
- standardize `sources` as a list when present
- avoid disruptive renames until a real migration need is proven

## Why This RFC Exists

The current frontmatter model mixes multiple axes into too few fields.

In practice:

- `type` mixes epistemic class, artifact family, and workflow intent
- `status` mixes lifecycle, maturity, retirement, and completion signals
- `author` compresses collaborative provenance into one scalar
- source citation exists, but its shape has drifted across notes

The Nest is now large enough that this drift is worth correcting, but the existing `type` vocabulary is also visibly load-bearing in practice. The safest path is to fix the fields that are structurally wrong without renaming the ones the vault already relies on.

## Working Model

This RFC proposes a three-layer model:

### 1. Frontmatter

Authored, coarse classification and provenance.

### 2. Note Body

Authored, note-specific structure such as findings, evidence, claims, review notes, or resolution logs.

### 3. Database / Generated Views

Computed or index-oriented properties such as graph centrality, hub-ness, link counts, source joins, crawl metadata, and derived trust signals.

This RFC only specifies layer 1.

## Proposed Field Changes

### Keep `type`

Do not rename `type` at this stage.

The vault already contains a large, meaningful population of `literature`, `permanent`, and `fleeting` notes. That distinction is not merely theoretical; it is visible in routing, synthesis, and actual agent behavior. Renaming `type` now would create migration cost without a proportionate gain.

### Keep `status`

Do not rename `status` at this stage.

The field is imperfect, but it is already part of the operating language of the vault. The conservative move is to tighten its written meaning later, not replace it immediately.

### `author` stays `author`, but becomes list-shaped

The current `author` field collapses collaborative provenance into one scalar.

The Nest is already multi-agent and occasionally multi-human. The lowest-risk fix is:

- keep the field name `author`
- require YAML list shape
- allow single-item lists for singly-authored notes

This solves the real structural problem without introducing a broader provenance redesign.

### `source` / `source_url` / variants -> `sources`

Source grounding should remain separate from authorship provenance.

The outer shape should be stabilized now:

- `sources` MUST be a list

The inner object shape can remain permissive for now.

## Proposed Core Schema

### Required

- `title`
- `date`
- `type`
- `status`
- `author`

### Strongly Recommended

- `aliases`

### Conditional

- `sources`
  Required for source-grounded notes and any note whose claims materially depend on external sources.

## Proposed Meanings

### `type`

Keep the current field and vocabulary for now, especially the core working set:

- `literature`
- `permanent`
- `fleeting`

Other live values may still need later cleanup, but that is a separate question from this RFC's conservative amendment.

### `status`

Keep the current field.

This RFC does not settle the complete vocabulary beyond preserving the existing contract.

### `author`

`author` MUST be a YAML list.

Examples:

```yaml
author:
  - gemini-cli
```

```yaml
author:
  - executor
  - codex
```

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

### Literature Note

```yaml
---
title: Literature: OpenAI Symphony Service Specification
date: 2026-05-04
type: literature
status: active
author:
  - executor
  - claude-sonnet-4-6
  - codex
sources:
  - title: OpenAI Symphony announcement
    url: https://openai.com/index/open-source-codex-orchestration-symphony/
  - title: openai/symphony SPEC.md
    url: https://github.com/openai/symphony/blob/main/SPEC.md
---
```

### Permanent Note

```yaml
---
title: OpenAI Symphony
date: 2026-05-04
type: permanent
status: active
author:
  - executor
  - gemini-cli
aliases:
  - symphony
sources:
  - 01_Wiki/lit-openai-symphony-spec.md
---
```

### Handoff Note

```yaml
---
title: Claude OpenAI Symphony Synthesis Handoff
date: 2026-05-04
type: handoff
status: archived
author:
  - executor
  - claude-sonnet-4-6
  - codex
sources:
  - 01_Wiki/lit-openai-symphony-spec.md
---
```

## What This RFC Does Not Settle

- whether `type` should later be narrowed to a stricter closed set
- whether `status` needs a sharper documented vocabulary
- whether `author` should eventually split into more granular provenance fields
- whether some notes should support additional specialized fields beyond this core

## Migration Direction

This RFC does not require immediate vault-wide migration beyond shape normalization for the amended fields.

The intended order is:

1. treat the current YANP baseline as canonical
2. normalize `author` to YAML-list shape
3. normalize `sources` to YAML-list shape when present
4. revise validators and writing guidance only for those changes
5. defer broader naming or taxonomy changes unless the live vault proves they are necessary

## Review Questions

Please pressure-test this against the actual Nest, not schema theory alone.

Questions:

1. Are `author` and `sources` the only frontmatter changes we can justify right now without harming the existing vault ecology?
2. Which real notes become easier to model once `author` is list-shaped?
3. Is requiring `sources` as a list the right level of stabilization right now?
4. Should `sources` remain optional on permanent notes that synthesize from vault-internal literature rather than direct external inputs?
5. What should remain in note body structure or Supabase/index state rather than frontmatter?

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
