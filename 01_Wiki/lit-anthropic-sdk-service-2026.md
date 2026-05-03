---
title: "Literature: Anthropic SDK and Service Configuration (Batch 2, Sub-batch E)"
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: literature
aliases:
  - lit-anthropic-sdk-service
  - anthropic-sdk-service-lit
source: "00_Raw/anthropic/ (sub-batch E: client-sdks, models-overview, api-service-tiers, api-versioning, api-beta-headers, context-editing)"
---

# Literature: Anthropic SDK and Service Configuration (Batch 2, Sub-batch E)

Synthesis of six Anthropic documentation pages covering client SDKs, model lineup, service tiers, API versioning, beta headers, and context editing. Crawled 2026-05-02 as part of Batch 2 ingestion. See the source provenance headers for page and chunk IDs.

---

## Client SDKs

Anthropic provides official SDKs for Python, TypeScript, Java, Go, Ruby, C#, and PHP. All SDKs provide idiomatic interfaces, type safety, streaming, retry handling, and error management. Platform support covers the Claude API, Amazon Bedrock, Google Vertex AI, and Microsoft Foundry.

**Version requirements (current as of crawl date):**

| SDK | Minimum version |
|---|---|
| Python | 3.9+ |
| TypeScript | 4.9+ (Node.js 20+) |
| Java | 8+ |
| Go | 1.23+ |
| Ruby | 3.2.0+ |
| C# | .NET Standard 2.0 |
| PHP | 8.1.0+ |

Beta features are accessed via the `beta` namespace in any SDK, passing `betas=["feature-name"]` alongside the request.

**Architectural note:** The SDK beta namespace is the stable integration point for accessing pre-release API surfaces. Beta headers flow through the SDK to the API; application code does not need to set raw HTTP headers when using an SDK.

---

## Model Lineup (Claude 4 Family)

Current generally available Claude 4 models as of crawl date. See [[anthropic-claude-4-model-family]] for the full capability matrix.

| Model | Context | Max output (sync) | Starting price (input/output per MTok) |
|---|---|---|---|
| Claude Opus 4.7 | 1M | 128k | $5 / $25 |
| Claude Sonnet 4.6 | 1M | 64k | $3 / $15 |
| Claude Haiku 4.5 | 200k | 64k | $1 / $5 |

Claude Mythos Preview is a separate, invitation-only research preview for defensive cybersecurity (Project Glasswing).

**Durable pattern:** Model IDs with snapshot dates (e.g., `claude-haiku-4-5-20251001`) are frozen — the same snapshot is identical across all platforms. Aliases without dates (`claude-haiku-4-5`) route to the latest snapshot. Use snapshot IDs in production for stability; use aliases in development for easy upgrades.

**Operational detail (likely to drift):** Pricing is subject to change. The 300k batch output ceiling requires the `output-300k-2026-03-24` beta header and applies only to the Message Batches API for Opus 4.7, Opus 4.6, and Sonnet 4.6.

---

## Service Tiers

Three tiers are available:

- **Standard:** Default for all API requests; best-effort prioritization.
- **Priority Tier:** Prioritized over all standard requests; targets 99.5% uptime; purchased as committed input/output token-per-minute capacity for 1, 3, 6, or 12 months. Requires contacting sales.
- **Batch:** Asynchronous processing via the Message Batches API; 50% cost discount.

Tier selection per request: `service_tier: "auto"` (default) uses Priority Tier capacity when available and falls back to Standard; `"standard_only"` forces Standard.

The response `usage` object includes `service_tier: "priority"` or `"standard"` to indicate which tier served the request. Response headers expose Priority Tier remaining capacity when applicable.

**Token accounting for Priority Tier capacity burndown:**
- Cache reads: 0.1 tokens per token read
- Cache writes (5-min TTL): 1.25 tokens per token written
- Cache writes (1-hr TTL): 2.0 tokens per token written
- US-only inference (`inference_geo: "us"`) on Opus 4.7, Opus 4.6, and newer: 1.1 tokens per input/output token
- All other: 1 token per token

**Architectural note:** The burndown coefficients mirror the relative pricing of each token type. This is a resource-accounting mechanism, not separate billing.

