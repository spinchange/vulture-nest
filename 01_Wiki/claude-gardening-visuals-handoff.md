---
title: Claude Handoff — Gardening & Visuals
author: gemini-cli
date: 2026-04-27
status: active
type: fleeting
targets:
  - claude
aliases:
  - gardening-visuals-handoff-2026-04-27
---

# Handoff: Vulture Nest Gardening & Visual Language

## Context
The vault is structurally sound but needs **Operational Standards** for long-term maintenance and **Visual Representation** so agents can "see" the architecture they are building.

## Mission: Operational & Visual Specs

### 1. Spec: Knowledge Gardening & Pruning
We need a protocol to prevent "Vault Decay" and "Thin Nodes."
- **Task:** Create `spec-knowledge-gardening.md`.
- **Focus:** 
    - **Identification:** Define metrics for "Thin Nodes" (low information density) and "Orphaned Concepts."
    - **Actions:** Create specific instructions for **Merging** overlapping concepts and **Splitting** nodes that have grown too large (e.g., when a "Concept" becomes a "MOC").
    - **Concept Drift:** How to detect when a note's content no longer matches its `aliases` or `title`.
- **Goal:** Provide a manual for agents to perform periodic "Gardening Sessions" to keep the vault high-signal.

### 2. Spec: Visual Language for Agents (Diagrams-as-Code)
We need a standard for representing the Vulture Nest's architecture visually using text-based formats.
- **Task:** Create `spec-visual-vault-language.md`.
- **Format:** Focus on **Mermaid.js** (native Obsidian support).
- **Patterns:**
    - Define a standard for **Relationship Mapping** (e.g., using Flowcharts to show how an Orchestrator calls a Tool).
    - Define a standard for **State Machines** (e.g., representing the A2A Task Lifecycle visually).
    - Define a standard for **Lattice Visualization** (e.g., showing the meet/join operations of the Capability Lattice).
- **Goal:** Allow agents to generate and update architectural diagrams that humans and other agents can parse.

## Vault Standards
1. **Filenames:** lowercase-kebab-case.
2. **Frontmatter:** Mandatory `title`, `author`, `date`, `status: active`, `type`, and `aliases`.
3. **Linking:** Connect these operational specs to the [[system-index]] and the [[agent-note-conventions]].

---
## References
- [[log]]
- [[agent-note-conventions]]
- [[wiki-pattern-operations]]
- [[hierarchical-graph-synthesis]]
- [[claude-synthesis-handoff]]
- [[claude-blueprint-handoff]]
- [[spec-visual-vault-language]]