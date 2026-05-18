---
title: Hermes Subagent Delegation
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - delegate-task-pattern
  - hermes-child-agents
type: permanent
---
# Hermes Subagent Delegation

[[hermes-subagent-delegation]] is Hermes Agent's in-turn multi-agent mechanism. The `delegate_task` tool spawns one or more child agents with isolated context, their own terminal sessions, restricted toolsets, and independent reasoning loops, then returns only their final summaries to the parent.

## Core idea

Delegation in Hermes is a **reasoning fork**, not just a function call.

A delegated child gets:
- a fresh conversation
- explicit goal and context fields
- its own tool access boundary
- its own terminal session
- a bounded reasoning loop

This makes the child a real agent process in miniature, even though its lifecycle is still controlled by the parent turn.

## Isolation model

The most important property is contextual isolation.

A child agent does **not** inherit the parent's full conversation history. It only knows what the parent passes in `goal` and `context`.

That means delegation is useful when:
- the subtask needs genuine reasoning
- the parent wants a clean room for a branch of work
- intermediate tool noise should not flood the parent context
- several independent lines of work can proceed in parallel

## Parallel batch model

Hermes can fan out multiple children concurrently and gather their summaries in input order.

This makes [[hermes-subagent-delegation]] a practical implementation of [[pattern-parallel-fan-out]] and [[pattern-dynamic-delegation]] inside a single agent runtime.

## Tool-boundary model

The parent can narrow each child's toolsets to match the task.

That matters because delegation is not only about parallelism; it is also about **capability shaping**. A research child can get web tools, while a code child gets terminal and file tools.

Certain tools are withheld from normal leaf children, such as user clarification, memory writes, further delegation, or cross-platform messaging. This preserves containment.

## Role and depth

Hermes also distinguishes between:
- **leaf children** — workers that cannot delegate further
- **orchestrator children** — children that may spawn their own workers when depth limits allow it

This gives the framework a controlled route from flat delegation to tree-shaped orchestration.

## Non-durable by design

A crucial constraint is that [[hermes-subagent-delegation]] is **synchronous and non-durable**.

If the parent turn is interrupted, the child is interrupted too. Children do not outlive the parent conversation step.

This is what separates delegation from Hermes's durable systems:
- [[hermes-cron]] survives across scheduler ticks and future time
- [[hermes-kanban]] survives across profiles, retries, and human intervention
- delegation does not

## Why this matters conceptually

Many multi-agent demos collapse three different things into one bucket: parallel reasoning, durable task queues, and long-lived named workers.

Hermes keeps them separate:
- delegation = short-lived isolated reasoning branch
- cron = scheduled autonomous rerun
- kanban = durable work queue and collaboration board

That separation makes the runtime easier to reason about.

## Architectural consequence

[[hermes-subagent-delegation]] gives Hermes a native answer to bounded multi-agent collaboration inside one conversation. It provides most of the benefits of parallel subagents without forcing every multi-agent task into a durable board or a separate process supervisor.

## See Also
- [[hermes-agent]]
- [[hermes-cron]]
- [[hermes-kanban]]
- [[pattern-dynamic-delegation]]
- [[pattern-parallel-fan-out]]
- [[multi-agent-systems]]
- [[openai-swarm]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\features\delegation.md`
- Source: `C:\Users\executor\AppData\Local\hermes\skills\autonomous-ai-agents\hermes-agent\SKILL.md`
