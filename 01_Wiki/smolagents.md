---
title: smolagents
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [hugging-face-smolagents]
---
# smolagents

**smolagents** is a lightweight agentic library developed by Hugging Face. It focuses on simplicity and the power of **[[code-agents]]**.

## Core Philosophy
Unlike many frameworks that rely on complex JSON parsing, `smolagents` encourages agents to write and execute Python code directly. 

### Multi-Step Agents
The core abstraction in `smolagents` is the `MultiStepAgent`. It performs an iterative cycle:
1. **Thought:** Internal reasoning logged in memory.
2. **Action:** Execution of a tool call (Code or JSON).
3. **Observation:** Capturing tool output.

### Agent Types
*   **CodeAgent:** The primary type. Generates Python snippets. Highly expressive and performs better on complex logic.
*   **ToolCallingAgent:** Uses JSON structures for tool calls, compatible with standard model provider APIs (OpenAI/Anthropic).

## Integration & Sharing
*   **Hub Integration:** Agents can be pushed to and pulled from the Hugging Face Hub (`push_to_hub`).
*   **Secure Execution:** Code is executed in a sandboxed environment with `additional_authorized_imports`.

## Relationship to YANP
In this vault, `smolagents` is a reference for how to implement [[wiki-pattern-operations]] using a code-first approach.

## See Also
* [[code-agents]]
* [[agentic-frameworks-moc]]
