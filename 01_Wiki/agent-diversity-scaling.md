---
title: Agent Diversity Scaling
author: gemini-cli
date: 2026-05-06
status: active
type: permanent
aliases: [diversity-scaling-laws, capable-model-diversity]
---

# Agent Diversity Scaling

**Agent Diversity Scaling** refers to the empirical observation that the effectiveness of diversity-recovery techniques (like [[verbalized-sampling|Verbalized Sampling]]) is positively correlated with a model's size and reasoning capability.

## Core Observation
While alignment-induced **mode collapse** affects models of all sizes, larger and more capable models (e.g., GPT-4.1, Claude 4, Gemini 2.5 Pro) retain a significantly broader latent distribution than smaller models. These "reasoning-class" models are the primary beneficiaries of inference-time diversity steering.

### Scaling Trends
- **Cognitive Burden:** Diversity techniques often require structured output (JSON) and self-estimation of probabilities. Capable models handle this "probabilistic overhead" without degrading the quality of the primary task.
- **Latent Breadth:** Larger models have more "long-tail" knowledge that can be unlocked. Smaller models may simply lack the diverse options to begin with, leading to empty or repetitive distributions even when steered.

## Architectural Implications for Multi-Agent Systems
This scaling law suggests a **Sampler-Worker Pattern** for high-variance tasks (ideation, simulation, complex planning):

1.  **The Sampler (Large Model):** Use a high-capability model with [[verbalized-sampling]] to elicit a distribution of potential plans, personas, or solutions.
2.  **The Workers (Small Models):** Use faster, specialized models to execute, validate, or refine individual samples from that distribution.

This optimizes for both **breadth** (leveraging the large model's latent diversity) and **throughput** (using small models for the bulk of the work).

## Relation to Orchestration
In [[multi-agent-patterns-moc|Multi-Agent Orchestration]], ignoring these scaling laws leads to "Groupthink" where an orchestrator repeatedly selects the same sub-optimal path. Incorporating diversity-aware scaling ensures that the system explores the full capability lattice of its constituent agents.

---
## See Also
- [[verbalized-sampling]]
- [[agentic-frameworks-moc]]
- [[capability-lattice-spec]]
- [[lit-verbalized-sampling-paper]]
