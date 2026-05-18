---
title: "Literature: Hermes Architecture and Control Surfaces"
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - lit-hermes-architecture
  - lit-hermes-docs
  - hermes-architecture-source
type: literature
---
# Literature: Hermes Architecture and Control Surfaces

## Source Metadata
- **Files:** `website/docs/developer-guide/architecture.md`, `website/docs/developer-guide/agent-loop.md`, `website/docs/reference/slash-commands.md`, `website/docs/reference/tools-reference.md`
- **Origin:** Official Hermes Agent documentation bundled with the local install at `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs`
- **Domain:** agent runtime architecture / multi-surface execution / tooling substrate
- **Relevance:** These docs explain Hermes as a unified runtime that spans CLI, gateway messaging, cron, tool execution, and persistent context management.

## High-Level Summary
The Hermes docs describe a system that is broader than a model wrapper and narrower than a full hosted cloud control plane. The core claim is that **one agent loop** can be reused across multiple surfaces — terminal UI, messaging adapters, cron jobs, ACP/IDE integration, and API-style entry points — as long as prompt assembly, provider resolution, tool dispatch, and persistence are centralized in a single `AIAgent` runtime.

## Core Architectural Picture
The architecture note divides Hermes into four major layers:
1. **Entry surfaces** — CLI, gateway, ACP, API server, and batch runners.
2. **Core orchestration** — `run_agent.py` plus prompt building, provider resolution, tool dispatch, compression, and caching.
3. **Persistence** — SQLite session storage with FTS5, plus memory files and profile-scoped state.
4. **Tool backends** — terminal, browser, web, file, vision, MCP, and plugin-provided tools.

This means Hermes is organized around a **shared execution core** rather than a separate implementation per interface.

## Agent Loop as the Unifying Primitive
The agent-loop docs make `AIAgent.run_conversation()` the central primitive. Every surface eventually funnels into the same basic cycle:
1. append the user or job prompt to history
2. assemble or reuse the system prompt
3. resolve provider and API mode
4. call the model
5. if tool calls are returned, execute them and continue looping
6. if text is returned, persist the result and end the turn

The important architectural consequence is that CLI, gateway, and cron differ mainly in **where the prompt came from**, **what history is loaded**, and **where the final response is delivered**, not in their core reasoning loop.

## Three Execution Surfaces
### CLI
The CLI is an interactive shell around the core runtime. Its distinctive value is local control: slash commands, session branching, checkpoints, and live progress callbacks.

### Gateway
The gateway turns the same runtime into a long-lived messaging daemon. Platform adapters normalize Telegram, Discord, Slack, and other events into a shared message flow, then send responses back through each platform's adapter.

### Cron
Cron is not shell scheduling bolted onto a chat tool. The docs frame it as **fresh-session agent execution**: each job spawns a new run with attached skills, optional scripts, and explicit delivery targets.

## Tool System as Capability Surface
The tools reference emphasizes that Hermes' capability surface is not monolithic. Tools are grouped into **toolsets**, registered centrally, and made available depending on environment, credentials, and platform.

This has three implications:
- the same agent identity can expose different capabilities in different contexts
- dynamic MCP tools extend the runtime without changing the core registry model
- agent behavior is partly shaped by which tool schemas are even visible in a session

The docs therefore treat tool availability as a first-class architectural input, not merely an implementation detail.

## Command Surfaces as Operational Grammar
The slash-command reference reveals a second design layer above the model loop: Hermes has an **operator grammar** for steering the runtime itself.

Commands such as `/model`, `/compress`, `/background`, `/goal`, `/kanban`, `/cron`, and `/reload-mcp` are not domain tools; they are controls over the agent substrate. In practice, Hermes exposes both:
- a **model-facing capability surface** through tools
- a **human-facing control surface** through slash commands

That dual interface is unusual among agent systems and helps explain why Hermes feels like an environment rather than a single chat abstraction.

## Durable Context Strategy
The docs position persistent context as a layered system:
- system prompt assembly from personality, memory, skills, and project context
- session storage in SQLite with lineage and search
- compression when context pressure rises
- profile-level isolation for multiple long-lived agents

This makes Hermes a concrete example of how to balance **always-on context**, **retrievable history**, and **ephemeral per-turn state** inside one runtime.

## Key Patterns Extracted
- **Single-core / many-surfaces architecture** — one loop, many interfaces
- **Prompt as assembled substrate** — context is built from files, memory, skills, and environment hints
- **Tool-schema governance** — what the model can do is constrained by the registered/visible toolset
- **Operational control plane** — slash commands manage the runtime itself
- **Durable yet bounded context** — memory stays small while sessions and tools extend recall on demand

## Connections to Vault
- [[hermes-agent]] - top-level Hermes environment concept
- [[hermes-moc]] - cluster navigation map for Hermes-specific notes
- [[spec-hermes-agent-loop]] - distilled execution spec derived from these sources
- [[hermes-bounded-memory]] - hot memory layer
- [[hermes-skills-system]] - procedural memory layer
- [[hermes-gateway]] - messaging surface
- [[hermes-cron]] - scheduled fresh-session execution
- [[hermes-subagent-delegation]] - synchronous child-agent branching inside a turn
- [[hermes-kanban]] - durable coordination outside a single turn

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\developer-guide\architecture.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\developer-guide\agent-loop.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\reference\slash-commands.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\reference\tools-reference.md`
