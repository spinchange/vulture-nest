---
title: 'Pattern: Agent as Tool'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases:
  - agent-tool-pattern
  - opaque-agent-callable
---

# Pattern: Agent as Tool

**Intent:** Expose a complete agent — with its own internal orchestration, memory, and tools — as a single opaque callable in the tool roster of a parent LLM. The parent agent invokes it like any other tool, passing a natural-language request and receiving a natural-language result, with no visibility into the sub-agent's internal mechanics.

This pattern enables **modular composition**: complex agent subsystems are encapsulated behind a single tool interface, just as a library function hides its implementation. The parent grows by adding tool entries, not by growing its own context or instructions.

---

## Framework Implementations

### ADK — `AgentTool`
ADK provides `AgentTool` as a first-class primitive for wrapping an agent as a tool:

```python
from google.adk.tools import AgentTool
from google.adk.agents import LlmAgent

specialist = LlmAgent(
    name="contract_analyst",
    description="Analyzes legal contracts and identifies liability clauses.",
    tools=[read_file_tool, legal_db_tool]
)

coordinator = LlmAgent(
    name="deal_coordinator",
    tools=[
        AgentTool(agent=specialist),
        # specialist appears in tool list as "contract_analyst"
        # with specialist.description as the tool docstring
    ]
)
```

The parent LLM sees `contract_analyst` as a tool. When it invokes the tool, `AgentTool` runs the specialist's full execution loop (potentially multi-turn, with its own tool calls) and returns the specialist's final response as the tool result string.

### A2A — Discovery + Delegation
A2A's Agent Card provides the same interface as a tool declaration but at the protocol level. An orchestrating agent can query `/.well-known/agent-card.json` to discover an agent's Skills and treat each Skill as a callable:

```
Discover: GET /.well-known/agent-card.json
  → {"skills": [{"id": "analyze_contract", "description": "...", ...}]}

Invoke: POST /tasks (SendMessage with skill reference)
  → task_id → poll → COMPLETED → Artifacts
```

The orchestrator only sees the Skill's `id`, `description`, and `input_modes` / `output_modes`. The agent's internal implementation is fully opaque.

### Swarm — Functions as Lightweight Tools
Swarm does not distinguish between "agent-as-tool" and "function-as-tool" — any Python callable exposed in an agent's `functions` list is a tool. An agent can be wrapped as a tool by hiding it inside a function:

```python
def analyze_contract(contract_text: str) -> str:
    """Analyze a legal contract for liability clauses."""
    # Internal agent invocation hidden here
    response = contract_client.run(
        agent=contract_agent,
        messages=[{"role": "user", "content": contract_text}]
    )
    return response.messages[-1]["content"]

coordinator = Agent(functions=[analyze_contract])
```

This is the Swarm idiom for Agent-as-Tool: wrap the sub-agent call in a regular function and let Swarm treat it as any other tool.

---

## Canonical Structure

```
Parent LLM
  └─ [tool roster visible to LLM]
       ├─ search_web(query)          ← simple function tool
       ├─ read_file(path)            ← simple function tool
       └─ contract_analyst(request)  ← Agent-as-Tool (opaque)
                                           └─ internally: multi-turn LLM + DB + file tools
```

The parent never sees the sub-agent's intermediate steps, tool calls, or internal state. It only sees the final natural-language response.

---

## Composability Properties

| Property | Value |
|---|---|
| **Encapsulation** | Sub-agent internals invisible to parent |
| **Replaceability** | Swap implementations behind same tool name |
| **Depth** | Sub-agents can themselves use Agent-as-Tool recursively |
| **Scope** | Capability gating applies at invocation (see [[pattern-capability-gating]]) |

---

## When to Use vs. Direct Delegation

| Scenario | Use Agent-as-Tool | Use Direct Delegation |
|---|---|---|
| Parent LLM chooses which specialist to call | ✓ (LLM picks from tool roster) | — |
| Orchestrator always routes to same agent | — | ✓ (explicit, no LLM choice overhead) |
| Sub-agent interaction is multi-turn internally | ✓ (`AgentTool` handles loop) | ✓ (A2A handles loop) |
| Parent needs to inspect sub-agent's intermediate steps | — | ✓ (stream events) |

---

## References
- [[agent-development-kit]] — `AgentTool` specification
- [[a2a-protocol]] — Skill-based discovery as protocol-level tool roster
- [[lit-openai-swarm]] — function-wrapping idiom
- [[pattern-dynamic-delegation]] — contrast: explicit delegation vs. LLM-chosen tool invocation
- [[pattern-capability-gating]] — scope enforcement at tool invocation boundary
- [[agent-tools]] — general tool taxonomy in the vault
- [[pattern-progressive-handoff]]