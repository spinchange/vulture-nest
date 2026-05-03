---
title: Anthropic Messages API
author: codex
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-messages-api
  - anthropic-api-messages
source: "[[lit-anthropic-messages-api]]"
---

# Anthropic Messages API

The **Anthropic Messages API** is the direct Claude API surface for prompt-response interactions. It is a stateless, block-structured interface built around `POST /v1/messages`, not a server-maintained chat session.

## Request contract

- Direct requests require `x-api-key`, `anthropic-version`, and `content-type: application/json`.
- The minimal useful request shape is `model`, `max_tokens`, and a `messages` array.
- Message history is caller-owned state. Each request resends the full conversation history needed for the next step.

## Message model

- Each message has a `role` and `content`.
- Content is block-oriented rather than plain text only, which lets Anthropic use text, image, `tool_use`, and `tool_result` blocks within the same high-level structure.
- Prior `assistant` turns may be synthetic, which supports controlled prefills and state reconstruction.

## Response model

- Responses return a top-level `message` object with `content`, `stop_reason`, `stop_sequence`, and `usage`.
- `stop_reason` is operationally important. `end_turn` means normal completion, while `tool_use` means the caller should execute one or more requested tools and continue the loop.
- Usage accounting is returned with the response and should be treated as the billing and observability source of truth for the request.

## Content Block Types

The API supports multiple content block types beyond text:
- `text` — standard text content
- `image` — inline or file-referenced images
- `document` — PDF, plain text, or file-referenced documents
- `tool_use` — Claude's tool call (in assistant turns)
- `tool_result` — tool execution result (in user turns)
- `thinking` — extended thinking summary or signature (in assistant turns when thinking is enabled)
- `redacted_thinking` — safety-redacted thinking block (opaque; must be round-tripped unchanged)

## Token Counting

The `POST /v1/messages/count_tokens` endpoint counts tokens for a planned request without executing it. It accepts the same parameters as the Messages endpoint and supports tools, images, documents, and system prompts. Use it before long or expensive calls to verify you are within context limits.

```python
count = client.messages.count_tokens(
    model="claude-opus-4-7",
    system="You are a helpful assistant.",
    messages=[{"role": "user", "content": "Hello"}],
)
print(count.input_tokens)
```

Token counting is especially valuable when building multi-turn conversations with thinking blocks, since thinking tokens from previous turns count as input tokens on Opus 4.5+ and Sonnet 4.6+.

## Implementation Implications

- Anthropic's API shape makes conversation state an application concern.
- Message construction should be treated as an explicit serialization step, especially when mixing text, images, tool content blocks, and thinking blocks.
- Provider-specific model behaviors such as prefill support can vary by model family; verify feature support against current docs before depending on them in production.
- When using extended thinking or large documents, use the token counting endpoint before calls to avoid context overflow errors.

## See also

- [[anthropic-tool-use]]
- [[anthropic-streaming-patterns]]
- [[anthropic-prompt-caching]]
- [[anthropic-adaptive-thinking]]
- [[anthropic-files-api]]
- [[chat-templates]]
- [[function-calling]]
