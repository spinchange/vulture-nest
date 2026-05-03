---
title: "Literature: Anthropic Async and Data APIs (Batch 2, Sub-batch C)"
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: literature
aliases:
  - lit-anthropic-async-data
  - anthropic-async-data-apis-lit
source: "00_Raw/anthropic/ (sub-batch C: batch-processing, files-api, token-counting-api, models-api-reference)"
---

# Literature: Anthropic Async and Data APIs (Batch 2, Sub-batch C)

Synthesis of four Anthropic documentation pages covering batch processing, the Files API, token counting, and the Models API list endpoint. Crawled 2026-05-02 as part of Batch 2 ingestion.

---

## Message Batches API

The Message Batches API is the asynchronous execution layer. It processes requests independently, at 50% of synchronous API rates, completing most batches within 1 hour.

### When Batches Are Appropriate

- Large-volume workflows (evaluations, content analysis, bulk generation)
- Cost-sensitive workloads where latency is not a constraint
- Thinking budgets above 32k tokens (long synchronous requests risk timeout)

Not suitable for: interactive use, streaming, or immediate-response requirements.

### Hard Limits

| Limit | Value |
|---|---|
| Requests per batch | 100,000 |
| Batch size | 256 MB |
| Processing window | Most complete < 1 hour; hard cap at 24 hours |
| Result availability | 29 days from `created_at` (not from `ended_at`) |
| `max_tokens: 0` | Not supported (cache pre-warming incompatible with batches) |

Results expire 29 days after batch *creation*, not after processing ends. This matters for long-running batches.

### Extended Output (Beta)

The `output-300k-2026-03-24` beta header raises `max_tokens` to 300,000 for batches using Opus 4.7, Opus 4.6, or Sonnet 4.6. This is batch-only — unavailable synchronously.

```python
batch = client.beta.messages.batches.create(
    betas=["output-300k-2026-03-24"],
    requests=[Request(
        custom_id="long-form",
        params=MessageCreateParamsNonStreaming(
            model="claude-opus-4-7",
            max_tokens=300_000,
            messages=[{"role": "user", "content": "..."}],
        ),
    )],
)
```

A single 300k-token generation can take over an hour — plan within the 24-hour window.

### Result Types

| Type | Billing |
|---|---|
| `succeeded` | Billed |
| `errored` | Not billed |
| `canceled` | Not billed |
| `expired` | Not billed |

Results are unordered. Always match results to requests via `custom_id`. Validation of `params` is asynchronous — errors appear in result records, not at submission time. Dry-run single requests against the synchronous API first.

### Prompt Caching with Batches

Batch and cache discounts stack. Caching within batches is best-effort (concurrent async processing means requests may not share cache state). Expected hit rates: 30–98% depending on traffic pattern.

To maximize hits:
1. Include identical `cache_control` blocks in every request.
2. Use the 1-hour cache TTL — the 5-minute default expires before most batches complete.
3. Maximize shared prefix across requests.

### Not ZDR-Eligible

The Message Batches API is not eligible for Zero Data Retention. Data is retained under the feature's standard retention policy.

---

## Files API

The Files API allows pre-uploading large documents — PDFs, text files, images — and referencing them by file ID in multiple Messages API requests. This avoids re-transmitting large files on every request that uses them.

**Beta header:** `files-api-2025-04-14`

**Platform availability:** Direct Anthropic API only. Not available on Amazon Bedrock or Google Vertex AI.

**Architectural pattern:** Upload once; reference by `file_id` in content blocks. File IDs are stable across requests within their retention window. Useful for:
- Repeated analysis of the same document over multiple requests
- Long PDFs that would otherwise push token budgets on every request
- Batch workflows where all requests use the same source material

See [[anthropic-files-api]] for the full permanent note.

---

## Token Counting API

The token counting endpoint (`POST /v1/messages/count_tokens`) predicts token usage before sending a request. This is useful for:
- Staying within context window limits before committing to a request
- Comparing prompt variants by cost
- Monitoring context growth in long-running workflows

The endpoint accepts the same parameters as the Messages API. It returns `input_tokens` (the count of tokens the prompt would consume). When context editing is enabled, the response also includes `context_management.original_input_tokens` (the pre-editing count) alongside `input_tokens` (the post-editing count).

**Beta header:** `token-counting-2024-11-01`

Token counting does not make a generation; it is a read-only sizing call. It does not affect caching or incur generation costs.

---

## Models API (List)

`GET /v1/models` returns a paginated list of available models with a `capabilities` object per model:

| Capability field | What it reports |
|---|---|
| `batch.supported` | Whether model supports Message Batches API |
| `citations.supported` | Citation generation support |
| `code_execution.supported` | Code execution tool support |
| `context_management.*` | Supported context management strategies (`clear_thinking_20251015`, `clear_tool_uses_20250919`, `compact_20260112`) |
| `effort.*` | Supported effort levels (`low`, `medium`, `high`, `xhigh`, `max`) |
| `image_input.supported` | Image content blocks accepted |
| `pdf_input.supported` | PDF content blocks accepted |
| `structured_outputs.supported` | Structured output / JSON mode / strict tools |
| `thinking.supported`, `thinking.types.*` | Thinking support and which types (`adaptive`, `enabled`) |

Also returned: `max_input_tokens`, `max_tokens`, `created_at`, `display_name`.

**Architectural note:** The Models API is the canonical programmatic source of truth for model capabilities. Hardcoding capability assumptions by model name creates maintenance debt as capabilities change. Runtime capability checks via the Models API are the resilient alternative.

Pagination uses cursor-based navigation (`after_id`, `before_id`). More recently released models appear first.

---

## Stable Patterns vs. Operational Details

**Stable (architecture):**
- Message Batches API as the async execution layer; 50% discount is structural
- `custom_id` as the correlation mechanism for unordered results
- Files API as upload-once/reference-many pattern; Anthropic API only (not Bedrock/Vertex)
- Token counting as a read-only sizing call before committing to generation
- Models API capabilities object as the programmatic capability surface

**Operational (likely to drift):**
- 29-day result retention window (policy, not architecture)
- `output-300k-2026-03-24` beta header availability and eligibility
- Files API beta header date and platform expansion
- Specific capability fields returned by the Models API (new capabilities added as models evolve)

---

## Notes for Synthesis

This sub-batch is the primary source for [[anthropic-message-batches]] and [[anthropic-files-api]] (both written in the advanced-capabilities batch). The Models API material is new; it complements [[anthropic-claude-4-model-family]] (capability matrix) and could eventually support a standalone `anthropic-models-api.md` note if deeper integration is needed.
