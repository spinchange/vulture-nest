---
title: OpenAI Swarm
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [swarm, openai-swarm-experimental]
---
# OpenAI Swarm

OpenAI Swarm is an experimental, educational framework designed to explore lightweight **multi-agent orchestration**. It focuses on making agent coordination and execution highly controllable and easily testable.

> [!IMPORTANT]
> Swarm is considered experimental and has been largely superseded by the [OpenAI Agents SDK](https://github.com/openai/openai-agents-python), which is the production-ready evolution of these patterns.

## Core Primitives
Swarm operates on two primary abstractions:
1. **Agents**: An `Agent` encompasses `instructions` and `tools`.
2. **Handoffs**: An `Agent` can choose to hand off a conversation to another `Agent` at any point by returning the next agent from a function call.

## Philosophy
* **Lightweight**: Minimal overhead for agent coordination.
* **Stateless**: Swarm runs almost entirely on the client and does not store state between calls (unlike the Assistants API).
* **Controllable**: Developers have full control over the handoff logic and agent interactions.

## Swarm vs. Assistants API
* **Swarm**: Best for large numbers of independent capabilities that are difficult to encode in a single prompt. It is stateless and client-side.
* **Assistants API**: Best for fully-hosted threads, built-in memory management, and retrieval.

## Implementation Pattern
The "Handoff" pattern in Swarm is implemented by functions that return another `Agent` object. This allows for dynamic routing based on user input or agent reasoning.

```python
def transfer_to_agent_b():
    return agent_b
```

---
## References
* Source: `00_Raw/openai-agents-and-swarm.md`
* [[multi-agent-systems]]
* [[agentic-frameworks-moc]]
