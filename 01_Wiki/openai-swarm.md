---
title: OpenAI Swarm
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - swarm
  - handoff-pattern
  - routine-pattern
type: permanent
---

# OpenAI Swarm

**OpenAI Swarm** is an experimental, educational framework for orchestrating multiple agents. It prioritizes a lightweight, stateless approach to multi-agent systems, focusing on **Handoffs** and **Routines**.

## Core Primitives

### 1. The `Agent`
An `Agent` encapsulates:
*   **Instructions:** The system prompt (can be a string or a callable returning a string).
*   **Functions:** A list of [[python]] functions the agent can call.
*   **Model:** The underlying LLM (defaults to `gpt-4o`).

### 2. Handoffs
A handoff occurs when an agent's function returns another `Agent` object.
*   **Mechanism:** When the framework sees a returned `Agent`, it switches the active agent to the new one and continues the conversation with the new agent's instructions.
*   **Use Case:** Triage agents routing users to specialized departments (e.g., "Billing", "Refunds").

### 3. Context Variables
Shared state passed into `client.run()`.
*   **Access:** Functions can declare `context_variables` as an argument to receive the current state.
*   **Updates:** Functions can return a `Result` object to update these variables.

## Key Features

### Stateless Execution
The `client.run()` loop is stateless. It processes the current turn, handles any function calls, manages handoffs, and returns the final response along with the updated `context_variables` and active `agent`. The caller is responsible for persisting this state.

### `Result` Object
A powerful return type for functions that allows for atomic updates:
```python
return Result(
    value="Final answer for the user",
    agent=next_agent,           # The Handoff
    context_variables={"key": "val"} # State update
)
```

## Comparison: Swarm vs. [[agent-development-kit|ADK]]
| Feature | OpenAI Swarm | [[agent-development-kit|ADK]] |
| :--- | :--- | :--- |
| **State Management** | External (Stateless) | Internal ([[adk-session-service|Session Service]]) |
| **Handoff Type** | Return-based (returns `Agent`) | Tool-based (`transfer_to_agent`) |
| **Orchestration** | Dynamic (Loop-based) | Mixed (Deterministic & Dynamic) |
| **Complexity** | Minimal | High (Full SDK) |

---
*Source: [[lit-openai-swarm]]*

