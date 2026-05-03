---
title: Anthropic Prompt Caching
author: codex
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-prompt-caching
  - anthropic-context-caching
source: "[[lit-anthropic-messages-api]]"
---

# Anthropic Prompt Caching

**Anthropic prompt caching** is a direct API feature for reusing stable prompt prefixes across requests. It is a provider-level context-management primitive, not just an application-side memoization trick.

## Core mechanism

- Prompt caching uses `cache_control` markers with `type: "ephemeral"`.
- Anthropic supports both automatic caching and explicit block-level cache breakpoints.
- Automatic caching uses a `5-minute` TTL by default.
- A `1-hour` TTL is available at a higher documented input-token price.
- Prompt caching is most useful once the reusable prefix is large enough to justify the extra machinery; Anthropic documents a minimum threshold around `1,024` tokens, with exact base limits varying by model.

## Structural constraints

- Automatic caching is compatible with explicit breakpoints, but the combined system has only `4` breakpoint slots.
- Ordering rules still matter: prompt blocks must remain stable enough for reuse to work.
- The caching system still applies the documented `20-block` lookback behavior.
- Conflicting cache-control configurations can produce `400` errors.

## When to Use It

- Large system prompts
- Repeated tool definitions
- Multi-turn workflows with stable shared context
- Long-context requests where repeated prefix cost would otherwise dominate

## 1-Hour Cache Duration

The default 5-minute TTL is too short for extended thinking sessions (which can exceed 5 minutes) and batch jobs (which typically take 30–60 minutes). Use the 1-hour TTL when:
- Prompt caching is combined with thinking (`budget_tokens` > ~32k or long adaptive thinking sessions)
- Using the Message Batches API with shared context across requests

```json
{"type": "text", "text": "...", "cache_control": {"type": "ephemeral", "ttl": "1h"}}
```

The 1-hour TTL is priced higher than the 5-minute TTL — verify current pricing before deploying.

## Thinking Mode Interaction

Prompt caching and thinking modes interact with specific invalidation rules:

- **Within the same mode:** Consecutive requests in the same thinking mode (`adaptive`, `enabled`, or `disabled`) preserve message cache breakpoints.
- **Across modes:** Switching between `adaptive`, `enabled`, and `disabled` invalidates message cache breakpoints.
- **System prompts and tool definitions:** Remain cached regardless of thinking mode changes.

This means a system prompt cache investment is stable even when you change thinking configuration. Message history cache is not.

**Thinking blocks as cached input tokens:**  
On Opus 4.5+ and Sonnet 4.6+, thinking blocks from previous turns are preserved in context by default. When these thinking blocks are passed back with tool results, they count as cached input tokens. In long tool-use chains, this can create non-trivial input token costs even when "the prompt hasn't changed."

## Batch Processing Interaction

Batch processing and prompt caching discounts stack. Cache hits are best-effort in batches (concurrent async processing means requests may not share a warm cache). Expected cache hit rates range from 30% to 98% depending on traffic pattern.

To maximize batch cache hits:
1. Use identical `cache_control` blocks in every request.
2. Use the 1-hour TTL (batch processing typically exceeds 5 minutes).
3. Structure requests to maximize shared prefix length.

## Caveats

- Rate-limit accounting can still depend on model-specific behavior documented elsewhere. Treat current rate-limit tables as operational docs to verify at integration time.
- Anthropic documents substantial savings for eligible cached prefixes, with pricing reductions reported as high as about `90%` for cached reads. Treat the current pricing page as the authoritative source for exact numbers.
- `max_tokens: 0` (cache pre-warming) is incompatible with extended thinking (requires `budget_tokens < max_tokens`) and with the Batches API.

## See also

- [[anthropic-messages-api]]
- [[anthropic-tool-use]]
- [[anthropic-adaptive-thinking]]
- [[anthropic-message-batches]]
- [[anthropic-error-handling]]
