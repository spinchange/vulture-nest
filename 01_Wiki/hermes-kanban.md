---
title: Hermes Kanban
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-multi-agent-board
  - hermes-durable-work-queue
type: permanent
---
# Hermes Kanban

[[hermes-kanban]] is Hermes Agent's durable multi-agent coordination board. Instead of treating collaboration as an in-memory swarm of temporary subagents, it stores tasks, comments, dependencies, workspace assignments, and worker state in a persistent SQLite-backed board shared across Hermes profiles.

## Core idea

Hermes Kanban turns multi-agent work into a **database-backed queue and state machine**.

The durable objects are:
- tasks with assignees and statuses
- links between tasks
- comment threads as handoff history
- workspaces where workers operate
- dispatcher claims and liveness signals

So every handoff becomes inspectable and resumable.

## Why it exists

[[hermes-subagent-delegation]] is excellent for short-lived reasoning branches, but it breaks down when work must:
- survive restarts
- wait on human input
- move between named agents over time
- be audited later
- accumulate a long-lived comment trail

[[hermes-kanban]] is Hermes's answer to that durability problem.

## Profile-centered collaboration

A Kanban worker is not an anonymous child summary. It is a full Hermes profile with its own memory, skills, configuration, and identity.

That means the board coordinates **named long-lived agents**, not just ephemeral branches of one parent prompt.

## Dispatcher model

A dispatcher loop watches the board, promotes ready tasks, reclaims stale claims, and spawns the assigned worker profile when work is ready.

Because the dispatcher normally runs inside the [[hermes-gateway]], the board inherits the same persistent daemon substrate that powers messaging and cron delivery.

## Tool-mediated worker protocol

Hermes workers do not coordinate through shelling out to a CLI wrapper. They use a dedicated `kanban_*` toolset to read tasks, post comments, heartbeat, block, or complete work.

This matters because it makes the board a **first-class agent substrate**, not just a shell-level queue bolted onto the side.

## Kanban versus delegation

The distinction from [[hermes-subagent-delegation]] is fundamental:
- delegation is a parent-owned synchronous fork/join call
- kanban is a durable peer-readable work queue

Delegation returns results into the parent context and disappears.
Kanban leaves a durable artifact trail that any authorized profile or human can inspect later.

## Kanban versus cron

The distinction from [[hermes-cron]] is also important:
- cron answers *when* an autonomous run should happen
- kanban answers *how* multiple named agents coordinate across time

A cron job can create or monitor board work, but the board itself is the coordination memory.

## Architectural consequence

[[hermes-kanban]] shows Hermes moving beyond "agent with tools" into **agent operations infrastructure**.

It combines:
- durable state
- named worker identities
- explicit handoffs
- dependency tracking
- human intervention points
- resumability after crashes or blocking conditions

This makes it one of the clearest examples of Hermes treating multi-agent collaboration as an operating system problem instead of a prompt-engineering trick.

## See Also
- [[hermes-agent]]
- [[hermes-gateway]]
- [[hermes-profiles]]
- [[hermes-cron]]
- [[hermes-subagent-delegation]]
- [[shared-memory-blackboard]]
- [[multi-agent-patterns-moc]]
- [[pattern-progressive-handoff]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\features\kanban.md`
- Source: `C:\Users\executor\AppData\Local\hermes\skills\autonomous-ai-agents\hermes-agent\SKILL.md`
