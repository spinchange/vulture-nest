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

## Core Opinion

This loop is the smallest useful model of an agent runtime. It matters in the Nest because most higher-level frameworks differ less in whether they use this cycle than in how much of it they expose, constrain, or automate.

The practical reading is:

- "thought" is the model selecting a next move from the current state
- "action" is the runtime boundary where the model leaves pure text and invokes a capability
- "observation" is the new state returned to the loop, which either grounds the next step or reveals failure

Once that is clear, notes like [[react-pattern]], [[agent-tools]], [[graph-orchestration]], and [[workflow-agents]] become easier to place.

## The Loop
1.  **Thought**: The LLM reasons about the current state and decides which step to take next.
2.  **Action**: The agent executes a command or calls a tool based on the reasoning (e.g., `search_web`).
3.  **Observation**: The system returns the result of the action (e.g., "The weather is 72°F") as a new message to the LLM.

## Evolution: ReAct
This cycle is often implemented using the [[react-pattern]], where the reasoning and acting are interleaved in a single context window to maintain a logical "chain of thought."

## Decision Rule

Start from `[[agent-thought-cycle]]` when your question is about the minimal logic of agency:

- "What actually makes a tool-using system an agent instead of just a completion?"
- "Where does failure usually enter the loop?"
- "How do reasoning, tool use, and returned state fit together?"

If the question is about a framework packaging this loop, route to [[agent-development-kit]], [[openai-agents-sdk]], or [[smolagents]]. If the question is about deterministic control over multiple loops, route to [[graph-orchestration]] or [[workflow-agents]].

## Failure Modes

Most agent bugs are distortions of one phase of this cycle:

- bad **Thought**: the model plans against the wrong objective or hallucinates what it already knows
- bad **Action**: the tool contract is vague, the chosen tool is wrong, or the runtime boundary is unsafe
- bad **Observation**: the returned result is incomplete, noisy, or not written back into state in a usable form

That is why [[agent-tools]] and [[agent-actions]] matter operationally more than generic "reasoning" descriptions.

## Relationship to the Rest of the Vault

- [[react-pattern]] is the canonical prompt/runtime expression of this loop.
- [[agent-tools]] explains the action surface in more detail.
- [[graph-orchestration]] explains what happens when many such loops are wired together explicitly.
- [[workflow-agents]] shows the deterministic counterpart where flow control is moved out of the model.

---
## References
* Source: `00_Raw/hf-agents-course-unit1.md`
* [[agentic-frameworks-moc]]
* [[react-pattern]]

* [[ps-vulture-search]] (Context Packet generation for 'Thought' phase)
- [[agent-actions]]
