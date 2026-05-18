---
title: "Literature: AgentOps Integration (ADK)"
author: gemini-cli
date: 2026-05-18
status: active
type: literature
aliases: [lit-agentops, agentops-adk]
---

# Literature: AgentOps Integration (ADK)

[AgentOps](https://www.agentops.ai) provides production-grade observability for autonomous agents, offering session replays, hierarchical tracing, and cost/latency tracking.

## 🛠️ ADK Integration Strategy
AgentOps employs a "patch and wrap" strategy to provide seamless observability for the **Agent Development Kit (ADK)**.

### 1. Neutralizing Native Telemetry
AgentOps detects ADK and patches its internal OpenTelemetry tracer (`trace.get_tracer('gcp.vertex.agent')`) with a `NoOpTracer`. This prevents duplicate traces and ensures AgentOps remains the authoritative source.

### 2. Hierarchical Span Mapping
AgentOps wraps key ADK methods to create a logical parent-child relationship:
- **Agent Spans** (`adk.agent.<ClassName>`): Parent spans created when `run_async` starts.
- **LLM Spans** (`adk.llm.<model_name>`): Child spans created for model calls. Captures prompts, parameters, and token usage via `_finalize_model_response_event`.
- **Tool Spans** (`adk.tool.<tool_name>`): Child spans created for tool executions. Captures inputs and returned results.

### 3. Attribute Extraction
AgentOps reuses ADK's internal data extraction logic (patching functions like `trace_tool_call` and `trace_call_llm`) to attach rich metadata as attributes to the active AgentOps span.

## 🚀 Getting Started (Python)
```python
import agentops
import os

agentops.init(
    api_key=os.getenv("AGENTOPS_API_KEY"),
    trace_name="my-adk-trace" # Optional
)
# AgentOps now automatically instruments all ADK Runner and Agent calls.
```

## 📊 Visualization Features
- **Waterfall of Spans**: Displays the sequence and duration of nested sub-agent and tool calls.
- **Session Replay**: Allows developers to re-watch the agent's decision-making process.
- **Cost Tracking**: Aggregates token usage across multiple providers into a single dollar-denominated metric.

---
## References
- Source: `00_Raw/adk-documentation.md` (Lines 16087-16209)
- [[agent-observability]]
- [[adk-moc]]
- [[lit-otel-genai]]
