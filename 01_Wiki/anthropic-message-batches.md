---
title: Anthropic Message Batches
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-batch-api
  - anthropic-batches
  - message-batches-api
source: "[[lit-anthropic-advanced-capabilities]]"
---

# Anthropic Message Batches

The **Message Batches API** is Anthropic's asynchronous execution layer for high-volume workflows. It processes requests independently, returns results when the batch completes, and prices everything at 50% of synchronous API rates.

## When to Use Batches

Batches are the right choice when:
- You need to process large volumes of data (evaluations, content analysis, bulk generation)
- Immediate responses are not required
- Cost matters more than latency
- Thinking budgets exceed 32k tokens (long synchronous requests risk timeout; use batches)

Not suitable for: interactive use cases, streaming output, or workloads that require immediate responses.

## Batch Limits

| Limit | Value |
|---|---|
| Requests per batch | 100,000 |
| Batch size | 256 MB |
| Processing window | Most complete < 1 hour; max 24 hours |
| Result availability | 29 days after batch creation (not after processing end) |
| `max_tokens: 0` | Not supported (cache pre-warming is incompatible with batches) |

Batches expire if processing does not complete within 24 hours. Results expire 29 days after the batch's `created_at` timestamp — not after `ended_at`.

## Request Shape

Each batched request has a `custom_id` and a `params` object with standard Messages API parameters:

```python
from anthropic.types.message_create_params import MessageCreateParamsNonStreaming
from anthropic.types.messages.batch_create_params import Request

batch = client.messages.batches.create(
    requests=[
        Request(
            custom_id="req-001",
            params=MessageCreateParamsNonStreaming(
                model="claude-opus-4-7",
                max_tokens=1024,
                messages=[{"role": "user", "content": "Hello"}],
            ),
        ),
    ]
)
```

Validation of `params` is asynchronous — errors appear in individual result records, not at submission time. Dry-run single requests against the Messages API before batching.

## Result Types

| Type | Description | Billing |
|---|---|---|
| `succeeded` | Message completed, result included | Billed |
| `errored` | Invalid request or server error | Not billed |
| `canceled` | Canceled before processing | Not billed |
| `expired` | Not processed within 24-hour window | Not billed |

**Results are not ordered.** Always match results to requests using `custom_id`.

```python
for result in client.messages.batches.results(batch_id):
    match result.result.type:
        case "succeeded":
            # result.result.message is the full Message object
        case "errored":
            if result.result.error.error.type == "invalid_request_error":
                # fix and resubmit
            # else server error — safe to retry
```

## Polling

```python
while True:
    batch = client.messages.batches.retrieve(batch_id)
    if batch.processing_status == "ended":
        break
    time.sleep(60)
```

`processing_status` transitions: `in_progress` → `ended` (or `canceling` → `ended` if canceled).

## Extended Output (Beta)

The `output-300k-2026-03-24` beta header raises `max_tokens` to **300,000** for batches using Opus 4.7, Opus 4.6, or Sonnet 4.6. This is batch-only — unavailable on the synchronous Messages API.

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

A single 300k-token generation can take over an hour — plan within the 24-hour processing window. Standard batch pricing applies (50% discount).

## Prompt Caching + Batches

Batch and cache discounts stack. Caching within batches is best-effort (concurrent async processing means requests may not share cache state). Expected cache hit rates: 30–98% depending on traffic pattern.

To maximize cache hits:
1. Include identical `cache_control` blocks in every request in the batch.
2. Use the 1-hour cache TTL — the default 5-minute TTL expires before most batches complete.
3. Structure requests to share as much prefix as possible.

See [[anthropic-prompt-caching]] for cache control mechanics.

## Data Retention

Batch request and response data is retained for 29 days. Not ZDR-eligible. Delete batches explicitly via `DELETE /v1/messages/batches/{batch_id}` (cancel first if in-progress).

## See also

- [[anthropic-messages-api]]
- [[anthropic-prompt-caching]]
- [[anthropic-adaptive-thinking]]
- [[lit-anthropic-advanced-capabilities]]
