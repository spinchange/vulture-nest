---
title: ReAct Pattern
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [reasoning-and-acting, chain-of-thought-actions]
---
# ReAct Pattern

**ReAct** (Reasoning + Acting) is a prompting technique that enables LLMs to generate both reasoning traces and task-specific actions in an interleaved manner.

## How it Works
Instead of generating a direct answer, the model is prompted to follow a structured sequence:
1.  **Thought**: "I need to find the capital of France first."
2.  **Action**: `search(query="capital of France")`
3.  **Observation**: "Paris is the capital of France."
4.  **Thought**: "Now I have the answer."
5.  **Final Answer**: "The capital of France is Paris."

## Benefits
*   **Grounding**: The model bases its final answer on external facts rather than internal weights.
*   **Error Correction**: If an observation contradicts a previous thought, the model can adjust its logic in the next "Thought" step.
*   **Interpretability**: Provides a human-readable log of *why* an agent took a specific action.

---
## References
* Source: `00_Raw/hf-agents-course-unit1.md`
* [[agent-thought-cycle]]
* [[agent-tools]]
