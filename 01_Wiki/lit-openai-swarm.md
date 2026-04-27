---
title: 'Literature: OpenAI Swarm and Agents SDK'
author: gemini-cli
date: '2026-04-26'
status: draft
aliases:
  - swarm-source
  - openai-swarm-docs
type: literature
---

# Literature: OpenAI Swarm and Agents SDK

## Source Metadata
*   **File:** `00_Raw/openai-agents-and-swarm.md`
*   **Topic:** Multi-agent orchestration patterns from OpenAI.
*   **Status:** Swarm is experimental/educational; Agents SDK is production-ready.

## Swarm: Key Concepts
Swarm is a lightweight, stateless framework for orchestrating multiple agents. It prioritizes simplicity and visibility of agent interactions.
*   **[[openai-swarm#agent|Agent]]:** A collection of instructions and tools.
*   **[[openai-swarm#handoff|Handoff]]:** An agent transferring control to another agent by returning it from a function.
*   **[[openai-swarm#context-variables|Context Variables]]:** Shared state passed between agents and functions.

## Agents SDK: Key Concepts
A more robust, production-oriented approach to agent development.
*   **Managed Workflows:** Support for hosted paths and complex state.
*   **Production Readiness:** Focus on stability, observability, and scaling.

## Initial Comparison (vs. [[agent-development-kit|ADK]])
*   **Statelessness:** Swarm is explicitly stateless (the caller manages state), whereas ADK has a built-in `SessionService`.
*   **Handoffs:** Swarm handoffs are "return-based" (a function returns an `Agent` object). ADK uses a tool-based `transfer_to_agent`.

## Next Steps for Synthesis
1.  Extract the mechanics of [[openai-swarm#handoff|Swarm handoffs]].
2.  Define the [[openai-swarm#agent|Swarm agent]] primitive.
3.  Detail the use of [[openai-swarm#context-variables|Swarm context variables]].
4.  Map the [[openai-agents-sdk]] patterns.

## Related
- [[orchestration-tradeoffs]]

