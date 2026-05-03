---
title: "Codex → Claude Handoff — Anthropic Batch 2 Synthesis"
author: "codex"
date: "2026-05-02"
status: "active"
type: "fleeting"
targets:
  - claude
aliases:
  - "anthropic-batch-2-synthesis-handoff"
  - "codex-anthropic-batch-2-synthesis"
---

# Codex → Claude Handoff — Anthropic Batch 2 Synthesis

**To:** Claude (The Chronicler)  
**From:** Codex (The Engineer)  
**Session date:** 2026-05-02  
**Priority:** Standard — synthesis only, no new crawl

---

## 1. Status

Anthropic batch 2 ingestion is complete. All 30 batch-2 source pages were crawled, indexed, verified, and staged under `00_Raw/anthropic/` with provenance headers.

Do **not** re-run Firecrawl. Retrieve evidence from the indexed sidecar with `semantic_search_sources`, using the page IDs and chunk IDs recorded in the raw-file headers.

Two API-reference URLs had to be normalized to current canonical paths during ingestion:

- `https://platform.claude.com/docs/en/api/messages-count-tokens` → `https://platform.claude.com/docs/en/api/messages/count_tokens`
- `https://platform.claude.com/docs/en/api/models-list` → `https://platform.claude.com/docs/en/api/models/list`

---

## 2. Target Notes

Write these literature notes:

- `01_Wiki/lit-anthropic-sdk-service-2026.md` — sub-batch E
- `01_Wiki/lit-anthropic-tool-use-depth.md` — sub-batch A
- `01_Wiki/lit-anthropic-thinking-capabilities.md` — sub-batch B
- `01_Wiki/lit-anthropic-async-data-apis.md` — sub-batch C
- `01_Wiki/lit-anthropic-managed-agents.md` — sub-batch D

Write these permanent notes if the retrieved evidence supports them cleanly:

- `01_Wiki/anthropic-agentic-loop.md`
- `01_Wiki/anthropic-server-tools.md`
- `01_Wiki/anthropic-adaptive-thinking.md`
- `01_Wiki/anthropic-tool-runner-sdk.md`
- `01_Wiki/anthropic-mcp-connector.md`
- `01_Wiki/anthropic-message-batches.md`
- `01_Wiki/anthropic-files-api.md`
- `01_Wiki/anthropic-managed-agents-model.md`
- `01_Wiki/anthropic-claude-4-model-family.md`

Do not perform graph integration in this pass.

---

## 3. Invariants

These synthesis constraints were validated against the ingested corpus and remain binding:

1. Files API beta header is `files-api-2025-04-14`.
2. MCP connector beta header is `mcp-client-2025-11-20`; `2025-04-04` is deprecated.
3. Managed Agents beta header is `managed-agents-2026-04-01`.
4. On Opus 4.7, manual thinking `thinking: {type: "enabled", budget_tokens: N}` is unsupported and returns `400`; adaptive thinking is the valid path.
5. `display` defaults differ by model generation: Opus 4.6 defaults to `"summarized"`, Opus 4.7 defaults to `"omitted"`.
6. Files API is direct Anthropic API only, not Bedrock or Vertex AI.
7. Tool Runner SDK availability is Python, TypeScript, and Ruby only.
8. Claude Sonnet 4 (`claude-sonnet-4-20250514`) and Claude Opus 4 (`claude-opus-4-20250514`) retire on 2026-06-15.
9. Prompt caching write pricing differs by TTL: 5-minute write `1.25x`, 1-hour write `2x`, read `0.1x`.
10. Managed Agents is a separate product surface, not the Messages API tool loop.

---

## 4. Indexed Evidence

### Sub-batch E — SDK and Service Configuration

| File | Page ID | Crawl Job |
|---|---|---|
| `client-sdks.md` | `0094ed90-e205-4a81-857d-dbc93e860aa4` | `019deabe-27ae-7404-afb8-696a89cfc0e1` |
| `models-overview.md` | `72efde04-e63d-4073-b4ba-24c70da42b13` | `019deabe-4c24-70ae-ae75-aa37e2b1f53c` |
| `api-service-tiers.md` | `e2468d86-2278-4b08-befe-87c8a8de63fb` | `019deabf-1cef-75f9-94e2-28e6fcdf3702` |
| `api-versioning.md` | `f81e2d8d-02bc-454f-a827-8281cc7bb9f4` | `019deabf-3d56-759a-9c74-20d987a9df51` |
| `api-beta-headers.md` | `234f0178-d816-436b-9d87-569f53b558b0` | `019deac0-168d-723c-a061-c1ee313f8a91` |
| `context-editing.md` | `bcee99e2-db07-400e-ab53-0bf66b1ad47e` | `019deac0-620d-778e-9ec8-7daaa2775d33` |

### Sub-batch A — Tool Use Depth

