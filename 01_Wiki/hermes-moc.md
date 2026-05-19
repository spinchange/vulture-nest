---
title: Hermes Agent MOC
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-moc
  - nous-hermes-index
  - hermes-cluster
type: permanent
---
# Hermes Agent MOC

This map organizes the **Hermes Agent** cluster in the Vulture Nest. It separates Hermes into three layers: conceptual foundations, durable execution surfaces, and grounded source material.

## Start here
- [[hermes-agent]] - The top-level claim: Hermes is a persistent agent environment, not just a chat loop.
- [[lit-hermes-architecture]] - Literature synthesis of Hermes official docs across architecture, tool/runtime surfaces, and command surfaces.
- [[spec-hermes-agent-loop]] - Descriptive spec of Hermes turn execution, message alternation, tool dispatch, and persistence invariants.

## Identity, memory, and procedure
- [[hermes-bounded-memory]] - Prompt-resident hot memory paired with transcript search and optional external providers.
- [[hermes-skills-system]] - `SKILL.md` as procedural memory, progressive disclosure, and agent-maintained workflow capture.
- [[hermes-profiles]] - Long-lived identity partitions with isolated config, memory, skills, sessions, and gateway state.

## Repo-internal runtime layers
- [[hermes-provider-abstraction]] - Declarative provider profiles, api-mode transport contracts, auxiliary routing, and live model switching.
- [[hermes-prompt-assembly]] - System-prompt construction from identity, memory guidance, environment hints, skills indexes, and context files.
- [[hermes-context-compression]] - Bounded-context rollover with lineage-preserving session rotation and memory/context-engine hooks.
- [[hermes-tool-registry]] - Registry + toolset architecture that unifies built-ins, dynamic schemas, and MCP-discovered tools.

## Runtime surfaces
- [[hermes-gateway]] - Messaging daemon that exposes the same agent through Telegram, Discord, Slack, and other platforms.
- [[spec-hermes-agent-loop]] - Common execution contract shared by CLI, gateway, and cron surfaces.

## Background and multi-agent systems
- [[hermes-cron]] - Scheduled fresh-session automation, chained jobs, and script-only watchdogs.
- [[hermes-subagent-delegation]] - In-turn isolated child agents with explicit context passing and bounded autonomy.
- [[hermes-kanban]] - Durable multi-profile task board for resumable collaboration over time.

## Comparative neighbors
- [[agentic-frameworks-moc]] - Wider framework map containing Hermes, ADK, Swarm, LangGraph, and related systems.
- [[adk-moc]] - Useful contrast: toolkit/framework view rather than full agent environment.
- [[anthropic-moc]] - Provider-specific ecosystem map, contrasting with Hermes as provider-agnostic substrate.
- [[agent-knowledge-vault]] - Passive knowledge layer that complements Hermes's active skill and memory layers.

## Literature and specifications
- [[lit-hermes-architecture]] - Source-grounded literature note for Hermes official docs.
- [[spec-hermes-agent-loop]] - Derived implementation spec for the Hermes turn lifecycle.
- [[literature-moc]] - External source summaries across frameworks and protocols.
- [[specifications-moc]] - Formal and derived specs used in the vault.

---
## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\developer-guide\architecture.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\developer-guide\agent-loop.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\reference\slash-commands.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\reference\tools-reference.md`
