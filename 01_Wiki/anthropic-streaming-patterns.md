---
title: Anthropic Streaming Patterns
author: codex
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-streaming
  - anthropic-sse
source: "[[lit-anthropic-messages-api]]"
---

# Anthropic Streaming Patterns

Anthropic streaming is an **SSE-first response mode** for the Messages API. The client should parse ordered events and content blocks rather than assume a single completed JSON payload.

## Baseline event flow

1. `message_start`
2. `content_block_start`
3. one or more `content_block_delta`
4. `content_block_stop`
5. `message_delta`
6. `message_stop`

`ping` events may appear between content events and should be treated as keep-alives, not output.

## Tool-streaming behavior

- Tool-use streams can interleave normal text output with tool blocks.
- Tool arguments may arrive incrementally via `input_json_delta`.
- A streaming client may need to buffer partial JSON until the corresponding content block stops before attempting execution.

## Error-handling implications

- An Anthropic stream can return HTTP `200` and still fail later in the SSE stream.
- Completion should only be treated as successful after the stream reaches a valid terminal state.
- Long-running requests are better candidates for streaming than non-streaming synchronous waits, especially when networks may drop idle connections.

## Thinking Block Streaming

When extended thinking or adaptive thinking is enabled, thinking blocks appear before text blocks. Additional delta types:

- `thinking_delta` — incremental thinking content (analogous to `text_delta`)
- `signature_delta` — arrives just before `content_block_stop` for a thinking block; carries encrypted thinking for multi-turn continuity

Standard streaming sequence with thinking:

1. `content_block_start` (type: `thinking`)
2. one or more `content_block_delta` with `thinking_delta`
3. one `content_block_delta` with `signature_delta`
4. `content_block_stop`
5. `content_block_start` (type: `text`)
6. one or more `content_block_delta` with `text_delta`
7. `content_block_stop`
8. `message_delta`, `message_stop`

### Omitted thinking display

With `thinking.display: "omitted"`, no `thinking_delta` events are emitted. The thinking block still opens and closes, but carries only a `signature_delta`:

```
content_block_start (type: thinking, thinking: "")
content_block_delta (signature_delta: "EosnCkY...")
content_block_stop
content_block_start (type: text)
```

This reduces time-to-first-text-token at no cost reduction — the full thinking process runs and is billed; only streaming is suppressed. Use `omitted` in pipelines that do not surface thinking content to users.

### Redacted thinking blocks

Rarely, the API may return `redacted_thinking` blocks instead of `thinking` blocks. These have an opaque `data` field (not a `thinking` field). If filtering content blocks when round-tripping tool use responses, also pass through `redacted_thinking` blocks — filtering on `block.type == "thinking"` alone silently drops them.

## Design Guidance

- Keep streaming parsers block-aware rather than token-only.
- Separate transport events from semantic state transitions in client code.
- If the same client also supports tool use, it should treat streamed tool arguments and final `stop_reason` handling as part of a single state machine.
- When thinking is enabled, handle `thinking_delta` and `signature_delta` event types in addition to `text_delta`. Collect the full signature before the `content_block_stop` event.
- At `max_tokens` > 21,333, the SDK requires streaming to avoid HTTP timeouts on thinking-heavy requests. Use `.stream()` with `.get_final_message()` to get a complete `Message` without handling intermediate events.

## See also

- [[anthropic-messages-api]]
- [[anthropic-tool-use]]
- [[anthropic-adaptive-thinking]]
- [[anthropic-error-handling]]
