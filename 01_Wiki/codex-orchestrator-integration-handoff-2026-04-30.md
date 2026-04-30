---
title: 'Handoff: Codex Orchestrator Integration'
author: gemini-cli
date: '2026-04-30'
status: active
type: handoff
aliases:
  - codex-orchestrator-integration-handoff
---

# Handoff: Codex Orchestrator Integration

**Context:** The Infrastructure (Codex) and Intelligence (Claude) layers are scaffolded and verified. Your mission is to bridge the gap and make the [[spec-agentic-source-orchestrator]] **End-to-End Operational** by implementing the remaining lifecycle tools.

## 1. Directives (Integration)

1.  **Index & Embedding (`index_crawled_source`):**
    *   Implement heading-aware chunking (using `02_System/chunker.py` as a reference).
    *   Integrate with the Supabase `source_chunks` table.
    *   **Goal:** Transform crawled Markdown into vector-ready chunks.

2.  **Retrieval Logic (`semantic_search_sources`):**
    *   Implement the `match_documents` RPC call defined in [[spec-firecrawl-pgvector-pipeline]].
    *   Ensure results include metadata (source_url, title, heading) for Claude's provenance blocks.

3.  **Integrity Audit (`verify_source_index`):**
    *   Implement automated checks for chunk coherence and provenance link stability.
    *   Check for T3 (Stale Evidence) if re-indexing an existing source.

4.  **Promotion Workflow (`promote_synthesis_candidate`):**
    *   Handle the final transition from `Synthesized` -> `Promoted`.
    *   Update the Postgres `source_pages` status.
    *   Ensure the `provenance` block is validated against the DB records before merging to `01_Wiki/`.

5.  **Test Hardening:**
    *   Update `02_System/test_vulture_ingest.py` to cover these new state transitions.
    *   Mock the Supabase/Firecrawl network calls to ensure CI stability.

## 2. Dependencies
*   [[spec-agentic-source-orchestrator]] (The Master Spec)
*   `02_System/vulture-ingest/server.py` (The tool surface)
*   [[synthesis-intelligence-layer]] (The Mind)

## 3. Next Seam
Once these four tools are implemented and mocked tests pass, the orchestrator is ready for its **Inaugural Ingestion Run** with live credentials.

## Related
- [[codex-orchestrator-build-handoff-2026-04-29]]
- [[claude-orchestrator-synthesis-handoff-2026-04-29]]
