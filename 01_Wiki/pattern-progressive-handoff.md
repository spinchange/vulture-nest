---
title: 'Pattern: Progressive Handoff'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases:
  - handoff-pattern
  - task-ownership-transfer
  - agent-transfer
---

# Pattern: Progressive Handoff

**Intent:** Transfer complete ownership of a task from Agent A to Agent B. Agent A's involvement terminates cleanly; Agent B continues from a serialized snapshot of A's working state. The user (or orchestrator) experiences continuity — the conversation does not restart.

Handoff is distinct from [[pattern-dynamic-delegation]] (where A retains ownership and uses B as a sub-worker) and from [[pattern-parallel-fan-out]] (where A coordinates many concurrent workers). In a handoff, A exits the picture entirely.

---

## Framework Implementations

### Swarm — Function Returns Agent
In Swarm, a handoff is encoded as a function that returns an `Agent` object:
```python
billing_agent = Agent(name="BillingSpecialist", instructions="...")

def transfer_to_billing():
    """Route conversation to the billing specialist."""
    return billing_agent  # returning Agent = handoff

triage_agent = Agent(
    instructions="Route requests to the correct department.",
    functions=[transfer_to_billing]
)
```
When the triage agent calls `transfer_to_billing()`, Swarm swaps the active agent: the system prompt changes to `billing_agent.instructions`, but the full conversation history is preserved. The triage agent's instruction context disappears; the billing agent takes over.

**Limitation:** Context is passed via the shared `context_variables` dict (see [[pattern-state-transfer]]). There is no explicit "handoff summary" step — the billing agent receives the raw conversation history, which may include noise.

### ADK — `transfer_to_agent`
ADK's `LlmAgent` can invoke a `transfer_to_agent` action (via the runner's built-in tool) to route to a named sub-agent in the hierarchy:
```python
# In a tool or callback, the agent signals a transfer
def check_and_route(tool_context: ToolContext) -> dict:
    if tool_context.state.get("intent") == "billing":
        return {"action": "transfer_to_agent", "agent_name": "BillingAgent"}
```
The Runner detects the transfer signal and routes subsequent turns to `BillingAgent`. State accumulated in `session.state` is available to the receiving agent immediately.

### A2A — `TRANSFERRED` State
A2A formalizes the handoff as a task state transition:

**Three-phase atomic handoff:**
1.  **Summarize:** Originating agent serializes working state into `transfer_context`.
2.  **Create:** Originating agent creates the receiving task on Agent B via `SendMessage` (with `transfer_context` in the message).
3.  **Terminate:** Originating agent transitions its own task to `TRANSFERRED`, referencing B's task ID.

```json
{
  "state": "TRANSFERRED",
  "transfer": {
    "agent_endpoint": "https://billing.example.com",
    "task_id": "task_xyz_billing",
    "reason": "Routing to Billing specialist — BILLING_REFUND intent"
  }
}
```

The orchestrator reads the `transfer` field and routes subsequent user messages to `billing.example.com/tasks/task_xyz_billing`. The originating agent's task is terminal — it receives no further input.

---

## Canonical Three-Phase Structure

```
[Phase 1: Summarize]
  Agent A distills key facts from its working memory
  into a typed state snapshot (transfer_context / context_variables).

[Phase 2: Bootstrap]
  Agent A creates a task on Agent B, passing the state snapshot.
  Agent B bootstraps its working memory from the snapshot.

[Phase 3: Terminate]
  Agent A transitions to a terminal state (TRANSFERRED / exits run loop).
  Orchestrator routes subsequent input to Agent B.
```

**Atomicity requirement (A2A):** Steps 2 and 3 must be ordered — B's task must exist before A transitions to TRANSFERRED, to prevent the orchestrator from receiving a TRANSFERRED pointer to a non-existent task.

---

## Contrast: Handoff vs. Delegation

| | Handoff | Delegation |
|---|---|---|
| A continues after B? | No | Yes |
| A retains task ownership? | No | Yes |
| B needs A's state? | Yes (serialized) | Partially (input only) |
| A2A state | TRANSFERRED (terminal) | WORKING (throughout) |
| Swarm mechanism | Return Agent object | Return string result |
| ADK mechanism | `transfer_to_agent` | `AgentTool` invocation |

---

## Capability Gate (Mandatory Pre-Check)

Before any handoff, the originating agent must verify:
```
Required ⊆ Caps(B) ∩ Scope(A)
```
Failure → `FAILED` state (never silent forward). See [[pattern-capability-gating]].

---

## References
- [[a2a-protocol]] — TRANSFERRED state and transfer_context specification
- [[agent-development-kit]] — `transfer_to_agent` mechanism
- [[lit-openai-swarm]] — function-returning-Agent handoff model
- [[pattern-state-transfer]] — state serialization before handoff
- [[pattern-dynamic-delegation]] — contrast: A retains ownership
- [[pattern-capability-gating]] — mandatory pre-handoff authorization check
- [[inter-agent-handoff-protocol]] — vault-level handoff protocol
- [[pattern-agent-as-tool]]