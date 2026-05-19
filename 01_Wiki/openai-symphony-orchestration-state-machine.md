---
title: OpenAI Symphony Orchestration State Machine
author: gpt-5.4
date: '2026-05-19'
status: active
aliases:
  - symphony-state-machine
  - symphony-claim-state
  - symphony-run-lifecycle
type: permanent
---

# OpenAI Symphony Orchestration State Machine

[[openai-symphony]] becomes much clearer once its internal claim logic is separated from the external tracker workflow. The tracker may say `Todo`, `In Progress`, or `Done`; Symphony itself separately tracks whether an issue is **claimed**, **running**, or **queued for retry**.

## Two distinct state layers

Symphony has two state systems that must not be conflated.

### 1. Tracker workflow state

This is the project-management view exposed by Linear or another tracker:

- active states such as `Todo` and `In Progress`
- terminal states such as `Done`, `Closed`, or `Cancelled`
- workflow-defined intermediate handoff states such as `Human Review`

This state answers: **Should this work item still exist as live project work?**

### 2. Symphony orchestration state

This is the service's internal claim state:

- **`Unclaimed`** — no worker is running and no retry is scheduled
- **`Claimed`** — the orchestrator has reserved the issue to prevent duplicate dispatch
- **`Running`** — a worker task exists and the issue is present in the running map
- **`RetryQueued`** — no worker is active, but a retry timer exists

This state answers: **What is the orchestrator currently doing with this issue?**

## Why the split matters

This split keeps Symphony from confusing project status with execution status.

An issue can remain tracker-active while Symphony transitions through several internal execution states:

`Unclaimed -> Claimed -> Running -> RetryQueued -> Running -> terminal cleanup`

The tracker owns the work item's business meaning. Symphony owns the worker lifecycle.

## The poll-and-dispatch loop

At the top level, Symphony is a continuous orchestration tick:

1. poll the tracker for candidate issues
2. exclude issues that are already claimed or otherwise ineligible
3. claim selected issues to prevent duplicate dispatch
4. create or reuse the workspace
5. launch the worker attempt
6. react to worker outcomes and tracker changes
7. release, retry, or clean up

The orchestrator is therefore not just a launcher. It is the **durability and coordination layer** around repeated worker attempts.

## Run attempts as bounded worker episodes

A Symphony issue may require multiple attempts before it leaves the active workflow. Each attempt is a bounded episode consisting of:

- workspace preparation
- prompt rendering from `WORKFLOW.md`
- coding-agent startup
- streamed runtime events back to the orchestrator
- a terminal outcome such as success, failure, cancellation, stall, or retry scheduling

This makes the issue, not the single worker process, the durable unit of work.

## Reconciliation is first-class, not cleanup glue

The spec gives reconciliation a central role.

### Stall detection

For each running issue, Symphony computes elapsed time since either:

- the last Codex event timestamp, or
- the run start time if no event has yet been seen

If the elapsed time exceeds `codex.stall_timeout_ms`, the worker is terminated and a retry is queued. If stall timeout is disabled, stall detection is skipped entirely.

### Tracker refresh

Every tick, Symphony refreshes tracker state for running issue IDs.

- if the tracker state is now terminal, Symphony terminates the worker and cleans the workspace
- if the tracker state is still active, Symphony updates the in-memory issue snapshot

This means runtime truth is continuously checked against project-system truth.

## Runtime events as state-machine inputs

The agent runner emits structured events upstream to the orchestrator, including examples such as:

- `session_started`
- `startup_failed`
- `turn_completed`
- `turn_failed`
- `turn_cancelled`

These events are not just logs. They are **inputs to orchestration decisions** about liveness, retry, progress tracking, and operator visibility.

## Recovery and idempotency

The Symphony state machine is designed for long-running service conditions rather than one-shot script execution.

Important consequences:

- startup can include terminal-workspace cleanup
- active runs are reconciled repeatedly, not trusted blindly
- retries are scheduled explicitly rather than inferred from worker exit alone
- issue claims prevent duplicate dispatch when the poller sees the same candidate again

This gives Symphony the character of a **service-owned execution ledger**, even when some state is in-memory.

## Architectural significance

Symphony's main contribution is not merely "run Codex for issues." It is the claim that coding-agent orchestration should be treated like a durable control loop with:

- explicit claim semantics
- bounded worker attempts
- reconciliation against an external control plane
- retry scheduling as a native state transition

That is why it feels closer to a workflow service than to a multi-agent chat runtime.

## See Also

- [[openai-symphony]]
- [[openai-symphony-workflow-contract]]
- [[openai-symphony-trust-boundary]]
- [[multi-agent-systems]]
- [[graph-orchestration]]

## References

- [[lit-openai-symphony-spec]]
- `SPEC.md` §7–§10, `openai/symphony`
