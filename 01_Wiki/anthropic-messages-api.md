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

## Implementation implications

- Anthropic's API shape makes conversation state an application concern.
- Message construction should be treated as an explicit serialization step, especially when mixing text, images, and tool content blocks.
- Provider-specific model behaviors such as prefill support can vary by model family, so integrations should verify feature support against current docs before depending on them in production.

## See also

- [[anthropic-tool-use]]
- [[anthropic-streaming-patterns]]
- [[anthropic-prompt-caching]]
- [[chat-templates]]
- [[function-calling]]
