# Anthropic API Overview

- Captured: 2026-05-02
- Canonical URL: https://platform.claude.com/docs/en/api/overview
- Scope: direct Claude API fundamentals for authentication, headers, request sizing, and platform caveats

## Key captured points

- The Claude API is a REST API at `https://api.anthropic.com`.
- Direct model access for this batch is centered on the `Messages API` at `POST /v1/messages`.
- Direct API requests require `x-api-key`, `anthropic-version`, and `content-type: application/json`.
- Anthropic's official SDKs handle header management, retries, streaming, and connection management.
- Standard request-size limits are `32 MB` for Messages and Token Counting, `256 MB` for Message Batches, and `500 MB` for Files.
- Every response includes `request-id` and `anthropic-organization-id`.
- Partner platforms may differ from the direct API in feature timing and request-size limits.

## Why this matters

- This page defines the provider-specific transport contract around the Messages API.
- It is the root source for authentication and request-shape assumptions used by the rest of this batch.
