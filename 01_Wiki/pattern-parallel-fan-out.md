---
title: 'Pattern: Parallel Fan-Out'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases:
  - fan-out-pattern
  - concurrent-delegation
  - parallel-agent-execution
---

# Pattern: Parallel Fan-Out

**Intent:** A coordinator agent dispatches N independent sub-tasks to N agents simultaneously, waits for all to reach a terminal state, then merges the results. Total latency = max(individual latencies), not sum.

Fan-Out is the performance primitive of multi-agent systems — the mechanism that makes parallelism explicit and manageable. It is distinct from [[pattern-dynamic-delegation]] (which is sequential by default) by virtue of the simultaneous dispatch and barrier synchronization.

---

## Framework Implementations

### ADK — `ParallelAgent`
ADK provides a first-class `ParallelAgent` workflow agent that executes all sub-agents concurrently and writes each result to `session.state` under the sub-agent's `output_key`:

```python
from google.adk.agents import ParallelAgent, LlmAgent

research_agent = LlmAgent(name="researcher", output_key="research_result", ...)
legal_agent    = LlmAgent(name="legal",      output_key="legal_review",   ...)
finance_agent  = LlmAgent(name="finance",    output_key="financial_model", ...)

parallel = ParallelAgent(
    name="analysis_fan_out",
    sub_agents=[research_agent, legal_agent, finance_agent]
)
# All three run concurrently; session.state receives all three output_keys
```

The parent `ParallelAgent` is the barrier: it does not return until all sub-agents have completed. Results are available in `session.state` after the barrier.

### Swarm — Manual Fan-Out
Swarm has no native parallel primitive. Fan-out must be implemented manually using Python concurrency:

```python
import asyncio

async def fan_out(tasks: list[dict]) -> list[str]:
    results = await asyncio.gather(*[
        run_agent_async(agent=specialist, task=t)
        for t in tasks
    ])
    return results
```

The `client.run()` function is synchronous, so async fan-out requires wrapping it in `asyncio.to_thread()` or using the async-compatible Agents SDK successor.

### A2A — Concurrent `SendMessage`
```python
# Dispatch all tasks simultaneously
task_ids = await asyncio.gather(*[
    send_message(agent_endpoint=ep, payload=p)
    for ep, p in zip(endpoints, payloads)
])

# Barrier: wait for all tasks to reach terminal state
results = await asyncio.gather(*[
    poll_until_done(task_id=tid)
    for tid in task_ids
])

# Merge: extract Artifacts from each completed task
merged = [extract_artifacts(r) for r in results]
```

A2A has no built-in barrier primitive — the orchestrator is responsible for tracking all task IDs and joining them. The coordinator's own A2A task remains `WORKING` until all sub-tasks complete.

---

## Canonical Structure

```
Coordinator
  ├─ DISPATCH (simultaneously):
  │    ├─ Agent B1 ← subtask_1
  │    ├─ Agent B2 ← subtask_2
  │    └─ Agent B3 ← subtask_3
  │
  ├─ BARRIER: wait until all reach COMPLETED (or FAILED)
  │
  └─ MERGE: combine results into coordinator's working state
```

---

## Error Handling at the Barrier

Fan-out must define a **failure policy** for the barrier:

| Policy | Behavior | When to use |
|---|---|---|
| **Fail-fast** | Cancel all running tasks if any fails | All results are required for coherent output |
| **Best-effort** | Collect whatever completes, log failures | Partial results are acceptable |
| **Retry** | Re-attempt failed sub-tasks before barrier | Transient failures expected |
| **Escalate** | Transition coordinator to `INPUT_REQUIRED` | Human decision needed on failure |

ADK's `ParallelAgent` fails the entire parallel step if any sub-agent fails. A2A orchestrators must implement their own policy. Swarm's `asyncio.gather()` with `return_exceptions=True` enables best-effort collection.

---

## When to Use Fan-Out vs. Sequential

| Scenario | Pattern |
|---|---|
| Sub-tasks are independent and results must be merged | Fan-Out |
| Sub-task B depends on output from sub-task A | Sequential (`SequentialAgent` / chained delegation) |
| Sub-task count is dynamic (unknown at dispatch time) | Fan-Out with dynamic task list |
| One sub-task dominates latency and others are negligible | Sequential (simpler) |

---

## References
- [[agent-development-kit]] — `ParallelAgent` implementation
- [[lit-openai-swarm]] — manual async fan-out in Swarm
- [[a2a-protocol]] — concurrent SendMessage pattern
- [[pattern-dynamic-delegation]] — sequential delegation (contrast)
- [[pattern-state-transfer]] — merging results back into shared state after barrier
- [[lit-python-standard-library]] — `asyncio.gather` as the Python barrier primitive
