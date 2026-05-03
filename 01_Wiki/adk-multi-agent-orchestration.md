---
title: [[agent-development-kit|ADK]] Multi-Agent Orchestration
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - adk-multi-agent
  - adk-agent-transfer
  - agent-as-a-tool
  - agent-hierarchy
type: permanent
---

# ADK Multi-Agent Orchestration

The [[agent-development-kit|ADK]] provides several mechanisms for composing multiple agents into complex, collaborative systems. These range from deterministic hierarchies to dynamic, LLM-driven delegation.

## 1. Composition Primitives

### Agent Hierarchy
Agents can be nested. A "Parent" agent can have multiple `sub_agents`. The framework automatically manages the parent-child relationship (e.g., `agent.parent_agent`).

### LLM-Driven Transfer (`transfer_to_agent`)
A dynamic routing mechanism where an `LlmAgent` decides to "handoff" the conversation to another agent.
*   **Mechanism:** The LLM generates a special tool call: `transfer_to_agent(agent_name='TargetAgent')`.
*   **Use Case:** A "Coordinator" agent routing a user query to "Billing", "Support", or "Sales" based on intent.

### Agent as a Tool (`AgentTool`)
Encapsulates an entire agent (and its sub-tree) as a standard tool that another agent can call.
*   **Mechanism:** The parent agent sees the sub-agent as a function (e.g., `ImageGen`). When called, the sub-agent executes, and its final response is returned to the parent as the tool result.
*   **Use Case:** An "Artist" agent calling an "ImageGenerator" agent to fulfill a specific sub-task.

## 2. Communication & State Sharing

### The `output_key` Mechanism
Agents can be configured with an `output_key`. When an agent finishes its execution, its final response is automatically saved to the `Session State` under this key.
*   **Importance:** This allows subsequent agents in a [[workflow-agents|SequentialAgent]] pipeline to access the results of previous steps.

### Shared Session State
All agents within a session share a single `State` object managed by the [[adk-session-service|Session Service]].

## 3. Advanced Multi-Agent Patterns

### Generator-Critic Pattern
Two agents within a `SequentialAgent`:
1.  **Generator:** Produces an initial draft and saves it to `state['draft']` via `output_key`.
2.  **Critic:** Reads `state['draft']`, evaluates it, and saves feedback to `state['review']`.
3.  *Optional:* A [[workflow-agents|LoopAgent]] can repeat this until the Critic is satisfied.

### Coordinator Pattern
A root `LlmAgent` acting as a router using `transfer_to_agent`. It maintains the high-level goal while delegating specific tasks to specialized sub-agents.

### Parallel Information Gathering
A `ParallelAgent` runs multiple "Fetcher" agents concurrently. A final "Synthesizer" agent reads the gathered data from the shared state to produce a unified response.

---
*Source: [[lit-adk-documentation]]*


## Related
- [[multi-agent-patterns-moc]]
- [[pattern-dynamic-delegation]]
