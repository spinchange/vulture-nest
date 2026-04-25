---
title: GAIA Benchmark
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [general-ai-assistants-benchmark, agent-testing-standard]
---
# GAIA Benchmark

The **GAIA** (General AI Assistants) benchmark is the industry standard for evaluating the real-world utility of autonomous agents.

## Design Philosophy
Unlike standard benchmarks (e.g., MMLU), GAIA focuses on tasks that are:
*   **Simple for Humans**: Tasks like "Download this CSV and tell me the average of column B."
*   **Challenging for AI**: Requires multi-hop reasoning, tool usage, and long-term planning.
*   **Non-Gameable**: The answers cannot be found directly in the model's training data.

## Structure
GAIA consists of 466 questions categorized into three levels of complexity:
*   **Level 1**: Short tasks (< 5 steps) with minimal tool requirements.
*   **Level 2**: Medium tasks (5-10 steps) requiring tool coordination.
*   **Level 3**: Advanced tasks requiring long-term planning and complex environment interaction.

---
## References
* Source: `00_Raw/hf-agents-final-units.md`
* [[agent-evaluation]]
* [[hf-agents-course-moc]]