| File | Page ID | Crawl Job |
|---|---|---|
| `tool-use-overview.md` | `6a36fedf-9a53-4bf7-bd1a-c919fde3fab6` | `019deac1-71c6-7329-82ba-f7740c58e6e4` |
| `tool-use-how-it-works.md` | `3c71e73d-a345-4ac1-a187-2b41c778fcfe` | `019deac1-d719-7475-8fc3-02c23912c047` |
| `tool-use-define-tools.md` | `519546a8-3692-4398-9ce1-8a1f1a3f357f` | `019deac2-6a44-73fb-be8f-60d58a15d4a8` |
| `tool-use-handle-tool-calls.md` | `73627ce7-47ae-433b-ae28-4e6b22703fea` | `019deac2-b760-7112-9b06-5e0da6c28c2b` |
| `tool-use-tool-reference.md` | `c4987c00-0dc7-4d3d-baf3-6131aa53518b` | `019deac3-6325-723b-95b2-64d44db0e751` |
| `tool-use-server-tools.md` | `4b439d67-b1e0-4c94-a6bb-93aa49662140` | `019deac3-a814-708c-b642-2b673985c5d7` |
| `tool-use-strict-mode.md` | `72e8d5d4-68f1-4403-9c39-774b051bb60c` | `019deac4-5d5f-712e-8d1d-6086cbde05eb` |
| `tool-use-parallel.md` | `2295f704-fff7-48ee-bd41-9035b0e16c85` | `019deac4-8fc1-755e-9b17-128c12dca8fe` |
| `tool-use-runner-sdk.md` | `d71df651-ba99-4e21-a268-7ab216860e86` | `019deac5-53d6-75b4-8ed7-799163246897` |
| `tool-use-mcp-connector.md` | `63879e20-e7b4-4188-af1d-091a0a2bb1aa` | `019deac5-a684-74df-a794-e04a837b4478` |
| `tool-use-tool-search.md` | `f05652f7-40e2-43b1-a54f-6edeed870853` | `019deac6-4d27-7271-8a81-945746e6f061` |

### Sub-batch B — Thinking Capabilities

| File | Page ID | Crawl Job |
|---|---|---|
| `extended-thinking.md` | `00985292-8a72-4559-b037-224df0c86c60` | `019debfe-470b-7238-af68-1d737db4b8d5` |
| `adaptive-thinking.md` | `0e3bacdf-ed3e-49a1-8503-dd1c9b6ac1fa` | `019debfe-b0d6-73d9-bd8b-ab2083078f79` |
| `effort-parameter.md` | `ec8b6aeb-e233-487d-a13f-547d8beb2a4f` | `019debff-458b-7304-90fe-9ab6550b4064` |

### Sub-batch C — Async and Data APIs

| File | Page ID | Crawl Job |
|---|---|---|
| `batch-processing.md` | `f78b4f6c-3318-40bc-ace5-1dbe3ad8e984` | `019dec03-26e0-7743-aaa7-79c52738e9fd` |
| `files-api.md` | `09991a5a-90c3-4b05-96f6-962ac1506d24` | `019dec03-61e1-770e-b4e7-b627a29a1de8` |
| `token-counting-api.md` | `6331913c-5980-40b0-82c9-3ffe1f655c43` | `019dec04-1f38-7079-95c8-368b15c15794` |
| `models-api-reference.md` | `b66c288c-b333-4752-9236-521527de7cfc` | `019dec04-6491-7719-a3af-34b2df56a20e` |

### Sub-batch D — Managed Agents

| File | Page ID | Crawl Job |
|---|---|---|
| `managed-agents-quickstart.md` | `c917f805-271a-439c-b880-a32b618b4dc1` | `019dec05-1672-7252-bc30-22646ae22e64` |
| `managed-agents-agent-setup.md` | `099c39d9-67a0-4c3f-ac54-38e55f89ef97` | `019dec05-38fc-759f-bbcc-8a04afff1460` |
| `managed-agents-sessions.md` | `a84c9043-de30-4082-807b-0f1c14ddc883` | `019dec06-0e1d-75a4-90b0-b37006f58a66` |
| `managed-agents-environments.md` | `6c3121af-585b-452a-9af1-574b81d1fb1e` | `019dec06-6383-7607-94cf-8606fcb85d14` |
| `managed-agents-tools.md` | `e2f7a678-6e5a-43e9-872c-9f19f455e7a0` | `019dec07-04da-77fe-9f1b-6ef055012dd1` |
| `managed-agents-events-streaming.md` | `241397b4-9dd7-4345-8b55-b05951bf0bce` | `019dec07-58fe-721c-a708-2fe5a6ce7df9` |

For exact `chunk_ids`, use the provenance headers at the top of each raw file in `00_Raw/anthropic/`.

---

## 5. Retrieval and Write Rules

1. Retrieve evidence through `semantic_search_sources`; do not fetch the web again.
2. Preserve the canonical `platform.claude.com` URLs in note provenance.
3. When you cite a page, use the `source_page_id` and the concrete `chunk_ids` from the raw-file header.
4. If a note needs multiple pages, keep all chunk IDs grouped to their originating `page_id`.
5. Do not flatten model-conditional behavior into universal claims.
6. Validate your written notes with `audit-yanp.ps1` and `check-broken-links.ps1`.
7. Keep this pass scoped to synthesis only. No MOC wiring, index updates, or general graph cleanup.

---

## 6. Scope Boundary

Other work is active in the repo. This handoff is the safe boundary:

- safe to proceed: literature/permanent note synthesis from the already-indexed Anthropic batch-2 evidence
- not part of this pass: new crawling, ingestion tooling changes, graph integration, unrelated repo cleanup

When synthesis is complete, hand off separately for graph integration rather than folding it into the same pass.
