---
title: Agent Thought Cycle
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [thought-action-observation, ooda-loop-for-agents]
---
# Agent Thought Cycle

The **Thought-Action-Observation** cycle is the fundamental workflow of an autonomous agent, enabling it to reason about a goal and refine its approach based on environment feedback.

## The Loop
1.  **Thought**: The LLM reasons about the current state and decides which step to take next.
2.  **Action**: The agent executes a command or calls a tool based on the reasoning (e.g., `search_web`).
3.  **Observation**: The system returns the result of the action (e.g., "The weather is 72°F") as a new message to the LLM.

## Evolution: ReAct
This cycle is often implemented using the [[react-pattern]], where the reasoning and acting are interleaved in a single context window to maintain a logical "chain of thought."

---
## References
* Source: `00_Raw/hf-agents-course-unit1.md`
* [[agentic-frameworks-moc]]
* [[react-pattern]]

* [[ps-vulture-search]] (Context Packet generation for 'Thought' phase)
- [[agent-actions]]
