---
title: "Literature: Anthropic Advanced Capabilities"
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: literature
aliases:
  - lit-anthropic-advanced
  - anthropic-advanced-batch
source: "00_Raw/anthropic/"
---

# Literature: Anthropic Advanced Capabilities

Synthesis of the second-batch Anthropic raw corpus: advanced reasoning modes, batch execution, file management, tool extensions, and the Managed Agents surface. The first-batch fundamentals (Messages API, tool use, streaming, error handling, prompt caching basics) are covered in [[lit-anthropic-messages-api]].

## Source Set

Crawled from `platform.claude.com/docs` between 2026-05-01 and 2026-05-03:

| File | Topic |
|---|---|
| `adaptive-thinking.md` | Adaptive thinking mode, effort parameter, display control |
| `extended-thinking.md` | Manual thinking mode, interleaved thinking, block preservation |
| `effort-parameter.md` | `effort` levels, model-specific guidance, tool use interaction |
| `batch-processing.md` | Message Batches API, polling, extended output beta |
| `files-api.md` | Files API, upload/reference pattern, storage lifecycle |
| `token-counting-api.md` | Token count endpoint, pre-call estimation |
| `tool-use-mcp-connector.md` | MCP Connector, toolset config, allowlist/denylist, TypeScript helpers |
| `tool-use-runner-sdk.md` | Tool Runner SDK, `@beta_tool`, compaction |
| `tool-use-server-tools.md` | Server-side tool types |
| `managed-agents-quickstart.md` | Agent/Environment/Session model, quickstart |
| `managed-agents-sessions.md` | Session lifecycle, statuses, vault IDs |
| `managed-agents-agent-setup.md` | Agent configuration and versioning |
| `managed-agents-environments.md` | Environment templates |
| `managed-agents-events-streaming.md` | Event types, streaming protocol |
| `managed-agents-tools.md` | Managed agent toolset |
| `models-overview.md` | Model IDs, token limits, feature support matrix |
| `models-api-reference.md` | Model API reference |
| `api-beta-headers.md` | Beta feature headers |
| `api-versioning.md` | API version policy |
| `context-editing.md` | Context compaction, thinking block clearing |
| `client-sdks.md` | SDK overview |

## Durable Architectural Patterns

**Adaptive thinking replaces manual token budgets.** The shift from `budget_tokens` to `effort` is not cosmetic — it changes who controls thinking depth (model vs. caller). Adaptive mode outperforms fixed budgets on bimodal tasks and long-horizon agentic workflows because Claude can skip thinking for simple sub-tasks. Manual mode gives predictability; adaptive mode gives optimality.

**Interleaved thinking is automatic in adaptive mode.** Claude reasons between tool calls, not just before the first one. This is architecturally significant for multi-step tool workflows: reasoning quality at each step improves when Claude can reconsider after seeing a tool result.

**Thinking display is a latency knob, not a cost knob.** `display: "omitted"` skips streaming thinking tokens, reducing time-to-first-text-token. You are charged the same for full thinking tokens regardless of display setting.

**Batch API = cost-optimized async tier.** 50% discount for any workload that can tolerate < 1 hour latency. Batch and prompt caching discounts stack. The extended output beta (300k tokens) is batch-only — synchronous API caps at 64k–128k depending on model.

**Files API decouples ingestion from inference.** The upload-once pattern eliminates repeated base64 encoding of large documents. The asymmetry — uploads cannot be downloaded, only code-execution outputs can — reflects a specific design intent: files are inputs to inference, not a general object store.

**MCP Connector makes Claude the MCP client.** The simplification is real: no MCP client implementation, no local tool execution infrastructure for remote MCP tools. The constraint is also real: only HTTP-accessible servers, only tool calls (not prompts or resources), not on Bedrock or Vertex AI.

**Tool Runner SDK is loop automation, not a protocol change.** The same tool call loop still runs; the SDK handles the iteration, error wrapping, and state management. Compaction support is the most important addition for production agentic workloads — it allows agents to run beyond context window limits.

**Managed Agents is Anthropic's hosted agent runtime.** Compared to building on the Messages API, the tradeoff is control vs. simplicity: container provisioning, agent loop, and tool execution all happen server-side. Sessions are event-driven state machines; the caller sends user events and receives agent events via SSE.

## Operational Details Likely to Drift

- Beta headers (files-api, mcp-client, managed-agents) will change as features GA.
- `mcp-client-2025-04-04` is already deprecated; `mcp-client-2025-11-20` is current.
- `output-300k-2026-03-24` beta header for extended batch output — likely to be versioned.
- Model-specific effort level availability (`xhigh` is Opus 4.7-only as of this capture).
- Exact pricing tables (batch rates, cache write/read rates) — treat the pricing page as authoritative.
- Files API rate limit (100 req/min) is a beta-period limit and will change.
- Managed Agents tool types (`agent_toolset_20260401`) use date-versioned identifiers.

## Relationship to First Batch

The first batch ([[lit-anthropic-messages-api]]) covers: Messages API request/response shape, tool use execution loop, SSE streaming baseline, error handling, prompt caching core mechanics.

This batch extends it with: reasoning modes, async execution, file storage, MCP integration, SDK-level abstractions, and the hosted agent runtime. The two batches together cover the full current Anthropic API surface captured in the local corpus.

## See also

- [[lit-anthropic-messages-api]]
- [[anthropic-adaptive-thinking]]
- [[anthropic-message-batches]]
- [[anthropic-files-api]]
- [[anthropic-mcp-connector]]
- [[anthropic-tool-runner-sdk]]
- [[anthropic-managed-agents-model]]
