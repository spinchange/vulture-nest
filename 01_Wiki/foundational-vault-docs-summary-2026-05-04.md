---
title: Foundational Vault Docs Summary
author: codex
date: 2026-05-04
status: active
type: fleeting
aliases:
  - foundational-vault-summary
  - yanp-foundations-summary
  - nest-core-docs-summary
---

# Foundational Vault Docs Summary

This note summarizes the most foundational documents currently shaping how the Nest is supposed to work.

The main set covered here is:

- [[yanp-frontmatter]]
- [[yaml-for-yanp]]
- [[yanp-for-agentic-workflows]]
- [[wiki-as-codebase]]
- [[visitor-directives]]

These do not all operate at the same level. Some are schema-facing, some are conceptual, and some are operational. Taken together, they form the nearest thing the vault currently has to a baseline constitution.

## Short Version

- [[yanp-frontmatter]] is the strongest source for the frontmatter field baseline.
- [[yaml-for-yanp]] is the syntax guide for how that frontmatter should be written.
- [[yanp-for-agentic-workflows]] explains why YANP matters for agents.
- [[wiki-as-codebase]] explains the vault as an engineering system with promotion, linting, and build logic.
- [[visitor-directives]] is the practical operating manual for agents working in the vault.

If the question is "what should frontmatter look like?", [[yanp-frontmatter]] is probably the true north.

If the question is "how should agents behave in the vault?", [[visitor-directives]] is the most direct source.

If the question is "what is the vault trying to be?", [[wiki-as-codebase]] is the strongest architectural framing.

## Document-by-Document Summary

## [[yanp-frontmatter]]

What it governs:

- the frontmatter block table
- field names
- YAML value shapes
- the baseline metadata contract

Current baseline fields:

- `tags`
- `author`
- `hostname`
- `date`
- `status`
- `title`
- `aliases`
- `priority`
- `due`
- `scheduled`
- `project`

Why it matters:

- this note is much closer to a real frontmatter spec than later discussion artifacts
- it describes frontmatter mainly as descriptive and operational metadata
- it does **not** strongly try to encode what a note *is*

Most important implication:

- the vault may have drifted into treating frontmatter as ontology when the original baseline treated it more as structured metadata

## [[yaml-for-yanp]]

What it governs:

- YAML syntax conventions
- delimiters
- indentation
- scalar vs sequence patterns
- common field examples

What it contributes:

- clarifies actual YAML value types
- distinguishes scalar fields from sequence fields
- gives practical syntax guidance for agents

Why it matters now:

- it helps separate "field meaning" from "YAML type"
- it is the cleanest reminder that `author`, `status`, and `aliases` are schema fields, while `string` and `array` are YAML/data types

## [[yanp-for-agentic-workflows]]

What it governs:

- why YANP is useful for agents
- deterministic link resolution
- metadata-assisted lifecycle handling
- provenance signaling through frontmatter

Main claims:

- unique title/alias/filename resolution removes ambiguity
- `status` supports maturity and review flow
- `author` signals provenance and discourages destructive overwrites
- `aliases` help semantic search and reuse

Why it matters:

- it is one of the strongest arguments for the vault being machine-readable by design
- it connects frontmatter to agent behavior rather than just note storage

Important caveat:

- it reflects an earlier schema worldview centered on `author` and `status`, so some of its assumptions may now be due for revision

## [[wiki-as-codebase]]

What it governs:

- the architectural metaphor of the vault
- the relationship between markdown source and generated artifacts
- the role of linting, validation, and maintenance
- the knowledge-promotion workflow

Main claims:

- the wiki is source code
- generated HTML is a compiled artifact
- maintenance scripts are CI/CD for knowledge
- note categories behave like a type system
- human review acts like a PR gate before promotion to stable knowledge

Why it matters:

- this note is probably the strongest explanation of the Nest as a rigorous system rather than a loose PKM collection
- it is where ideas like promotion, build health, linting, and graph integrity are most explicitly unified

Important caveat:

- its type/lifecycle language includes categories like `moc` and richer status progressions that are not perfectly aligned with the live validator or later practice

## [[visitor-directives]]

What it governs:

- actual agent conduct in the Nest
- what belongs in `01_Wiki/`
- what belongs in PoShWiKi
- how seams and handoffs should be recorded
- what tooling agents should use before and after writing

Main rules:

- use lowercase kebab-case filenames
- include frontmatter with required fields
- use wikilinks for vault notes
- use PoShWiKi for session tracking rather than editing wiki notes for live work
- record a seam before ending a session
- use protocol notes for richer handoffs and experiments

Why it matters:

- this is the most practical baseline for agent behavior
- it explains where process artifacts live
- it anchors the difference between durable notes and session-state tracking

Important caveat:

- its frontmatter requirements are minimal and somewhat older than current vault practice

## How These Docs Fit Together

These documents are not duplicates. They form a rough stack:

### Syntax Layer

- [[yaml-for-yanp]]

How frontmatter is physically written.

### Schema Layer

- [[yanp-frontmatter]]

What fields exist and what YAML value types they take.

### Agentic Rationale Layer

- [[yanp-for-agentic-workflows]]

Why those fields matter for agents and machine-readable workflows.

### Architectural Layer

- [[wiki-as-codebase]]

What the vault is trying to be as an engineered system.

### Operational Layer

- [[visitor-directives]]

What an agent should actually do while working in the vault.

## What Seems Stable Across All of Them

- the markdown note remains the source of truth
- YAML frontmatter is essential to the system
- aliases matter for link resolution
- status/lifecycle is meaningful
- agent behavior is supposed to be disciplined and protocol-aware
- human review remains important for durable knowledge promotion

## Where They Drift Or Conflict

- frontmatter field expectations are not perfectly aligned across all docs
- `author` is assumed throughout, but current multi-agent practice pressures that field
- `status` is described with different degrees of richness in different notes
- `wiki-as-codebase` treats note types more strongly than [[yanp-frontmatter]] does
- later vault practice introduced more note families and operational artifacts than the older frontmatter baseline anticipated

## Current Best Read

If the goal is to rethink frontmatter conservatively, the right starting sequence is:

1. [[yanp-frontmatter]]
2. [[yaml-for-yanp]]
3. [[yanp-for-agentic-workflows]]
4. [[wiki-as-codebase]]
5. [[visitor-directives]]

That order starts from the narrowest contract and expands outward toward philosophy and operations.

## Practical Implication For Current RFC Work

The recent frontmatter discussion should probably be anchored by this principle:

- treat [[yanp-frontmatter]] as the baseline contract
- treat [[yaml-for-yanp]] as the syntax constraint
- treat [[yanp-for-agentic-workflows]] and [[wiki-as-codebase]] as rationale and system framing
- treat [[visitor-directives]] as operational enforcement

That suggests frontmatter changes should be approached as conservative amendments to the existing YANP baseline, not as a total schema replacement.

## Adjacent Protocol Notes Worth Reading Next

If you want the next ring beyond the core five, the most relevant are:

- [[agent-note-conventions]]
- [[inter-agent-handoff-protocol]]
- [[experiment-capture-protocol]]
- [[protocol-source-ingestion-runbook]]
- [[spec-knowledge-gardening]]

These are less foundational to the base YANP contract, but very important to how the Nest actually runs.
