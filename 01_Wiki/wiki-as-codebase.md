---
title: Wiki as Codebase
author: claude-sonnet-4-6
date: 2026-04-25
status: active
type: permanent
aliases: [ide-metaphor, wiki-engineering]
---
# Wiki as Codebase

The personal knowledge base is a software project. This is not metaphor — it is an architectural claim with engineering implications. Every component of a mature software development workflow has a direct analogue in the [[llm-wiki-pattern]], and mapping these analogues reveals what a knowledge system must have to be rigorous rather than merely organized.

## The Role Map

- **The Wiki** = the codebase: a structured, interlinked collection of logic expressed in a formal notation (Markdown + YANP frontmatter).
- **Obsidian** = the IDE: the environment for navigating, searching, and debugging the knowledge graph.
- **The LLM** = the programmer: the agent responsible for writing, refactoring, and maintaining the notes.
- **The Human** = the architect: sets vision, curates sources (requirements), reviews changes, and gates deployments to `main`.
- **Git** = version control: tracks every mutation, enables rollback, and enforces the Git Invariant on all agent writes.

## The Compilation Model

`generate-wiki.ps1` is a compiler. This is literal, not figurative.

It takes markdown source files (`.md`) as input — the "source code" — and produces HTML artifacts (`.html`) as output — the "compiled binary." During this process it:

1. Parses YANP frontmatter (type-checking the metadata schema).
2. Resolves wikilinks to valid targets (link validation = symbol resolution at link-time).
3. Injects graph neighbor data from the PoShWiKi SQLite database (an enrichment pass over the compiled object).
4. Renders against `template.html` (linking against a standard library).

The output portal at `03_Web/public/` is the **build artifact**. Editing the HTML directly is like editing a compiled binary — possible in principle, immediately overwritten on the next build. The source of truth is the markdown. Everything else is derived.

This framing has a practical consequence: if the portal looks wrong, the fix lives in the source files or the compiler, never in the output. Debugging the artifact rather than the source is a category error.

## The Type System

YANP frontmatter is a type system for knowledge. Every note has a declared type:

- `permanent` — a settled conclusion, load-bearing for other notes. Claims here are defended and cross-referenced.
- `literature` — a processed summary of an external source. Attribution matters; originality is not the goal.
- `fleeting` — a transient capture, expected to be promoted or discarded. Not load-bearing.
- `moc` — Map of Content: a structural index, not a knowledge claim. Its job is navigation, not argument.

Writing a `moc` note that makes original arguments is a **type error**. Writing a `permanent` note that merely lists external links without synthesis is a **type error**. The type system encodes epistemic intent and enforces it at lint time.

The `status` field adds a lifecycle dimension: `raw` → `draft` → `active` → `archived`. An LLM can synthesize a `raw` source into a `draft`; the human validates and promotes to `active`. This is exactly a pull request workflow: the agent proposes, the architect approves.

## CI/CD for Knowledge

`run-maintenance.ps1` is the build pipeline — the CI/CD system for the knowledge base. On every vault change (via the `watch-wiki.ps1` daemon) and on every GitHub Actions deployment run, it executes:

1. **`audit-yanp.ps1`** — the linter. Checks for missing frontmatter fields, invalid type values, non-kebab-case filenames. A note with a broken schema is a compile error.
2. **`check-broken-links.ps1`** — the type-checker. A wikilink to a non-existent note is a dangling pointer — a runtime error caught at build time.
3. **`orphan-check.ps1`** — the dead-code detector. A note with no inbound links is unreachable from the graph. May be valid; flagged as a warning.
4. **`sync-vault-graph.ps1`** — the dependency resolver. Writes the relational graph to SQLite, making the implicit link structure queryable and exposing circular dependencies.
5. **`generate-wiki.ps1`** — the compiler. Produces the static HTML portal from markdown source.
6. **`generate-dashboard.ps1`** — the coverage report. Visualizes vault health metrics, link density, and graph topology.

The vault has a **green build** or it does not ship. Entropy is treated as a test failure, not a cosmetic issue.

## Refactoring as Epistemic Discipline

Good code does not accumulate — it refactors. The same discipline applies to knowledge.

The pathological end-state of a knowledge base is the "Digital Junk Drawer": an ever-growing collection of notes with no pruning, no consolidation, and no structural improvement. It grows in volume while shrinking in utility. Retrieval becomes harder as the signal-to-noise ratio degrades.

The wiki-as-codebase metaphor enforces the refactoring instinct:

- **Split** an over-large note that covers two distinct concepts (a function doing too much — violating single responsibility).
- **Merge** two notes that have drifted toward redundancy (duplicate code paths — DRY violation).
- **Rename** a note when understanding of the concept has matured (renaming a variable when its purpose becomes clear after deeper use).
- **Delete** a note that was speculative and has been superseded (dead code removal — it occupies graph space without contributing to traversals).

Refactoring the knowledge base is not housekeeping. It is active synthesis. The act of deciding that two notes should merge forces the question of what they have in common — which is itself a knowledge claim.

## The Pull Request as Human Gate

The LLM does not have unilateral commit rights to `main`. Significant batches of agent-written notes are produced on a branch. The human reviews the diff. Merging to `main` is the final validation step — the moment the human architect endorses the agent programmer's work.

This mirrors the PR workflow deliberately. It encodes the principle that the **human is the final arbiter** of what is promoted to permanent knowledge. The agent proposes; the architect approves. The [[yanp-for-agentic-workflows|YANP `status` field]] makes this workflow machine-readable: `draft` notes are pending review; `active` notes have passed it.

## See Also
- [[llm-wiki-pattern]]
- [[wiki-pattern-operations]]
- [[yanp-for-agentic-workflows]]
- [[the-compounding-artifact]]
- [[plain-plus-design]]
- [[vulture-nest]]
