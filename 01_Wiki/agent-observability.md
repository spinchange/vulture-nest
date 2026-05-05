---
title: Agent Observability
author: claude-sonnet-4-6
date: 2026-05-04
status: active
type: permanent
aliases: [agent-monitoring, agent-tracing, session-replays]
---
# Agent Observability

Agent observability is the practice of instrumenting agent systems to understand internal states through external signals — making non-deterministic, multi-step execution legible enough to debug, tune, and trust in production.

## The Three Pillars

**Logs** — structured records of discrete events: tool invocations, model calls, errors, state changes. Cheapest to collect; queryable after the fact.

**Metrics** — quantitative aggregates over time:
- Token usage and cumulative cost
- Latency per step and end-to-end
- Tool error rate and success rate
- User feedback signals (explicit ratings, implicit retry behavior)

**Traces** — causal chains that link events into a complete execution graph:
- A **trace** represents one complete task (from the first user message to the final agent response)
- A **span** represents one atomic step within that trace — an LLM call, a single tool execution, or an agent handoff
- Together they answer "where in the pipeline did this fail, and why?"

## Observability vs. Evaluation vs. Replay

| Signal | Question answered | Timing |
|---|---|---|
| **Observability** (logs/metrics/traces) | What is the system doing right now? | Real-time |
| **Evaluation** | Did it do the right thing? | Offline + Online |
| **Session replay** | What exactly happened in interaction X? | Post-hoc |

Observability is the instrumentation layer that makes evaluation and replay possible. Without traces, evaluation is blind to *why* an output was wrong — only that it was.

## Instrumentation Standards

**OpenTelemetry (OTel)** is the industry standard for collecting telemetry data. The GenAI semantic conventions define portable span attributes for LLM calls:
- `gen_ai.system` — the model provider
- `gen_ai.request.model` — model identifier
- `gen_ai.usage.input_tokens` / `gen_ai.usage.output_tokens` — token accounting

OTel-compatible instrumentation keeps traces portable across observability backends (Jaeger, Honeycomb, Arize AX, custom pipelines).

**AgentOps** provides drop-in session replay and a unified metrics dashboard with minimal code changes, often replacing native framework telemetry as a single source of truth.

**Arize AX** targets production-grade tracing and quality evaluation at scale, with built-in LLM-as-a-judge scoring.

## Instrumentation by Framework

### ADK
ADK exposes lifecycle hooks as the primary observability surface. The key hooks for tracing are:
- `on_agent_start` / `on_agent_finish` — agent-boundary events, good for outer span boundaries
- `on_tool_start` / `on_tool_end` — tool-boundary events, good for individual spans
- `before_model_callback` — fires before each LLM call; use to capture input shape before the round-trip

All hooks receive a `CallbackContext` carrying `agent_name`, `session_id`, and `state` — enough context to emit structured spans without modifying core agent logic. See [[adk-callbacks-and-lifecycle]].

### Anthropic
Streaming events carry inline telemetry: `message_start` contains input token counts, `message_delta` delivers output totals, and `tool_use` content blocks identify which tool was invoked and with what arguments. For high-volume pipelines, batch status polling aggregates this across many requests. See [[anthropic-streaming-patterns]] and [[anthropic-message-batches]].

### Multi-agent orchestration
In multi-agent pipelines, trace correlation across agent boundaries is the hard problem. Each agent leg should emit spans that share a root trace ID, so failures can be pinpointed to a specific handoff or delegation edge rather than just the final output. See [[graph-orchestration]] and [[adk-multi-agent-orchestration]].

## Where to Start

- **Instrumenting an agent for the first time?** Start here, then go to [[adk-callbacks-and-lifecycle]] for the hook implementation.
- **Measuring output quality, not execution flow?** Go to [[agent-evaluation]] (offline benchmarking + online monitoring loop).
- **ADK trajectory and multi-turn benchmarking?** Go to [[adk-evaluation-framework]].
- **Automated output scoring?** Go to [[llm-as-a-judge]].

---
## References
- Sources: `00_Raw/hf-agents-bonus2.md`, `00_Raw/adk-documentation.md`
- [[lit-hf-agents-bonus]]
- [[adk-callbacks-and-lifecycle]]
- [[adk-evaluation-framework]]
- [[agent-evaluation]]
- [[llm-as-a-judge]]
- [[anthropic-streaming-patterns]]
- [[anthropic-message-batches]]
- [[graph-orchestration]]
- [[adk-multi-agent-orchestration]]
- [[agentic-frameworks-moc]]
- [[adk-moc]]

