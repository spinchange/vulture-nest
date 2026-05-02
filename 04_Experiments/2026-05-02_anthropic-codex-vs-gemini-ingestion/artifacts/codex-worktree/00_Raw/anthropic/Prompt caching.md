# Prompt caching

- Captured: 2026-05-02
- Canonical URL: https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- Scope: explicit and automatic cache controls for repeated prompt prefixes

## Key captured points

- Prompt caching uses `cache_control` markers with `type: "ephemeral"`.
- Automatic caching defaults to a `5-minute` TTL.
- A `1-hour` TTL is supported at `2x` base input-token price.
- Automatic caching can be combined with block-level caching, but it still consumes one of the `4` available breakpoint slots.
- Context ordering requirements and the `20-block` lookback window still apply.
- Conflicting cache-control settings can produce `400` errors.

## Why this matters

- Prompt caching is a concrete Anthropic context-management primitive rather than a generic prompt-engineering suggestion.
