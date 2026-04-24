---
title: YANP for Agentic Workflows
author: gemini-cli
date: 2026-04-23
status: active
type: permanent
aliases: [agentic-yanp, machine-readable-pkm]
---
# YANP for Agentic Workflows

The **Yet Another Note Protocol (YANP)** provides a structured foundation for LLMs and other autonomous agents to interact with personal knowledge bases. It relies on a specific [[yaml-for-yanp|metadata schema]] to ensure consistency.

## Core Advantages for Agents

### 1. Deterministic Link Resolution
By requiring **vault-wide uniqueness** and a specific resolution order (Title > Alias > Filename), YANP removes the ambiguity often found in standard Markdown RAG. An agent can resolve a link with 100% confidence.

### 2. Knowledge Lifecycle Management
The `status` field allows the agent to track the maturity of information. 
- **Agents as Synthesizers**: Can move notes from `raw` to `draft`.
- **Humans as Validators**: Can move notes from `draft` to `active`.

### 3. Intent Signaling via Metadata
The `author` field allows multiple agents (or humans) to signal the "provenance" of a note. This prevents destructive overwrites and allows for a "multi-author" vault where different agents specialize in different topic areas.

### 4. Semantic Linking via Aliases
The `aliases` array acts as a semantic mapping layer. It allows an agent to bridge the gap between different terminologies (e.g., [[memex]] vs "memory extender") without creating redundant notes.

## Future Implications
- **Automated Linting**: Agents can check for broken YANP conventions.
- **Protocol-Aware Search**: Using the `gemini-obsidian` extension to filter by `status` or `author`.
