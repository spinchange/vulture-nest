---
title: Agent Observability
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [agent-monitoring, agent-tracing, session-replays]
---
# Agent Observability

Agent Observability is the practice of tracking, monitoring, and analyzing the behavior of autonomous agents to ensure reliability, safety, and performance.

## Core Metrics
* **Token Usage**: Tracking cost and efficiency across sessions.
* **Latency**: Measuring response times and tool execution duration.
* **Success Rate**: Evaluating how often the agent achieves the intended goal.
* **Tool Accuracy**: Identifying failures or misuse of external functions and APIs.

## Monitoring Patterns
1. **Session Replays**: Recording full conversational turns and internal reasoning (traces) to debug unexpected behavior.
2. **OpenTelemetry Tracing**: Using standardized protocols to map the flow of execution from the initial prompt through multiple agent handoffs and tool calls.
3. **Callbacks**: Implementing lifecycle hooks (e.g., `on_tool_start`, `on_agent_finish`) to log granular events without modifying core logic.

## Integration Platforms
* **AgentOps**: Provides session replays, metrics, and automated monitoring with minimal code changes. It often replaces native framework telemetry to act as a unified source of truth.
* **Arize AX**: A production-grade platform for tracing and performance evaluation at scale.
* **BigQuery Analytics**: Logging operational events to a data warehouse for deep offline analysis and auditability.

---
## References
* Source: `00_Raw/adk-documentation.md`
* [[agent-evaluation]]
* [[agentic-frameworks-moc]]
