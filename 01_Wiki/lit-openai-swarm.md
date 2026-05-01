---
title: 'Literature: OpenAI Swarm and Agents SDK'
author: gemini-cli
date: '2026-05-01'
status: active
aliases:
  - swarm-source
  - openai-swarm-docs
type: literature
---

# Literature: OpenAI Swarm and Agents SDK

**Source:** `00_Raw/openai-agents-and-swarm.md`

## Overview
This material documents OpenAI's evolution of multi-agent orchestration, starting with the experimental **Swarm** framework and culminating in the production-ready **OpenAI Agents SDK**.

## Swarm: Lightweight Orchestration (Experimental)
Swarm focuses on making agent coordination lightweight and highly controllable. It is explicitly **stateless** (running on the client) and relies on the Chat Completions API.

### Core Primitives
1.  **Agent**: Encapsulates `instructions` and `functions`. Agents are not persistent "Assistants" but transient configurations for a specific turn or task.
2.  **Handoff**: The process where an agent transfers a conversation to another agent. This is achieved by a function returning a new `Agent` object.
3.  **Context Variables**: A shared dictionary used to pass state between agents and functions.

### The Execution Loop (`client.run()`)
1.  Get completion from the active agent.
2.  Execute tool calls and append results.
3.  Switch agent if a handoff is detected.
4.  Update context variables.
5.  Repeat until no more function calls occur.

## OpenAI Agents SDK (Production)
The Agents SDK is the "production-ready evolution" of Swarm. It adds support for:
-   **Managed Workflows**: Hosted threads and persistent state management.
-   **Observability**: Built-in tracing and debugging.
-   **Safety**: Integrated guardrails and human-in-the-loop patterns.
-   **MCP Support**: Native integration with the Model Context Protocol.

## Rationale for Usage
-   **Swarm** is ideal for educational purposes and lightweight, client-side orchestration where the developer wants total control over state.
-   **Agents SDK** is the standard for building scalable, durable applications with complex multi-agent logic and enterprise-grade safety.

---
## See Also
- [[openai-swarm]]
- [[openai-agents-sdk]]
- [[orchestration-tradeoffs]]
- [[agentic-frameworks-moc]]
