---
title: Agent Observability
author: gemini-cli
date: 2026-05-18
status: active
type: permanent
aliases: [agent-monitoring, agent-tracing, session-replays]
---
# Agent Observability

Agent observability is the practice of instrumenting agent systems to understand internal states through external signals — making non-deterministic, multi-step execution legible enough to debug, tune, and trust in production.

## 🏗️ The Three Pillars (Standardized)

Observability uses the **OpenTelemetry (OTel)** namespace `gen_ai` to ensure portable telemetry across providers and backends. See [[lit-otel-genai]] for the full attribute list.

**1. Logs** — Structured records of discrete events.
- Capture: Prompt strings, tool outputs, and raw model completions.
- Convention: Capture as **Events** (`gen_ai.client.inference.operation.details`) rather than span attributes to manage PII.

**2. Metrics** — Quantitative aggregates for health and performance.
- **Latency**: `gen_ai.operation.duration`.
- **Cost/Usage**: `gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens`, and `gen_ai.usage.cache_read.input_tokens`.
- **Reliability**: Tracking `gen_ai.response.finish_reasons` (e.g., identifying when agents hit `length` limits).

**3. Traces** — Causal chains mapping the execution graph.
- **Trace**: Represents one complete task (root ID).
- **Span**: An atomic step (LLM call, tool call, handoff).
- **Attributes**: Every span should carry `gen_ai.operation.name` (e.g., `chat`), `gen_ai.provider.name`, and `gen_ai.request.model`.

## 🛠️ Implementation Patterns

### Hierarchical Tracing (AgentOps)
In multi-agent systems, simple flat traces are insufficient. **AgentOps** implements a hierarchical span model for the **Agent Development Kit (ADK)**:
- **Parent Spans**: Represent the agent's full execution lifecycle (`adk.agent.<ClassName>`).
- **Child Spans**: Represent nested logic — sub-agents, LLM interactions (`adk.llm.<model>`), and tool usage (`adk.tool.<tool>`).
- **Mechanism**: AgentOps patches the native ADK telemetry to act as the authoritative source for these hierarchies. See [[lit-agentops-adk]].

### Span-Level Evaluation (Arize AX)
Modern observability moves beyond "did it work?" to "why did it work?". **Arize AX** enables **Span-Level Evaluation** to score internal reasoning:
- **Trajectory Eval**: Did the agent follow the "golden path" or loop?
- **Tool Accuracy**: Did the agent extract parameters correctly for the `gen_ai.tool.name`?
- **Groundedness**: Is the answer supported by the specific context spans?
- **Mechanism**: Results are logged back to the trace as **Annotations**. See [[lit-arize-ax]].

## ⚖️ Observability vs. Evaluation vs. Replay

| Signal | Question answered | Timing | Implementation |
|---|---|---|---|
| **Observability** | What is the system doing? | Real-time | OTel, AgentOps |
| **Evaluation** | Did it do the right thing? | Offline + Online | [[llm-as-a-judge]], Arize AX |
| **Session Replay** | What exactly happened in X? | Post-hoc | AgentOps Dashboard |

## 🚀 Where to Start
- **First-time instrumentation?** Use the `gen_ai` semantic conventions in [[lit-otel-genai]].
- **Using the ADK framework?** See [[lit-agentops-adk]] for auto-instrumentation.
- **Optimizing for accuracy/groundedness?** See [[lit-arize-ax]] for span evaluation.
- **Measuring quality at scale?** Go to [[agent-evaluation]] and [[llm-as-a-judge]].

---
## References
- [[lit-otel-genai]]
- [[lit-agentops-adk]]
- [[lit-arize-ax]]
- [[adk-callbacks-and-lifecycle]]
- [[agent-evaluation]]
- [[llm-as-a-judge]]
- [[agentic-frameworks-moc]]

