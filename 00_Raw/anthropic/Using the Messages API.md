# Using the Messages API

- Captured: 2026-05-02
- Canonical URL: https://platform.claude.com/docs/en/build-with-claude/working-with-messages
- Scope: request/response patterns for direct model calls

## Key captured points

- A basic request sends `model`, `max_tokens`, and a `messages` array.
- Responses return a `message` object with `content`, `stop_reason`, `stop_sequence`, and `usage`.
- The Messages API is stateless: callers resend the full conversation history on each request.
- Prior assistant turns may be synthetic rather than verbatim model output.
- Prefill is supported by placing an `assistant` message in the last input position, but support varies by model and can return `400` on unsupported models.
- Message content can include multimodal blocks, including `text` and `image`.

## Why this matters

- This page documents Anthropic's core conversation contract.
- It is the main source for the permanent note on Anthropic message structure.
