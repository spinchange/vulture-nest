---
title: Agent Knowledge Vault
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [shared-agent-memory, model-agnostic-knowledge]
---
# Agent Knowledge Vault

An **Agent Knowledge Vault** is a shared, model-agnostic knowledge base built on plain Markdown (specifically [[yanp-for-agentic-workflows]]) that allows humans and multiple AI agents (Claude, Gemini, etc.) to collaborate on a single knowledge graph.

## The Problem of Siloed Memory
Most agent memory systems are fragmented and specific to a single provider or tool. This vault acts as a layer above them, providing a unified space for:
* User preferences and workflow standards.
* Project state and design rationale.
* Cross-session continuity.
* Operational conventions.

## Core Pillars
1. **Interoperability**: Built on standard Markdown and Git to ensure any tool can read/write.
2. **Provenance**: Clear metadata (`author`, `hostname`, `date`) to track who wrote what and where.
3. **Auditability**: Using Git for version control and rollbacks.
4. **Graph-Based**: Using `[[the-compounding-artifact|Wikilinks]]` to create a dense web of information rather than isolated files.

## Operational Standards
The vault relies on strict adherence to [[agent-note-conventions]] to prevent drift and ensure that machine-parsable metadata remains consistent over time.

---
## References
* Source: `00_Raw/agent-knowledge-vault.md`
* [[core-patterns-moc]]
* [[wiki-as-codebase]]
* [[agent-note-conventions]]
