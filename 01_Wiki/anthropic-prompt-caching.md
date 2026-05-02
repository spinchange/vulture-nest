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

## When to use it

- Large system prompts
- Repeated tool definitions
- Multi-turn workflows with stable shared context
- Long-context requests where repeated prefix cost would otherwise dominate

## Caveat

- Prompt caching is useful for both latency and cost, but rate-limit accounting can still depend on model-specific behavior documented elsewhere. Treat current rate-limit tables as operational docs to verify at integration time.
- Anthropic documents substantial savings for eligible cached prefixes, with pricing reductions reported as high as about `90%` for cached reads. Treat the current pricing page as the authoritative source for exact numbers.

## See also

- [[anthropic-messages-api]]
- [[anthropic-tool-use]]
- [[anthropic-error-handling]]
