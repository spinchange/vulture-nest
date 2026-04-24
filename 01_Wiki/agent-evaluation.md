---
title: Agent Evaluation
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [agent-testing, online-vs-offline-eval, benchmarking-agents]
---
# Agent Evaluation

**Evaluation** is the systematic process of analyzing telemetry data to judge an agent's performance and identify areas for improvement.

## Evaluation Strategies
### 1. Offline Evaluation (Benchmarking)
Performed in controlled environments using curated datasets (e.g., GSM8K for math).
*   **Goal:** Guard against regressions before deployment.
*   **Benefit:** Repeatable and provides a "Ground Truth" for accuracy.

### 2. Online Evaluation (Production Monitoring)
Performed on live user interactions.
*   **Goal:** Capture real-world performance and model drift.
*   **Benefit:** Identifies edge cases not present in test datasets.

## The Continuous Improvement Loop
1.  **Offline Eval:** Test new version on benchmarks.
2.  **Deploy:** Release to production.
3.  **Online Monitor:** Capture failures and user feedback.
4.  **Iterate:** Add new failure cases to the offline test set.

## See Also
* [[agent-observability]]
* [[llm-as-a-judge]]
* [[agentic-frameworks-moc]]
