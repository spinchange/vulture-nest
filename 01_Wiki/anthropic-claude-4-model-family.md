---
title: Anthropic Claude 4 Model Family
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-4-models
  - claude-model-lineup
  - claude-opus-sonnet-haiku
source: "[[lit-anthropic-sdk-service-2026]]"
---

# Anthropic Claude 4 Model Family

The current Claude 4 family comprises three generally available models plus a restricted research preview. Model selection is the first architectural decision in any Anthropic integration.

## Current Model Lineup

| Model | API ID | Alias | Context | Max Output | Pricing (input/output per MTok) |
|---|---|---|---|---|---|
| **Claude Opus 4.7** | `claude-opus-4-7` | `claude-opus-4-7` | 1M tokens | 128k (sync); 300k (batch) | $5 / $25 |
| **Claude Sonnet 4.6** | `claude-sonnet-4-6` | `claude-sonnet-4-6` | 1M tokens | 64k (sync); 300k (batch) | $3 / $15 |
| **Claude Haiku 4.5** | `claude-haiku-4-5-20251001` | `claude-haiku-4-5` | 200k tokens | 64k | $1 / $5 |

Batch 300k output requires the `output-300k-2026-03-24` beta header. It is batch-only — unavailable on the synchronous Messages API.

## Model Characteristics

**Claude Opus 4.7** is the highest-capability generally available model. It offers a step-change improvement in agentic coding over Opus 4.6, 1M token context, and is the only model where adaptive thinking is the *only* supported thinking mode (manual `budget_tokens` returns `400`).

**Claude Sonnet 4.6** is the speed/intelligence balance point — fast, 1M context, supports both adaptive and manual thinking modes (manual is deprecated). It is the recommended default for most applications.

**Claude Haiku 4.5** is the fastest model with near-frontier intelligence. 200k context, no adaptive thinking support — only manual extended thinking with `budget_tokens`.

**Claude Mythos Preview** (`claude-mythos-preview`) is a separate research preview for defensive cybersecurity, offered under Project Glasswing. Access is invitation-only with no self-serve sign-up. Adaptive thinking is its default and only supported mode; `thinking.type: "disabled"` is not supported; `display` defaults to `"omitted"`.

## Thinking Support Matrix

| Model | Adaptive thinking | Manual thinking (`budget_tokens`) |
|---|---|---|
| Opus 4.7 | Required | Rejected (400 error) |
| Sonnet 4.6 | Recommended | Deprecated, functional |
| Opus 4.6 | Recommended | Deprecated, functional |
| Haiku 4.5 | Not supported | Supported |
| Mythos Preview | Default, only mode | Not applicable |

## Knowledge Cutoffs

| Model | Reliable knowledge cutoff | Training data cutoff |
|---|---|---|
| Opus 4.7 | Jan 2026 | Jan 2026 |
| Sonnet 4.6 | Aug 2025 | Jan 2026 |
| Haiku 4.5 | Feb 2025 | Jul 2025 |

## Retirement Dates

Claude Sonnet 4 (`claude-sonnet-4-20250514`) and Claude Opus 4 (`claude-opus-4-20250514`) — the earlier generation without the `.6`/`.7` suffix — retire **2026-06-15**. Migrate to Sonnet 4.6 or Opus 4.7 before that date.

## Platform Availability

All models are available via the Claude API, Amazon Bedrock, Google Vertex AI, and Microsoft Foundry. Bedrock offers global endpoints (dynamic routing) and regional endpoints (guaranteed data residency). Vertex AI offers global, multi-region, and regional endpoints.

US-only inference (`inference_geo: "us"`) on Opus 4.7, Opus 4.6, and newer models bills at 1.1× the standard token rate. Priority Tier capacity is drawn down at 1.1 tokens per input/output token for US-only inference requests.

Note: Claude Opus 4.7 on AWS is available through Claude in Amazon Bedrock (the Messages-API Bedrock endpoint), not the Bedrock Converse API.

## Models API

Query model capabilities and limits programmatically:

```bash
GET /v1/models
```

The response includes a `capabilities` object per model with fields: `batch`, `citations`, `code_execution`, `context_management`, `effort`, `image_input`, `pdf_input`, `structured_outputs`, `thinking`. This enables runtime capability checks rather than hardcoded model assumptions.

```python
for model in client.models.list():
    if model.capabilities.thinking.types.adaptive.supported:
        print(f"{model.id} supports adaptive thinking")
```

## See also

- [[anthropic-adaptive-thinking]]
- [[anthropic-message-batches]]
- [[anthropic-messages-api]]
- [[anthropic-prompt-caching]]
- [[lit-anthropic-sdk-service-2026]]
