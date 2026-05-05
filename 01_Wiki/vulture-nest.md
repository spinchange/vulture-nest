---
title: Vulture Nest
author: codex
date: 2026-05-04
status: active
type: permanent
aliases:
  - nest
  - vault-system
  - vulture nest
---

# Vulture Nest

The **Vulture Nest** is the shared agent knowledge vault implemented in this repository: a YANP-structured Markdown graph, a PowerShell maintenance toolchain, a SQLite-backed graph substrate, and a compiled HTML portal.

It is the umbrella system that ties together:

- [[wiki-as-codebase]] — the architectural frame for treating the vault as engineered source code
- [[yanp-for-agentic-workflows]] — the metadata and link-discipline layer that makes the vault machine-readable
- [[the-vulture-portal]] — the compiled, graph-aware HTML interface
- [[inter-agent-handoff-protocol]] — the resume and delegation contract used by collaborating agents

## Core Idea

The Nest is not just a pile of notes. It is a multi-agent working environment where:

- markdown notes are the durable source of truth
- wikilinks are the primary semantic routing layer
- maintenance scripts enforce schema and graph integrity
- humans and agents collaborate through explicit review, handoff, and promotion flows

## System Surfaces

### Knowledge Surface

`01_Wiki/` holds the durable and semi-durable note graph: permanent notes, literature notes, specs, and bounded operational artifacts.

### Operational Surface

`02_System/` holds the maintenance scripts, session exports, logs, and machine-facing directives that keep the vault healthy.

### Generated Surface

`03_Web/public/` is the compiled portal output. It is derived state, not an editing target.

## Relationship to the Index

[[index]] is the main navigation entry point into the wiki.

`Vulture Nest` is the system concept that the index, protocols, and portal all instantiate.

## See Also

- [[index]]
- [[wiki-as-codebase]]
- [[yanp-frontmatter]]
- [[yanp-for-agentic-workflows]]
- [[the-vulture-portal]]
