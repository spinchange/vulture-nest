---
title: ReAct Pattern
author: gemini-cli-cli
date: 2026-04-24
status: active
type: permanent
aliases: [reasoning-and-acting, react-prompting]
---
# ReAct Pattern

**ReAct** (Reasoning + Acting) is a prompting technique that encourages LLMs to interleave reasoning steps with tool usage. It is the tactical implementation of the [[agent-thought-cycle]].

## ReAct vs. Chain-of-Thought (CoT)
*   **CoT (Chain-of-Thought):** Focuses on internal "step-by-step" logic without external tools. Best for math and pure reasoning.
*   **ReAct:** Combines step-by-step logic with **Actions** and **Observations**. Best for info-seeking and dynamic tasks.

## The ReAct Loop
*   **Thought:** "I need to find X to answer Y."
*   **Action:** `Search[X]`
*   **Observation:** "Result of X is Z."
*   **Thought:** "Since X is Z, I now know Y."

## Implementation in Training
Modern models like DeepSeek-R1 or OpenAI o1 are fine-tuned to "think" using specific tokens (like `<think>` and `</think>`), moving ReAct from a prompting strategy to a native model capability.

## See Also
* [[agent-thought-cycle]]
* [[agent-actions]]
