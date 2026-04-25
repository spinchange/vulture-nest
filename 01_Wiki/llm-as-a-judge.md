---
title: LLM-as-a-Judge
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [automated-grading, llm-evaluation]
---
# LLM-as-a-Judge

**LLM-as-a-Judge** is a technique where a secondary, more capable model (e.g., GPT-4o, Claude 3.5 Sonnet) is used to automatically evaluate and score the outputs of an agent.

## Why use it?
*   **Scalability**: Manually grading thousands of agent turns is impossible.
*   **Nuance**: Unlike keyword matching, a model can judge if an answer is "helpful," "safe," or "concise."
*   **Benchmarking**: Provides a consistent metric for comparing different agent architectures or prompts.

## Metrics
Common scores provided by an LLM Judge:
1.  **Grounding**: Did the agent use the provided facts?
2.  **Completeness**: Did the agent answer all parts of the user query?
3.  **Toxicity**: Is the response harmful or biased?
4.  **Efficiency**: Did the agent take too many steps to reach the answer?

---
## References
* Source: `00_Raw/hf-agents-bonus2.md`
* [[agent-evaluation]]
* [[hf-agents-course-moc]]
