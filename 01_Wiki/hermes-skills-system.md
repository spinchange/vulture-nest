---
title: Hermes Skills System
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-skills
  - skill-md-procedural-memory
type: permanent
---
# Hermes Skills System

[[hermes-skills-system]] is Hermes Agent's on-demand procedural knowledge layer. It treats a skill not as a hidden prompt fragment but as a **versioned document bundle** that the agent can discover, inspect, load, patch, publish, and reuse.

## Core idea

A Hermes skill is centered on a `SKILL.md` document, optionally accompanied by references, templates, scripts, and assets.

This makes skills:
- human-readable
- agent-editable
- portable across machines and installs
- loadable only when needed

So the skill system functions as **procedural memory externalized into files**.

## Progressive disclosure

Hermes does not inject every skill into prompt all the time. Instead it uses a staged loading model:
1. **index level** — list available skills by name and description
2. **full skill level** — load one skill's `SKILL.md`
3. **supporting file level** — load only the needed reference or template

This is a token-economy design. The agent sees the catalog cheaply, then pulls in detailed procedure only when a task requires it.

## Why skills matter

Many agent frameworks force reusable know-how into one of two bad places:
- the giant base system prompt
- ad hoc user reminders that disappear after the session

Hermes instead gives procedures their own durable substrate.

That allows workflows such as:
- install a skill from a registry
- let the agent discover and use it at runtime
- patch the skill when reality differs from the instructions
- keep the improved workflow for later sessions

In that sense, [[hermes-skills-system]] is Hermes's answer to the question: **where should learned procedure live?**

## Skills versus memory

Skills and memory solve different persistence problems:
- [[hermes-bounded-memory]] stores stable facts about the user and environment
- [[hermes-skills-system]] stores reusable procedures, checklists, and recipes

So "Chris prefers concise answers" belongs in memory, while "how to troubleshoot Telegram topic sessions on Windows" belongs in a skill.

## Directory model

The canonical Hermes skill store is `~/.hermes/skills/`. Skills can also be discovered from external directories, but the local Hermes directory remains the writable source of truth.

This means the system supports three kinds of skill provenance:
- bundled skills shipped with Hermes
- hub-installed skills from registries or URLs
- agent-authored or agent-patched skills generated from lived use

## Agent-managed skills

A distinctive feature of Hermes is that the agent itself can maintain the skill library.

The agent can:
- create a new skill after discovering a workflow
- patch an outdated skill after hitting a pitfall
- add supporting reference files or templates
- delete or archive obsolete procedures

This turns the skill library into a **self-improving operations manual**.

## Hub and ecosystem role

Hermes also treats skills as a distribution format. Skills can be browsed, inspected, installed, audited, updated, and published across multiple hubs and repositories.

That makes a skill more than local prompt furniture; it becomes an exchangeable unit of agent capability.

## Architectural consequence

[[hermes-skills-system]] sits between the static system prompt and the live tool layer.

It gives Hermes a way to:
- stay lightweight at session start
- become specialized on demand
- preserve hard-won procedure after the session
- share operational knowledge between agents and operators

This is why the skill layer is central to understanding Hermes as a **self-improving agent environment** rather than a fixed assistant wrapper.

## Relationship to the vault

The skill system is also a useful contrast with [[agent-skills-index]] and the broader Vulture Nest substrate.

- a Hermes skill is **active procedural instruction** loaded into a live agent session
- a vault note is **passive durable knowledge** that remains outside the active prompt until retrieved

Hermes therefore separates procedural execution memory from the knowledge graph in a cleaner way than many notebook-style agent systems.

## See Also
- [[hermes-agent]]
- [[hermes-bounded-memory]]
- [[hermes-profiles]]
- [[agent-skills-index]]
- [[lit-skills-agent-behavior]]
- [[agent-knowledge-vault]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\features\skills.md`
- Source: `C:\Users\executor\AppData\Local\hermes\skills\autonomous-ai-agents\hermes-agent\SKILL.md`
