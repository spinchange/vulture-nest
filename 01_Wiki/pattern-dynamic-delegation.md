---
title: 'Pattern: Dynamic Delegation'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases:
  - delegation-pattern
  - agent-calls-agent
---

# Pattern: Dynamic Delegation

**Intent:** Agent A invokes Agent B as a sub-worker for a specific capability, waits for completion, and incorporates B's output into A's own ongoing task. A retains ownership of the parent task throughout.

This is the foundational composition primitive of multi-agent systems — the agent equivalent of a function call.

---

## Framework Implementations

### ADK — `AgentTool`
ADK wraps a complete agent as a callable tool visible to the parent `LlmAgent`'s tool roster:
```python
research_agent = LlmAgent(name="researcher", ...)
parent_agent = LlmAgent(
    name="coordinator",
    tools=[AgentTool(agent=research_agent)]
)
```
The parent LLM sees `researcher` in its tool list with the agent's description as the tool docstring. Invocation is a standard tool call; the AgentTool executes the sub-agent's full run loop and returns its final text output as the tool result.

### Swarm — Function Returning a String Result
In Swarm's model, delegation is a plain Python function call — the function does the work and returns a string:
```python
def get_research(topic: str) -> str:
    # Could invoke another model, API, or sub-agent
    return research_service.query(topic)

coordinator = Agent(functions=[get_research])
```
Swarm does not have a native `AgentTool` concept — returning an `Agent` object from a function is a **handoff** (see [[pattern-progressive-handoff]]), not delegation. True delegation in Swarm requires the function to complete synchronously and return a value.

### A2A — `SendMessage` + Poll Until `COMPLETED`
```
A: POST /tasks (SendMessage) → creates task on B, gets task_id
A: GET /tasks/{task_id} (or SSE subscribe) → polls state
B: state transitions SUBMITTED → WORKING → COMPLETED
A: extracts B.Artifacts → incorporates into A's own task
```
A's own task on its host remains `WORKING` throughout. B's task has its own independent lifecycle. The orchestrator managing A never sees B's task directly — A is responsible for the sub-delegation.

---

## Canonical Structure

```
Coordinator (A)
  └─ [receives goal]
  └─ [determines: sub-task needed for capability C]
  └─ DELEGATE to Specialist (B) with {input}
  └─ [await completion]
  └─ [receive result from B]
  └─ [incorporate result, continue own task]
  └─ [produce final output]
```

**Key invariant:** A never terminates its task while waiting for B. A is blocked (or async-waiting) but still the active task owner.

---

## Decision Criteria: When to Delegate vs. Hand Off

| Criterion | Delegate | Hand Off |
|---|---|---|
| A continues after B completes | Yes | No |
| A needs B's output | Yes | No (passes context) |
| A retains task ownership | Yes | No (transfers it) |
| A may call multiple sub-agents | Yes | No (single transfer) |

Use delegation when the coordinator needs to aggregate results from multiple specialists. Use [[pattern-progressive-handoff]] when the coordinator's role is complete and a specialist takes over entirely.

---

## Capability Constraint

Per [[capability-lattice-spec]], delegation is bounded by the scope intersection:
```
Effective(A → B) = Caps(B) ∩ Scope(A)
```
A cannot grant B capabilities A does not itself hold. See [[pattern-capability-gating]] for enforcement details.

---

## References
- [[agent-development-kit]] — `AgentTool` implementation
- [[lit-openai-swarm]] — Swarm function-as-tool model
- [[a2a-protocol]] — SendMessage delegation primitive
- [[pattern-progressive-handoff]] — contrast: transfer of ownership
- [[pattern-agent-as-tool]] — related: treating agent as opaque callable
- [[pattern-capability-gating]] — authorization enforcement at delegation boundaries
- [[pattern-parallel-fan-out]] — related: concurrent delegation to multiple agents
- [[adk-multi-agent-orchestration]]