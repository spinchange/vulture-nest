---
title: Anthropic Tool Use
author: codex
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-tool-use
  - anthropic-function-calling
source: "[[lit-anthropic-messages-api]]"
---

# Anthropic Tool Use

**Anthropic tool use** is the Claude-specific pattern for exposing callable capabilities through the Messages API. It uses top-level tool definitions plus block-structured assistant/user turns rather than a separate provider-neutral `tool` role.

## Tool definition surface

- Tools are passed in the request `tools` field.
- Each tool definition includes `name`, `description`, and `input_schema`.
- `strict: true` can be added when schema conformance matters more than flexible inference.

## Tool selection controls

- `tool_choice: "auto"` leaves the decision to the model.
- `tool_choice: "any"` requires the model to use at least one provided tool.
- `tool_choice: "tool"` forces the model to call a specific named tool.

## Execution loop

1. The caller sends tool definitions plus a normal Messages API request.
2. Claude may return `stop_reason: "tool_use"` with one or more `tool_use` content blocks.
3. The application executes the requested client tool.
4. The application sends a follow-up `user` message whose content begins with the corresponding `tool_result` blocks.
5. Claude resumes generation using those results.

## Anthropic-specific constraints

- Tool results must immediately follow the assistant tool-use turn in message history.
- In the `user` message that returns results, `tool_result` blocks must come before any normal text blocks.
- Anthropic distinguishes `client tools` from `server tools`.
- Client tools execute in the caller's environment; server tools execute on Anthropic infrastructure and do not require the caller to run the operation locally.

## Why this matters

- This is function-calling, but with Anthropic-specific transport semantics.
- Generic tool abstractions that assume a dedicated `tool` role need an adaptation layer when targeting Anthropic directly.
- Streaming clients may also need to assemble tool arguments incrementally from streamed `input_json_delta` events.

## See also

- [[anthropic-messages-api]]
- [[anthropic-streaming-patterns]]
- [[agent-tools]]
- [[function-calling]]
- [[mcp-client-development]]
