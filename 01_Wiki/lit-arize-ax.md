---
title: "Literature: Arize AX Span-Level Evaluation"
author: gemini-cli
date: 2026-05-18
status: active
type: literature
aliases: [arize-ax, arize-phoenix, span-evaluation]
---

# Literature: Arize AX Span-Level Evaluation

Arize AX (and the open-source **Phoenix**) focuses on **span-level evaluation**, enabling developers to score the internal reasoning steps of an agent rather than just the final output.

## 🧩 Core Primitives
- **Span**: A single unit of work (LLM call, tool call, retrieval).
- **Trace**: A collection of spans representing a complete task.
- **Annotation**: An evaluation result (score or label) attached to a specific span in the UI.

## 🛠️ Implementation Workflow

### 1. Instrumentation
Arize uses **OpenInference** (based on OpenTelemetry) for auto-instrumentation of frameworks like LangChain and LlamaIndex.
```python
from phoenix.otel import register
from openinference.instrumentation.openai import OpenAIInstrumentor

tracer_provider = register(project_name="agent-eval", endpoint="...")
OpenAIInstrumentor().instrument(tracer_provider=tracer_provider)
```

### 2. Retrieval & Query
Spans are retrieved into a DataFrame for analysis using the **SpanQuery** DSL.
```python
from phoenix.trace.dsl import SpanQuery
query = SpanQuery().where("span_kind == 'TOOL'")
tool_spans_df = px_client.spans.get_spans_dataframe(project_name="agent-eval", query=query)
```

### 3. Evaluation (The Judge)
Arize provides two main evaluation paths:
- **LLM-as-a-Judge**: Using a powerful model (e.g., GPT-4o) to evaluate specific logic (e.g., `HallucinationEvaluator`, `ToolCallAccuracy`).
- **Code-Based Evals**: Deterministic Python functions for objective checks (JSON validity, regex matching).

## 📊 Agent-Specific Metrics
- **Tool Selection Quality**: Did the agent select the correct tool for the user's intent?
- **Parameter Extraction**: Were the tool arguments correct and properly formatted?
- **Trajectory Evaluation**: Did the agent follow the intended logic path without looping?
- **Groundedness**: Is the answer supported by the retrieved context spans?

---
## References
- [[agent-observability]]
- [[agent-evaluation]]
- [[llm-as-a-judge]]
- [[lit-otel-genai]]
- [Arize Phoenix Documentation](https://docs.arize.com/phoenix/)
