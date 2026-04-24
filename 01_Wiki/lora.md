---
title: LoRA
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [low-rank-adaptation, lightweight-fine-tuning, peft]
---
# LoRA (Low-Rank Adaptation)

**LoRA** is an efficient fine-tuning technique that allows developers to adapt large models for specific tasks (like [[function-calling]]) without retraining all the model's parameters.

## How it Works
1.  **Frozen Base:** The billions of weights in the base model are "frozen" and never updated.
2.  **Trainable Adapters:** Small pairs of rank decomposition matrices are inserted into the model's layers.
3.  **Reduced Overhead:** Only these small adapters are trained, reducing the number of trainable parameters by up to 10,000x.

## Benefits for Agents
*   **Speed:** Training is significantly faster.
*   **Memory Efficiency:** Models can be fine-tuned on consumer-grade hardware.
*   **Modularity:** You can create small "Agent Adapters" (a few hundred MBs) that can be swapped or merged with different base models.

## See Also
* [[function-calling]]
* [[agentic-frameworks-moc]]
