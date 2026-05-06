---
title: Verbalized Sampling
author: codex
hostname: LYRA
date: 2026-04-26
status: active
type: permanent
aliases: [vs-sampling, llm-diversity-recovery, mode-collapse-mitigation]
---
# Verbalized Sampling

**Verbalized Sampling** is a training-free prompting technique for recovering diverse outputs from an aligned language model without changing the model weights. Its core claim is that many aligned models still retain diverse latent knowledge, but standard decoding repeatedly selects the same familiar answer.

## The Problem It Addresses

Aligned models often exhibit **mode collapse**: they converge on a narrow band of familiar, high-likelihood responses even when many valid and more creative alternatives exist.

The crucial claim from the material processed in this workflow is that the collapse is not only an algorithmic defect. It is amplified by **typicality bias** in human preference data:

- human raters reward fluent, familiar, easy-to-process answers
- RLHF sharpens those preferences into default response modes
- the model becomes safe and legible, but also generic

In this framing, alignment does not erase diversity. It suppresses access to it.

## Semantic Meaning

Verbalized sampling matters because it changes the interpretation of "boring AI." The model is not necessarily empty, weak, or undertrained. It may instead be **over-regularized toward recognizability**.

That makes the method conceptually important:

- it treats diversity as a retrieval problem, not just a training problem
- it reframes creativity loss as a byproduct of human preference compression
- it suggests that prompt-layer control can recover parts of the model's hidden option space

## Technical Implementation

The paper defines several implementation patterns for eliciting distributions:

### 1. The Standard Prompt
Request $k$ responses with verbalized probabilities in a structured format (JSON).
> "Generate 5 responses to the input prompt... Return the responses in JSON format... each includes a <text> and a numeric <probability> relative to the full distribution."

### 2. VS-CoT (Reasoning-Integrated)
Incorporates Chain-of-Thought before the distribution verbalization.
> "First, provide a single 'reasoning' field... detailing your step-by-step thought process. Then, return the output in JSON format with 5 responses and probabilities."

### 3. Diversity Tuning (P% Constraint)
Explicitly constraining the model to sample from low-probability regions.
> "Randomly sample from the distribution, where the probability of each response must be below [threshold]."

## Scaling & Compatibility

*   **Model Scale Law:** Performance gains from VS are positively correlated with model scale. Larger, more capable models (e.g., GPT-4.1, Claude 4) handle the cognitive burden of probability estimation and structured output better than smaller models.
*   **Orthogonality:** VS gains are **independent of temperature and top-p**. Combining VS with traditional temperature scaling or min-p sampling creates a superior diversity-quality Pareto front than using either method alone.

## Why It Fits This Vault

This concept belongs in the vault because it connects agent behavior, evaluation, and workflow engineering:

- **Prompt design** becomes a control surface for capability recovery.
- **Multi-agent loops** can use VS to generate diverse plans, mitigating "groupthink" or mode collapse in orchestration.
- **Synthetic Data** pipelines can use VS to generate diverse "hard negatives" (plausible but incorrect paths) for better model training.

---
## See Also
- [[verbalized-sample-skill]] (Operational Implementation)
- [[agent-evaluation]]
- [[orchestration-tradeoffs]]
- [[verbalized-sampling-experiment]]
- [[local-agent-environments]]
- [[lit-verbalized-sampling-paper]]

