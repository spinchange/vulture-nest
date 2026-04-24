# Hugging Face Agents Course - Bonus Unit 2: Observability & Evaluation

Source: [Hugging Face Agents Course](https://hf.co/learn/agents-course/bonus-unit2/introduction)

## Summary
This unit focuses on making AI agents transparent and measurable. It covers the technical instrumentation of agents (Traces/Spans) and the strategic evaluation of their performance (Online/Offline).

## Key Concepts
*   **Observability:** Understanding internal agent states via external signals (Logs, Metrics, Traces).
*   **Traces & Spans:** A trace represents a complete task; spans are individual steps (LLM calls, tool execution) within that task.
*   **Evaluation:** The process of analyzing data to determine how well an agent is performing.
    *   **Offline:** Using curated benchmarks (e.g., GSM8K) before deployment.
    *   **Online:** Monitoring real-world interactions and user feedback in production.
*   **LLM-as-a-Judge:** Using a separate, powerful LLM to automatically score an agent's outputs for accuracy, toxicity, or helpfulness.
*   **Metrics:** Latency, Token Costs, Error Rates, and User Feedback (Explicit/Implicit).
*   **OpenTelemetry:** The industry standard for instrumenting code to collect telemetry data.
