---
title: Hermes Agent
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - nous-hermes
  - hermes-framework
type: permanent
---
# Hermes Agent

[[hermes-agent]] is a provider-agnostic AI agent framework that runs the same core agent across terminal, messaging platforms, and IDE-style control surfaces. Its distinctive move is to treat an agent not as a single chat loop, but as a **durable operating environment** composed of tools, memory, skills, sessions, and background workers.

## Core idea

Most agent frameworks focus on one layer:
- orchestration libraries such as [[langgraph]] or [[openai-agents-sdk]] define control flow
- protocol layers such as [[mcp-moc]] define tool interoperability
- hosted runtimes such as [[anthropic-managed-agents-model]] define a managed execution environment

Hermes instead bundles all of these into a user-facing substrate:
1. **Conversation surfaces** — CLI, messaging gateway, and ACP/IDE integrations
2. **Execution substrate** — terminal, file, browser, search, vision, messaging, and scheduling tools
3. **Context layer** — [[agent-skills-index|skills]], bounded persistent memory, session search, and personality files
4. **Durability layer** — profiles, gateway daemons, cron jobs, background processes, and multi-agent coordination

The result is closer to an **agent shell** or **personal agent operating system** than to a narrow SDK.

## What makes Hermes distinct

### 1. Skills as procedural memory
Hermes treats `SKILL.md` documents as executable procedures that can be loaded on demand. This makes operational knowledge portable, inspectable, and improvable without hardcoding every workflow into the base prompt. See [[agent-skills-index]], [[hermes-skills-system]], and [[hermes-bounded-memory]].

### 2. Bounded memory plus deep recall
Hermes keeps a small always-on memory in prompt and pairs it with searchable session history. This splits "critical facts the agent should always remember" from "everything the agent once discussed." See [[hermes-bounded-memory]].

### 3. Same agent across many interfaces
The same Hermes instance can answer in a terminal, a Telegram thread, or another gateway surface while preserving the same tools and long-term context. See [[hermes-gateway]].

### 3.5. A real operator control plane
Hermes does not force runtime management through natural-language chat alone. It exposes a structured slash-command layer for session control, model switching, background runs, gateway administration, and runtime steering. See [[hermes-command-control-plane]].

### 4. Durable background execution
Hermes is not limited to foreground chat. It can schedule work, spawn background tasks, run daemonized gateways, and maintain isolated profiles. This gives it a lifecycle closer to infrastructure than to a one-off assistant process. See [[hermes-cron]], [[hermes-profiles]], and [[hermes-kanban]].

### 5. Multiple collaboration modes
Hermes separates several forms of multi-agent work that other systems often blur together:
- [[hermes-subagent-delegation]] for synchronous in-turn child agents
- [[hermes-cron]] for scheduled autonomous reruns
- [[hermes-kanban]] for durable cross-profile work queues

That separation makes the runtime easier to reason about than systems that treat every kind of concurrency as one generic "agent swarm."

## Architectural consequence

Hermes collapses several patterns that are often separated in other stacks:
- **tool calling**
- **memory management**
- **skill loading**
- **message transport**
- **background automation**
- **multi-profile isolation**

This makes Hermes a strong reference implementation for the idea that an agent is not just a model-plus-tools loop, but a **persistent context layer wrapped around interchangeable models**.

## When to start here

Start at [[hermes-agent]] when the question is:
- how one agent can persist across sessions and platforms
- how skills and memory interact in a real deployed system
- how chat surfaces, cron, and background daemons can share one substrate
- how to compare a full agent environment against narrower frameworks such as [[agent-development-kit]], [[openai-swarm]], or [[langgraph]]

## See Also
- [[hermes-moc]]
- [[hermes-bounded-memory]]
- [[hermes-gateway]]
- [[hermes-profiles]]
- [[hermes-skills-system]]
- [[hermes-cron]]
- [[hermes-subagent-delegation]]
- [[hermes-kanban]]
- [[hermes-command-control-plane]]
- [[hermes-vs-adk-openai-agents-langgraph]]
- [[lit-hermes-architecture]]
- [[spec-hermes-agent-loop]]
- [[agent-knowledge-vault]]
- [[agent-skills-index]]
- [[memory-spectrum]]
- [[daemon-design-pattern]]
- [[agentic-frameworks-moc]]
- [[adk-moc]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\skills\autonomous-ai-agents\hermes-agent\SKILL.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\features\skills.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\features\memory.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\profiles.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\features\cron.md`
