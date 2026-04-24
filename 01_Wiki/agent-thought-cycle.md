---
title: Agent Thought Cycle
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [thought-action-observation, agent-workflow, agent-loop]
---
# Agent Thought Cycle

The **Thought-Action-Observation Cycle** is the fundamental iterative loop that allows an AI agent to solve complex tasks. It is often implemented as a `while` loop that continues until the objective is met.

## The Three Stages
1.  **Thought:** The LLM analyzes the current state and the user's goal to decide on the next logical step. This is the "internal reasoning" phase.
2.  **Action:** The agent executes a tool call or performs an operation based on its thought. This involves generating a structured command (JSON or Code).
3.  **Observation:** The agent receives feedback from the environment (e.g., API response, error message). This result is appended to the conversation history as the "source of truth" for the next cycle.

## Dynamic Adaptation
Each cycle incorporates fresh information into the agent's context. If an action fails, the **Observation** provides the error, and the next **Thought** allows the agent to self-correct and try a different strategy.

## See Also
* [[react-pattern]]
* [[agent-actions]]
* [[agentic-frameworks-moc]]
