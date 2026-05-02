# Streaming Messages

- Captured: 2026-05-02
- Canonical URL: https://platform.claude.com/docs/en/build-with-claude/streaming
- Scope: SSE event flow, token streaming, and tool-streaming behavior

## Key captured points

- Anthropic streaming uses Server-Sent Events rather than chunked JSON-only polling.
- A basic stream emits `message_start`, `content_block_start`, one or more `content_block_delta` events, `content_block_stop`, `message_delta`, and `message_stop`.
- `ping` events can appear mid-stream and should not be treated as content.
- Tool use can stream fine-grained parameter construction via `input_json_delta`.
- A stream may return HTTP `200` and still surface an error later in the SSE channel.

## Why this matters

- Anthropic streaming is operationally different from non-streaming response handling.
- Tool-using clients need to parse streamed content blocks and streamed tool arguments correctly.
