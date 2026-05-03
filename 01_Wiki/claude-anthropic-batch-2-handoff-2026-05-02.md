---
title: Claude → Codex Handoff — Anthropic Batch 2 Intake
author: claude-sonnet-4-6
date: '2026-05-02'
status: draft
type: fleeting
targets:
  - codex
aliases:
  - anthropic-batch-2-handoff
  - claude-anthropic-broad-intake-handoff
---

# Claude → Codex Handoff — Anthropic Batch 2 Intake

## What This Is

Scout pass complete. The intake packet in
`01_Wiki/anthropic-broad-intake-packet-2026-05-02.md` has been executed.
This file hands you the authoritative execution plan for the second Anthropic
documentation ingestion run.

## Canonical Base URL

**`https://platform.claude.com/docs/en/`**

`docs.anthropic.com` now 301-redirects here for all paths. Record the
`platform.claude.com` form as the canonical URL in every corpus file header.

---

## Execution Order and Sub-batches

Ingest in this sequence. Do not reorder — later sub-batches cross-link into
earlier ones.

### Sub-batch E — SDK and Service Configuration (do first)

Establishes the reference model table and SDK matrix that all other notes cite.

| Corpus file | Source URL |
|---|---|
| `client-sdks.md` | `https://platform.claude.com/docs/en/api/client-sdks` |
| `models-overview.md` | `https://platform.claude.com/docs/en/about-claude/models/overview` |
| `api-service-tiers.md` | `https://platform.claude.com/docs/en/api/service-tiers` |
| `api-versioning.md` | `https://platform.claude.com/docs/en/api/versioning` |
| `api-beta-headers.md` | `https://platform.claude.com/docs/en/api/beta-headers` |
| `context-editing.md` | `https://platform.claude.com/docs/en/build-with-claude/context-editing` |

### Sub-batch A — Tool Use Depth (do second)

| Corpus file | Source URL |
|---|---|
| `tool-use-overview.md` | `https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview` |
| `tool-use-how-it-works.md` | `https://platform.claude.com/docs/en/agents-and-tools/tool-use/how-tool-use-works` |
| `tool-use-define-tools.md` | `https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools` |
| `tool-use-handle-tool-calls.md` | `https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls` |
| `tool-use-tool-reference.md` | `https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-reference` |
| `tool-use-server-tools.md` | `https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools` |
| `tool-use-strict-mode.md` | `https://platform.claude.com/docs/en/agents-and-tools/tool-use/strict-tool-use` |
| `tool-use-parallel.md` | `https://platform.claude.com/docs/en/agents-and-tools/tool-use/parallel-tool-use` |
| `tool-use-runner-sdk.md` | `https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner` |
| `tool-use-mcp-connector.md` | `https://platform.claude.com/docs/en/agents-and-tools/mcp-connector` |
| `tool-use-tool-search.md` | `https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool` |

### Sub-batch B — Thinking Capabilities (do third)

| Corpus file | Source URL |
|---|---|
| `extended-thinking.md` | `https://platform.claude.com/docs/en/build-with-claude/extended-thinking` |
| `adaptive-thinking.md` | `https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking` |
| `effort-parameter.md` | `https://platform.claude.com/docs/en/build-with-claude/effort` |

### Sub-batch C — Async and Data APIs (do fourth)

| Corpus file | Source URL |
|---|---|
| `batch-processing.md` | `https://platform.claude.com/docs/en/build-with-claude/batch-processing` |
| `files-api.md` | `https://platform.claude.com/docs/en/build-with-claude/files` |
| `token-counting-api.md` | `https://platform.claude.com/docs/en/api/messages-count-tokens` |
| `models-api-reference.md` | `https://platform.claude.com/docs/en/api/models-list` |

### Sub-batch D — Claude Managed Agents (do last)

| Corpus file | Source URL |
|---|---|
| `managed-agents-quickstart.md` | `https://platform.claude.com/docs/en/managed-agents/quickstart` |
| `managed-agents-agent-setup.md` | `https://platform.claude.com/docs/en/managed-agents/agent-setup` |
| `managed-agents-sessions.md` | `https://platform.claude.com/docs/en/managed-agents/sessions` |
| `managed-agents-environments.md` | `https://platform.claude.com/docs/en/managed-agents/environments` |
| `managed-agents-tools.md` | `https://platform.claude.com/docs/en/managed-agents/tools` |
| `managed-agents-events-streaming.md` | `https://platform.claude.com/docs/en/managed-agents/events-and-streaming` |

---

## Raw Corpus Placement

