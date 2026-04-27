---
title: 'Pattern: Human-in-the-Loop'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases:
  - hitl-pattern
  - mid-task-escalation
  - agent-pause-resume
---

# Pattern: Human-in-the-Loop

**Intent:** An agent pauses mid-task at a decision point it cannot resolve autonomously — lacking information, authorization, or confidence — surfaces a structured question to a human, and resumes from the exact paused state after the human responds. No task teardown or restart required.

This pattern is the boundary between autonomous execution and supervised execution. A well-implemented HITL loop is invisible when not needed and unambiguous when it fires.

---

## Framework Implementations

### A2A — `INPUT_REQUIRED` and `AUTH_REQUIRED`

A2A defines two dedicated task states for human escalation:

```
SUBMITTED → WORKING → INPUT_REQUIRED
                     (agent pauses, delivers question to orchestrator/user)
                     ← (client sends follow-up with answer)
                     → WORKING (task resumes from paused state)
```

**`INPUT_REQUIRED`:** The agent needs information it cannot obtain autonomously.
```json
{
  "state": "INPUT_REQUIRED",
  "message": {
    "role": "agent",
    "parts": [{ "kind": "text", "text": "To process this refund, I need your billing address. Please provide it." }]
  }
}
```

**`AUTH_REQUIRED`:** The agent needs a credential or permission grant it does not hold.
```json
{
  "state": "AUTH_REQUIRED",
  "message": {
    "role": "agent",
    "parts": [{ "kind": "text", "text": "This action requires manager approval. Please provide a signed authorization token." }]
  }
}
```

The client responds via `SendMessage` with the answer/credential; the agent transitions back to `WORKING` without re-running previous steps.

### ADK — Callbacks
ADK uses **callbacks** to inject human-in-the-loop logic at specific execution points:

```python
from google.adk.agents import CallbackContext

def before_tool_call(callback_context: CallbackContext, tool_name: str, args: dict):
    if tool_name == "delete_record" and not args.get("confirmed"):
        # Pause: inject a confirmation request into the conversation
        callback_context.state["pending_confirmation"] = {
            "tool": tool_name, "args": args
        }
        return "Please confirm: delete record {id}? (yes/no)"
    return None  # proceed normally
```

When the callback returns a non-None value, the runner surfaces it to the user as an agent message and waits for the next user input before continuing. The pending state is preserved in `session.state`.

### Swarm — `execute_tools=False`

Swarm's `client.run()` accepts an `execute_tools=False` flag that causes the run loop to pause and return the pending tool call for external inspection or human approval:

```python
response = client.run(
    agent=agent,
    messages=messages,
    execute_tools=False  # pause before executing tool calls
)

if response.messages[-1].get("tool_calls"):
    # Surface to human for review
    approved = human_review(response.messages[-1]["tool_calls"])
    if approved:
        # Resume: execute the approved tool call and continue
        response = client.run(agent=agent, messages=response.messages, execute_tools=True)
```

This is a coarser mechanism than A2A's dedicated states — it pauses at every tool call rather than at specific decision points — but it enables an approval workflow without modifying agent logic.

---

## Canonical Structure

```
[Agent reaches decision point]
  └─ Requires: {information | authorization | confirmation}
  └─ Cannot resolve autonomously

[Pause]
  └─ Serialize current working state (see [[pattern-state-transfer]])
  └─ Emit structured question / escalation to human layer
  └─ Transition to waiting state (INPUT_REQUIRED / AUTH_REQUIRED / paused)

[Human responds]
  └─ Human provides: {answer | credential | approval}
  └─ Input delivered to agent

[Resume]
  └─ Agent reads response from state
  └─ Continues from exact pause point
  └─ No prior steps re-executed
```

---

## Design Principles

1.  **Stateful pause:** The agent must preserve all working state before pausing — nothing should be re-computed after resume. This requires the [[pattern-state-transfer]] pattern to be correctly implemented.
2.  **Structured questions:** HITL escalations should emit a specific, answerable question — not a vague "I need help." Include: what decision is needed, what context the human needs to decide, and what format the answer should take.
3.  **Authorization vs. information:** Distinguish between `INPUT_REQUIRED` (the agent lacks data) and `AUTH_REQUIRED` (the agent lacks permission). These require different human workflows — data retrieval vs. approval workflows.
4.  **Timeout policy:** Define what happens if the human does not respond within a time bound. Options: transition to `FAILED`, escalate to a supervisor agent, or cancel. Never hang indefinitely.

---

## When to Use HITL vs. Autonomous Fallback

| Situation | HITL | Autonomous Fallback |
|---|---|---|
| Missing required credential | ✓ | — (cannot proceed without auth) |
| Ambiguous user intent (low confidence) | ✓ | Possible (pick highest-confidence path, note assumption) |
| Destructive or irreversible action | ✓ (confirmation) | Only for low-stakes actions |
| Information available via search/tool | — | ✓ (try retrieval first) |

---

## References
- [[a2a-protocol]] — INPUT_REQUIRED and AUTH_REQUIRED state machine
- [[agent-development-kit]] — Callbacks for mid-execution pause
- [[lit-openai-swarm]] — `execute_tools=False` approval workflow
- [[hitl-ui-patterns]] — UI patterns for presenting HITL decisions to users
- [[pattern-state-transfer]] — preserving state before pause
- [[pattern-capability-gating]] — AUTH_REQUIRED as a runtime capability gate
- [[community-protocol-trust-substrate]] — trust model governing when HITL is mandatory
