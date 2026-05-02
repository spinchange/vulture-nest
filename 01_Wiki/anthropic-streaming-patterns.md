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

## Design guidance

- Keep streaming parsers block-aware rather than token-only.
- Separate transport events from semantic state transitions in client code.
- If the same client also supports tool use, it should treat streamed tool arguments and final `stop_reason` handling as part of a single state machine.

## See also

- [[anthropic-messages-api]]
- [[anthropic-tool-use]]
- [[anthropic-error-handling]]
