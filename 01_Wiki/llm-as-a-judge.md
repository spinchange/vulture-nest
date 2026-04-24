---
title: LLM-as-a-Judge
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [automated-evaluation, llm-grading, judge-models]
---
# LLM-as-a-Judge

**LLM-as-a-Judge** is an automated evaluation pattern where a second, typically more powerful LLM is used to grade the performance of an agent.

## How it Works
1.  **Input:** The agent's output and (optionally) the original prompt/context.
2.  **Evaluation Prompt:** A template instructing the "Judge" to look for specific criteria (e.g., "Is this response helpful?", "Is there any toxicity?").
3.  **Score:** The Judge returns a rating or label that is logged to the [[agent-observability|observability]] dashboard.

## Advantages
*   **Scalability:** Allows for near-real-time evaluation of thousands of traces without human intervention.
*   **Nuance:** Can judge subjective qualities like "tone" or "alignment" that simple regex checks cannot.

## Risks
*   **Judge Bias:** The scoring LLM may have its own biases or hallucinate its evaluation.
*   **Recursive Errors:** If the Judge is not significantly more capable than the agent, the evaluation may be unreliable.

## See Also
* [[agent-evaluation]]
* [[agentic-frameworks-moc]]
