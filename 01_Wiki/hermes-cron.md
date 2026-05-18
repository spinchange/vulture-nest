---
title: Hermes Cron
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-scheduled-tasks
  - hermes-agent-cron
type: permanent
---
# Hermes Cron

[[hermes-cron]] is Hermes Agent's durable scheduling layer. It runs autonomous work on a schedule by launching fresh agent sessions through the gateway-backed scheduler, then delivering results back to chats, files, or other configured destinations.

## Core idea

Hermes cron is not just "run a shell command later." It schedules **new agent executions**.

A cron job can carry:
- a prompt
- one or more attached skills
- delivery targets
- an optional working directory
- an optional script prelude
- optional upstream job context
- an optional script-only mode with no model invocation

That makes [[hermes-cron]] a scheduler for agent behavior, not merely for processes.

## Fresh-session model

Each cron run starts in a fresh agent session rather than continuing an existing conversation thread.

That gives the system predictable boundaries:
- each run has clean context
- the job definition, not chat history, defines what happens
- recurring work remains reproducible
- scheduled automation does not depend on an open foreground operator session

This is a major difference from interactive backgrounding.

## Gateway-backed execution

Cron execution is anchored in the [[hermes-gateway]] daemon, which ticks the scheduler, launches due jobs, updates metadata, and delivers output.

So the cron layer depends on Hermes already being a **persistent service substrate**.

## Delivery semantics

Cron jobs can return their results to:
- the originating conversation
- local output files
- one or more configured messaging platforms
- fan-out targets such as all connected home channels

This means the scheduler is integrated directly into Hermes's transport layer rather than forcing users to wire separate notification plumbing.

## No-agent mode

A crucial design choice is that Hermes cron has two modes:
- **agent mode** — run a prompt in a fresh agent session
- **no-agent mode** — run a script and deliver its stdout verbatim

This lets the same scheduler support both reasoning-heavy automations and classic watchdog patterns.

## Chained jobs and staged pipelines

Cron jobs can also feed later jobs via prior output context.

That enables multi-stage automation patterns such as:
- collect data
- filter or rank it
- format it for delivery
- ship it to one or more channels

So [[hermes-cron]] is not only a reminder system; it is a lightweight pipeline substrate.

## Safety and invariants

Hermes places important boundaries around scheduled autonomy:
- cron runs cannot recursively create more cron jobs
- each run happens in a fresh session
- the scheduler uses a tick lock to prevent duplicate overlapping execution
- working-directory jobs are serialized when needed to avoid shared-cwd corruption

These constraints keep the automation substrate from turning into runaway self-replication.

## Contrast with other Hermes execution modes

Use [[hermes-cron]] when the work must be **durable and time-based**.

Contrast:
- [[hermes-subagent-delegation]] is synchronous and tied to a parent turn
- a background shell process is durable at the OS level but not an agent scheduler
- [[hermes-kanban]] is a durable coordination board for multi-agent collaboration, not a time-triggered scheduler

## Architectural consequence

[[hermes-cron]] extends Hermes from an interactive assistant into a **persistent automation environment**. It allows skills, prompts, tools, and delivery surfaces to be recombined into scheduled agent behaviors without building a separate orchestration stack.

## See Also
- [[hermes-agent]]
- [[hermes-gateway]]
- [[hermes-profiles]]
- [[hermes-skills-system]]
- [[hermes-subagent-delegation]]
- [[hermes-kanban]]
- [[openai-symphony]]
- [[daemon-design-pattern]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\features\cron.md`
- Source: `C:\Users\executor\AppData\Local\hermes\skills\autonomous-ai-agents\hermes-agent\SKILL.md`
