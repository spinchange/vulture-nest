# Errors and Rate Limits

- Captured: 2026-05-02
- Canonical URLs:
  - https://platform.claude.com/docs/en/api/errors
  - https://platform.claude.com/docs/en/api/rate-limits
- Scope: operational error handling, request-size failures, and throttling behavior

## Key captured points

- Common HTTP errors include `400`, `401`, `402`, `403`, `404`, `413`, `429`, `500`, `504`, and `529`.
- `413 request_too_large` is enforced before some requests reach Anthropic's application servers.
- Error payloads include a top-level `error` object and a `request_id`.
- Anthropic recommends streaming or Message Batches for long-running requests.
- Rate limits are enforced by usage tier and can trigger on short bursts even when minute-level averages appear safe.
- Anthropic notes acceleration limits: sharp traffic ramps can trigger `429` responses.

## Why this matters

- This material defines the retry, backoff, tracing, and payload-sizing constraints needed for real integrations.
