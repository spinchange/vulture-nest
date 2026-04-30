---
title: 'Handoff: Inaugural Orchestrator Integration Test'
author: gemini-cli
date: '2026-04-30'
status: active
type: handoff
aliases:
  - gemini-orchestrator-test-handoff
  - inaugural-ingestion-test
---

# Handoff: Inaugural Orchestrator Integration Test

**Context:** The technical "Trinity Build" of the [[spec-agentic-source-orchestrator]] is finished. Infrastructure (Codex), Intelligence (Claude), and the State-Machine (Integration) are all versioned and passing mocked tests. The mission for the next session is to execute the first **Live End-to-End Ingestion Run**.

## 1. Prerequisites (Credentials Required)

Before starting, ensure the following environment variables are set in the shell (DO NOT COMMIT THESE):
*   `FIRECRAWL_API_KEY`: For crawling and mapping.
*   `SUPABASE_URL` & `SUPABASE_SERVICE_KEY`: For vector storage and state tracking.
*   `OPENAI_API_KEY`: For generating text-embedding-3-small vectors.

## 2. Test Target Selection

Choose a high-signal, atomic technical source.
*   **Primary Candidate:** [Firecrawl Documentation - Crawling](https://docs.firecrawl.dev/features/crawling)
*   **Alternative:** A specific technical blog post about MCP or Agentic RAG.
*   **Goal:** Ingest ~5-10 high-quality chunks to verify the T5 (Verified) epistemic path.

## 3. The 8-Stage Execution Sequence

Execute the following tools via the `vulture-ingest` MCP server:

1.  **Stage 1 (Propose):** `propose_source_intake` (Set `human_approved: true`).
2.  **Stage 2 (Map):** `orchestrate_ingestion` (Set `dry_run: false`). Verify URLs returned.
3.  **Stage 3 (Crawl):** `execute_source_crawl` (Set `dry_run: false`). Confirm Markdown retrieval.
4.  **Stage 4 (Index):** `index_crawled_source`. Confirm Supabase `source_chunks` population.
5.  **Stage 5 (Verify):** `verify_source_index`. Look for `status: passed` and any T3 warnings.
6.  **Stage 6 (Search):** `semantic_search_sources` with a specific query from the text to verify retrieval quality.
7.  **Stage 7 (Synthesize):** Claude to draft a Permanent Note in `01_Wiki/` based on retrieved chunks.
8.  **Stage 8 (Promote):** `promote_synthesis_candidate` to merge the draft with its validated `provenance` block.

## 4. Success Criteria
*   [ ] Raw source stored in Supabase `source_pages`.
*   [ ] Chunks embedded and searchable via vector query.
*   [ ] Epistemic gate (T5) successfully identifies direct evidence.
*   [ ] Final YANP note created in `01_Wiki/` with a valid, auditable `provenance` block.

## Related
- [[spec-agentic-source-orchestrator]]
- [[synthesis-intelligence-layer]]
- [[codex-orchestrator-integration-handoff-2026-04-30]]
