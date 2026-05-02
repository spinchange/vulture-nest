---
title: Anthropic Error Handling
author: codex
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-api-errors
  - anthropic-rate-limits
source: "[[lit-anthropic-messages-api]]"
---

# Anthropic Error Handling

Anthropic's direct API documents a predictable HTTP error surface, but production handling still needs to account for request-size limits, acceleration limits, and streaming-specific failure modes.

## Core HTTP failure classes

- `400 invalid_request_error`: malformed or invalid request content
- `401 authentication_error`: invalid or missing API key
- `402 billing_error`: billing or payment issue
- `403 permission_error`: authenticated but not authorized for the resource
- `404 not_found_error`: missing resource
- `413 request_too_large`: payload exceeds endpoint byte limits
- `429 rate_limit_error`: tier or burst limit exceeded
- `500 api_error`: internal server error
- `504 timeout_error`: request timed out while processing
- `529 overloaded_error`: temporary provider-side overload

## Operational patterns

- Log and surface Anthropic `request_id` values because they are the primary support and trace handle.
- Treat `413` as a payload-design problem, not a retry candidate.
- Treat `429` as a backoff-and-shape-traffic problem; Anthropic documents burst enforcement and acceleration limits.
- Treat `529` as transient provider overload and retry with backoff.
- Consider streaming or Message Batches for long-running work instead of large synchronous non-streaming calls.

## Rate-limit model

- Rate limits are tied to usage tiers and enforced at the organization level.
- Short bursts can fail even when minute-level averages look safe.
- Workspace-level limits can be configured, but organization-level limits still apply.
- Rate-limit response headers such as `anthropic-ratelimit-requests-remaining` provide runtime feedback about remaining quota and are useful for adaptive throttling.

## Streaming caveat

- With SSE, an error can occur after the initial HTTP success response.
- Streaming code therefore needs an application-level completion check, not just an HTTP-status check.

## See also

- [[anthropic-streaming-patterns]]
- [[anthropic-prompt-caching]]
- [[agent-observability]]