---

## API Versioning

The stable API version is `2023-06-01`. The contract is additive-only: Anthropic may add optional input parameters, add fields to outputs, change error conditions, and add enum variants to streaming event types. Breaking changes do not occur within a version.

**Operational detail:** Previous versions are deprecated and may be unavailable for new users. Always use `anthropic-version: 2023-06-01` in raw HTTP requests.

---

## Beta Headers

Beta features are accessed by sending `anthropic-beta: feature-name` (or a comma-separated list) in the API request, or passing `betas=[...]` in an SDK call. Beta features may have breaking changes with notice, rate limit differences, and limited regional availability.

**Current beta headers of note (as of crawl date):**

| Header | Feature |
|---|---|
| `files-api-2025-04-14` | Files API |
| `mcp-client-2025-11-20` | MCP connector (current; `2025-04-04` deprecated) |
| `managed-agents-2026-04-01` | Managed Agents (all endpoints) |
| `context-management-2025-06-27` | Context editing (tool result + thinking block clearing) |
| `output-300k-2026-03-24` | 300k max output on batch API |
| `extended-cache-ttl-2025-04-11` | 1-hour prompt cache TTL |
| `output-128k-2025-02-19` | 128k max output |
| `token-counting-2024-11-01` | Token counting API |

**Architectural note:** Beta headers with a `feature-YYYY-MM-DD` format are versioned independently of the API version. Treating them as opaque identifiers rather than semantic versions is the correct approach — their semantics are defined by the documentation at the given date, not derivable from the date alone.

---

## Context Editing

Context editing gives applications fine-grained runtime control over what content is cleared from conversation history as context grows. It is in beta (`context-management-2025-06-27`). The primary strategies:

**Tool result clearing (`clear_tool_uses_20250919`):** Removes old tool results in chronological order when a configured token threshold is exceeded. The application continues maintaining its full unmodified conversation history locally; clearing is server-side only. Configuration parameters: `trigger` (when to activate; default 100k input tokens), `keep` (how many recent tool pairs to preserve; default 3), `clear_at_least` (minimum token clearing per activation), `exclude_tools`, `clear_tool_inputs`.

**Thinking block clearing (`clear_thinking_20251015`):** Manages thinking blocks in conversations using extended thinking. Per-model defaults differ: Opus 4.5+ and Sonnet 4.6+ keep all prior thinking blocks; earlier Opus/Sonnet and all Haiku keep only the last turn. The `keep` parameter overrides the per-model default.

**Client-side SDK compaction:** An alternative where the SDK generates a summary of the conversation and replaces the full history with it, using the `tool_runner` method. Server-side compaction is generally preferred. Client-side compaction interacts poorly with server-side tools (overestimates token usage from accumulated cache reads).

**Architectural note:** Context editing does not modify client state. The server applies edits before the prompt reaches Claude; the application always works from the full, unmodified history. The `context_management.applied_edits` field in the response reports what was cleared and how many tokens were saved.

**Interaction with prompt caching:** Tool result clearing invalidates cache breakpoints at the point of clearing (write cost incurred; subsequent requests reuse the new prefix). Thinking block clearing preserves the cache when blocks are kept; invalidates when they are cleared.

---

## Stable Patterns vs. Operational Details

**Stable (architecture):**
- SDK beta namespace pattern for pre-release features
- Snapshot-date model IDs for stability; alias IDs for upgrade convenience
- Additive-only API versioning contract
- Context editing as server-side-only; client history unchanged
- Priority Tier burndown coefficients mirror pricing ratios

**Operational (likely to change):**
- Specific model prices and context window sizes
- Beta header dates (superseded by newer versions)
- `mcp-client-2025-04-04` is deprecated; use `mcp-client-2025-11-20`
- Specific default values for context editing parameters

---

## Notes for Synthesis

This sub-batch covers infrastructure and configuration rather than model capabilities. The most synthesis-ready permanent note surfaces are the model lineup (→ [[anthropic-claude-4-model-family]]) and the service tier/priority capacity model. Context editing is closely related to [[anthropic-prompt-caching]] and [[anthropic-adaptive-thinking]].