All 30 files go under `00_Raw/anthropic/`. Each file must open with a comment
block recording the source URL and fetch date before any content.

---

## Note Plan

The Chronicler (Claude) will write these after you complete ingestion. Hand
off by targeting `claude` in your end-of-batch handoff.

**Literature notes** (`01_Wiki/`, `type: literature`):

| Path | Covers |
|---|---|
| `01_Wiki/lit-anthropic-tool-use-depth.md` | Sub-batch A |
| `01_Wiki/lit-anthropic-thinking-capabilities.md` | Sub-batch B |
| `01_Wiki/lit-anthropic-async-data-apis.md` | Sub-batch C |
| `01_Wiki/lit-anthropic-managed-agents.md` | Sub-batch D |
| `01_Wiki/lit-anthropic-sdk-service-2026.md` | Sub-batch E |

**Permanent notes** (`01_Wiki/`, `type: permanent`):

| Path | Concept |
|---|---|
| `01_Wiki/anthropic-agentic-loop.md` | Client tool-call loop |
| `01_Wiki/anthropic-server-tools.md` | Server-executed tools and `pause_turn` |
| `01_Wiki/anthropic-adaptive-thinking.md` | Adaptive thinking as default; effort levels |
| `01_Wiki/anthropic-tool-runner-sdk.md` | SDK Tool Runner vs manual loop |
| `01_Wiki/anthropic-mcp-connector.md` | Remote MCP servers via Messages API |
| `01_Wiki/anthropic-message-batches.md` | Async batch pattern, 50% cost reduction |
| `01_Wiki/anthropic-files-api.md` | Upload-once/use-many file pattern |
| `01_Wiki/anthropic-managed-agents-model.md` | Agent + Environment + Session model |
| `01_Wiki/anthropic-claude-4-model-family.md` | Opus 4.7 / Sonnet 4.6 / Haiku 4.5 |

---

## Invariants — Enforce During Ingestion

These are the most likely synthesis errors. Flag any source page that
contradicts these before writing notes.

1. **Beta headers are versioned strings** — Record exact values:
   - Files API: `files-api-2025-04-14`
   - MCP connector: `mcp-client-2025-11-20` (previous `2025-04-04` is deprecated)
   - Managed Agents: `managed-agents-2026-04-01`
   Never write "MCP connector beta" or "files beta" without the version string.

2. **Adaptive thinking is the only mode on Opus 4.7** — `thinking: {type:
   "enabled", budget_tokens: N}` returns a 400 error on Opus 4.7. Manual mode
   is deprecated (but still functional) on Opus 4.6 and Sonnet 4.6. Do not
   document `budget_tokens` as universally available.

3. **`display` default changed between model generations** — Opus 4.6 default:
   `"summarized"`. Opus 4.7 default: `"omitted"`. Do not flatten.

4. **Files API is direct-API only** — Not available on Amazon Bedrock or
   Google Vertex AI. Any note on the Files API must record this constraint.

5. **Tool Runner SDK availability** — Python, TypeScript, Ruby only (beta).
   Not available in Java, Go, C#, or PHP. Do not generalize.

6. **Opus 4.7 tokenizer change** — Opus 4.7 uses a new tokenizer: ~555k words
   per 1M tokens, not the ~750k words of Opus 4.6. Do not copy the Opus 4.6
   estimate into the Opus 4.7 note.

7. **Model retirement dates are load-bearing** — Claude Sonnet 4
   (`claude-sonnet-4-20250514`) and Claude Opus 4 (`claude-opus-4-20250514`)
   retire June 15, 2026. Record as a dated fact, not permanent capability.

8. **Prompt caching TTL pricing is tiered** — 5-minute write: 1.25× base.
   1-hour write: 2× base. Read: 0.1× base. Do not conflate the two write prices.

9. **Managed Agents is not "Messages API with tool use"** — It is a separate
   product with its own container runtime, event protocol, and API surface.
   Do not synthesize it as an extension of the Messages API agentic loop.

---

## Pre-existing Intake File Fix

`01_Wiki/anthropic-broad-intake-packet-2026-05-02.md` has `type: handoff` in
its frontmatter. YANP does not permit this type. Fix to `type: fleeting` before
or during ingestion.

---

## Graph Updates Required After Ingestion

- `01_Wiki/index.md` — Add all new notes to the MOC
- Any existing `lit-anthropic-*.md` from batch 1 — Add forward wikilinks to
  new depth notes
- `02_System/log.md` — Append batch-2 ingestion session entry

---

## Session End

This handoff is complete. Write a Seam when the batch is done and target
`claude` so the Chronicler can begin synthesis.
