---
title: "Literature: Anthropic Messages API"
author: codex
date: "2026-05-02"
status: active
type: literature
source:
  - "00_Raw/anthropic/API Overview.md"
  - "00_Raw/anthropic/Using the Messages API.md"
  - "00_Raw/anthropic/Streaming Messages.md"
  - "00_Raw/anthropic/Tool use with Claude.md"
  - "00_Raw/anthropic/Errors and Rate Limits.md"
  - "00_Raw/anthropic/Prompt caching.md"
aliases:
  - lit-anthropic-api
  - lit-anthropic-messages
---

# Literature: Anthropic Messages API

This literature note captures the first bounded Anthropic documentation batch for the direct Claude API. The corpus is intentionally narrow: authentication and request model, message structure, streaming, tool use, error handling, rate limits, and prompt caching.

## Core request model

- The direct Claude API is a REST interface at `https://api.anthropic.com`.
- Direct requests require `x-api-key`, `anthropic-version`, and `content-type: application/json`.
- The primary interaction surface is the `Messages API`, which expects a `messages` array plus request controls such as `model` and `max_tokens`.
- Responses include a provider request identifier, usage accounting, and a `stop_reason` that governs the next step in the client loop.

## Message semantics

- Anthropic's Messages API is stateless: callers resend the full conversation history on each request.
- Input turns can include synthetic `assistant` messages, which makes the API implementation-facing rather than chat-session-preserving by default.
- Content is block-based rather than plain-text-only, which matters for multimodal inputs and tool use.
- Prefill remains possible through a final `assistant` input turn, but support is model-conditional and documented as unavailable for some newer models.

## Streaming and tool use

- Streaming uses SSE with an event sequence centered on `message_start`, `content_block_*`, `message_delta`, and `message_stop`.
- Tool use is integrated into the same message/block structure rather than a separate tool-role channel.
- For client-side tools, the assistant emits `tool_use` blocks with `stop_reason: "tool_use"`, the caller executes the tool, and the caller returns `tool_result` blocks in the next `user` message.
- Anthropic distinguishes client tools from server tools explicitly, which is a real provider-specific operational boundary.

## Operational constraints

- Request-size limits, acceleration limits, and organization-tier rate limits are part of the documented contract, not incidental implementation details.
- Anthropic explicitly documents that SSE streams can fail after an HTTP `200`, so transport-level success is not sufficient for completion success.
- Prompt caching is a first-class context-management feature with explicit `cache_control` markers, short default TTLs, and limited cache-breakpoint slots.

## Caveats

- Model support and some feature surfaces are conditional by model family and can change over time.
- Rate-limit tables and prefill support are especially subject to change; permanent notes should preserve the pattern, not freeze transient per-model numbers unless operationally necessary.
- Partner platforms such as Bedrock, Vertex AI, and Azure can differ from the direct Anthropic API in feature timing and payload limits.

## Connections

- [[anthropic-messages-api]]
- [[anthropic-tool-use]]
- [[anthropic-streaming-patterns]]
- [[anthropic-error-handling]]
- [[anthropic-prompt-caching]]
- [[agent-tools]]
- [[function-calling]]
