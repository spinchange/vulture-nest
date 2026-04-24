---
title: Agent Observability
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [agent-telemetry, traces-and-spans, llm-monitoring]
---
# Agent Observability

**Observability** is the practice of monitoring an agent's internal operations through external signals like logs, metrics, and traces. It transforms the agent from a "black box" into a transparent system.

## Traces and Spans
*   **Trace:** Represents the entire lifecycle of a single request or task (e.g., "Synthesize this file").
*   **Span:** A discrete unit of work within a trace (e.g., a single `grep_search` call or an LLM completion).

## Key Metrics
1.  **Latency:** The time taken for individual steps and the overall task.
2.  **Token Costs:** Tracking usage per model call to manage financial overhead.
3.  **Error Rates:** Identifying where tool calls or model generations fail.
4.  **User Feedback:** Capturing explicit (thumbs up/down) and implicit (rephrased queries) signals.

## Tools
Frameworks like [[smolagents]] use **OpenTelemetry** to export these signals to dashboards like **Langfuse** or **Arize Phoenix**.

## See Also
* [[agent-evaluation]]
* [[agentic-frameworks-moc]]
