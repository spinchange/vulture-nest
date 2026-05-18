---
title: Hermes Profiles
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-multi-profile-isolation
  - hermes-home-partitions
type: permanent
---
# Hermes Profiles

[[hermes-profiles]] is the mechanism that lets one Hermes install host multiple independent long-lived agents on the same machine. A profile is not just a named preset; it is a **separate Hermes home directory** with its own state, configuration, memory, sessions, skills, gateway state, and scheduled jobs.

## Core idea

Hermes treats agent identity as a directory boundary.

Each profile gets its own copy of:
- `config.yaml`
- `.env`
- `SOUL.md`
- memories and user profile data
- session transcripts
- installed and agent-authored skills
- gateway PID/state
- cron jobs and other persistent metadata

This makes a profile a **whole agent instance**, not just a persona switch.

## Why profiles matter

Profiles solve a problem that many agent stacks blur together: one machine may need several agents with different purposes, different credentials, and different persistent histories.

Examples:
- a coding-focused agent with repo-specific defaults
- a research agent with different tools and skills
- a messaging bot with its own bot token and home channel
- a personal assistant whose memory should not mix with engineering work

So [[hermes-profiles]] turns Hermes from a single assistant into a **fleet substrate**.

## What profiles isolate

Profiles isolate durable agent state:
- model and provider configuration
- API keys and bot tokens
- prompt personality via `SOUL.md`
- memory and user-profile stores
- sessions, logs, and skill inventory
- cron jobs and gateway runtime state

In practice, that means two profiles can share code but behave like different agents with different biographies.

## What profiles do not isolate

A profile is **not** the same thing as a sandbox or workspace.

It does **not** automatically limit filesystem access.
It does **not** automatically change the terminal working directory.
It does **not** stop the agent from touching files outside the profile directory.

That separation matters:
- **profile** = agent state boundary
- **workspace / cwd** = where tools start working
- **sandbox** = what the process is allowed to access

This makes [[hermes-profiles]] an identity partition, not a security boundary.

## Command-surface consequence

Creating a profile also creates a direct command alias for that profile. So a profile named `coder` becomes a callable agent surface with commands like `coder chat`, `coder setup`, or `coder gateway start`.

That means profile selection is not hidden config; it becomes part of the operator interface.

## Clone semantics

Hermes exposes several ways to fork an agent:
- **blank profile** — fresh identity with bundled skills seeded
- **clone config** — same config, keys, and personality, but fresh memory and sessions
- **clone all** — full agent snapshot including memory, sessions, skills, and cron jobs

These modes show that Hermes treats profiles as a reproducible packaging unit for agent state.

## Gateway and token isolation

Each profile can run its own [[hermes-gateway]] process with its own platform tokens and bot identity.

That matters because gateway processes are one of the main ways an agent becomes persistently reachable. Token-lock behavior prevents two profiles from silently sharing the same bot identity by mistake.

## Architectural consequence

[[hermes-profiles]] is one of the strongest signs that Hermes is an **agent environment** rather than a single chat wrapper. The profile mechanism gives Hermes a native answer to multi-agent coexistence:
- separate memory without separate installs
- separate bots without separate codebases
- separate cron jobs without separate schedulers
- separate identities without duplicating the whole framework

## Relationship to other Hermes notes

Use [[hermes-profiles]] when the question is about **agent partitioning and identity**.
Use [[hermes-gateway]] when the question is about **message transport and daemonized reachability**.
Use [[hermes-cron]] when the question is about **scheduled autonomous work**.

## See Also
- [[hermes-agent]]
- [[hermes-gateway]]
- [[hermes-cron]]
- [[hermes-skills-system]]
- [[hermes-bounded-memory]]
- [[multi-agent-systems]]
- [[daemon-design-pattern]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\profiles.md`
- Source: `C:\Users\executor\AppData\Local\hermes\skills\autonomous-ai-agents\hermes-agent\SKILL.md`
