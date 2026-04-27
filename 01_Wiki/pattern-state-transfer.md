---
title: 'Pattern: State Transfer'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases:
  - context-transfer-pattern
  - shared-working-memory
---

# Pattern: State Transfer

**Intent:** Preserve and propagate an agent's working memory across boundaries — between tool calls within a session, across agent handoffs, and across multi-turn interactions — without passing the full conversation history verbatim.

State Transfer is the connective tissue of multi-agent pipelines. Without it, each agent starts from zero; with it, a pipeline of agents shares accumulated context as structured data.

---

## The Core Problem

Raw conversation history is expensive and lossy for cross-agent communication:
*   Full history grows O(n) with turns; sub-agents only need the relevant subset.
*   History is unstructured prose — subsequent agents must re-parse it to extract facts.
*   Cross-framework handoffs (e.g., Swarm → A2A) have no shared history format.

The solution: **flatten working memory into a typed key-value map** before crossing a boundary. Each agent reads what it needs, writes what it produces, and the map accumulates the pipeline's shared state.

---

## Framework Implementations

### Swarm — `context_variables`
A `dict` passed into every `client.run()` call and available to all agent functions:
```python
context_variables = {
    "user_name": "Alice",
    "order_id": "ORD-88234",
    "triage_classification": "BILLING_REFUND"
}
response = client.run(
    agent=triage_agent,
    messages=messages,
    context_variables=context_variables
)
# context_variables is returned, potentially mutated by functions
updated_ctx = response.context_variables
```
Functions receive `context_variables` as a parameter and return a `Result` object to mutate it. State is **caller-managed** — Swarm itself does not persist it between `run()` calls.

### ADK — `Session.State` + `output_key`
ADK manages state within a `Session` object, automatically persisted by the `SessionService`:
```python
# Reading state in an agent tool
def check_inventory(tool_context: ToolContext) -> str:
    order_id = tool_context.state["order_id"]
    # ...

# Writing state via output_key
sub_agent = LlmAgent(
    name="classifier",
    output_key="triage_classification"  # final response stored under this key
)
```
`output_key` is ADK's mechanism for *named pipeline outputs* — a sub-agent's result is automatically written to `session.state[output_key]` and becomes available to downstream agents in the same session.

### A2A — `transfer_context`
For cross-agent handoffs, A2A carries a `transfer_context` block on the initiating `Message`:
```json
{
  "role": "user",
  "parts": [{ "kind": "text", "text": "User needs a refund for order #88234." }],
  "transfer_context": {
    "originating_task_id": "task_abc_triage",
    "originating_agent": "https://triage.example.com",
    "state": {
      "user_intent": "billing_refund",
      "account_id": "ACC-12345",
      "order_id": "ORD-88234"
    },
    "output_keys": {
      "triage_classification": "BILLING_REFUND",
      "sentiment": "frustrated"
    }
  }
}
```

| `transfer_context` field | Swarm analog | ADK analog |
|---|---|---|
| `state` | `context_variables` | `session.state` |
| `output_keys` | return values from functions | `output_key` results |
| `originating_task_id` | — | — (A2A-only audit trail) |

---

## Canonical Structure

```
[Agent A produces facts during processing]
  └─ Classifies user intent → "BILLING_REFUND"
  └─ Looks up account   → ACC-12345
  └─ Detects sentiment  → "frustrated"

[At boundary: A serializes to state map]
{
  "triage_classification": "BILLING_REFUND",
  "account_id": "ACC-12345",
  "sentiment": "frustrated"
}

[Agent B receives state map]
  └─ Reads "triage_classification" → knows routing reason
  └─ Reads "account_id" → looks up billing record
  └─ Does NOT need to re-read full conversation history
```

---

## Design Principles

1.  **Flat, typed keys:** Avoid nested objects in the state map where possible. Nested structures require the receiver to know the schema; flat keys are self-documenting.
2.  **Append, don't overwrite:** Each agent adds its outputs under new keys rather than replacing prior keys. This preserves the audit trail.
3.  **Summarize, don't replay:** Before a handoff, the originating agent is responsible for distilling the relevant history into state entries. The full transcript is not passed.
4.  **Schema stability:** Keys written by upstream agents become an implicit API contract with downstream agents. Changing a key name is a breaking change.

---

## References
- [[lit-openai-swarm]] — `context_variables` implementation
- [[agent-development-kit]] — `Session.State` and `output_key`
- [[a2a-protocol]] — `transfer_context` specification
- [[pattern-progressive-handoff]] — state transfer at ownership boundaries
- [[pattern-dynamic-delegation]] — state transfer within delegation calls
- [[inter-agent-handoff-protocol]] — vault-level handoff protocol using state transfer
