---
title: "Literature: OpenTelemetry GenAI Semantic Conventions"
author: gemini-cli
date: 2026-05-18
status: active
type: literature
aliases: [otel-genai, gen-ai-semconv, gen-ai-telemetry]
---

# Literature: OpenTelemetry GenAI Semantic Conventions

The OpenTelemetry (OTel) GenAI semantic conventions provide a standardized namespace (`gen_ai`) for instrumenting Generative AI applications, ensuring that telemetry is portable across providers and observability backends.

## 1. Core Operation Attributes
Identifies the provider and the nature of the model interaction.

| Attribute | Description | Examples |
| :--- | :--- | :--- |
| `gen_ai.operation.name` | High-level operation type. | `chat`, `text_completion`, `embeddings` |
| `gen_ai.provider.name` | The GenAI vendor. | `openai`, `anthropic`, `aws.bedrock`, `google_vertex` |
| `gen_ai.request.model` | The requested model name. | `gpt-4o`, `claude-3-5-sonnet` |
| `gen_ai.response.model` | The actual model that served the response. | `gpt-4o-2024-05-13` |

## 2. Usage & Token Accounting
Standardized attributes for cost and consumption tracking.

- **`gen_ai.usage.input_tokens`**: Total tokens in the prompt.
- **`gen_ai.usage.output_tokens`**: Total tokens in the response.
- **`gen_ai.usage.reasoning.output_tokens`**: Tokens used for internal reasoning steps (e.g., OpenAI o1).
- **`gen_ai.usage.cache_read.input_tokens`**: Input tokens served from cache.
- **`gen_ai.usage.cache_creation.input_tokens`**: Input tokens used to build new cache entries.

## 3. Request Parameters (Experimental)
Attributes capturing the model configuration.

- **`gen_ai.request.temperature`**: Sampling temperature.
- **`gen_ai.request.top_p`**: Nucleus sampling value.
- **`gen_ai.request.max_tokens`**: Maximum tokens allowed in response.
- **`gen_ai.request.stop_sequences`**: Array of strings where the model stops.

## 4. Agent & Tool Execution
Attributes for multi-agent and tool-calling flows.

- **`gen_ai.agent.name`**: Identifier for the autonomous agent.
- **`gen_ai.tool.name`**: The name of the tool invoked (e.g., `web_search`).
- **`gen_ai.tool.call.id`**: Unique ID for the specific tool call instance.

## 5. Content Capture (Events)
OTel recommends capturing prompts and completions as **Events** (`gen_ai.client.inference.operation.details`) rather than span attributes to manage sensitive data (PII) more easily.
- **Attributes**: `gen_ai.input.messages`, `gen_ai.output.messages` (serialized JSON).

## 🚀 Implementation Tip
To opt-in to the latest experimental conventions in supported SDKs, set:
`OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental`

---
## References
- [[agent-observability]]
- [[lit-hf-agents-bonus]]
- [OpenTelemetry Semantic Conventions for GenAI](https://opentelemetry.io/docs/specs/semconv/gen-ai/)
