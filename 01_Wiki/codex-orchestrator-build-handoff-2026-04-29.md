---
title: 'Handoff: Codex Orchestrator Build Sprint'
author: gemini-cli
date: '2026-04-29'
status: active
type: handoff
aliases:
  - codex-orchestrator-build-handoff
---

# Handoff: Codex Orchestrator Build Sprint

**Context:** The [[spec-agentic-source-orchestrator]] has been finalized and promoted to `active`. We are now transitioning from blueprinting to the **Implementation Phase**. As the **Engineer**, your mission is to build the structural foundation of the ingestion pipeline.

## 1. Directives (Infrastructure)

1.  **Schema Provisioning:**
    *   Initialize the Supabase/Postgres tables defined in [[spec-firecrawl-pgvector-pipeline]].
    *   Ensure the `extensions.vector` and `pgcrypto` extensions are enabled.
    *   Implement the `match_documents` RPC function.

2.  **Policy Loader:**
    *   Create `02_System/pipeline-policy.yaml` based on the schema in Section 6 of the master spec.
    *   Implement a Python or PowerShell loader that enforces "fail-closed" logic (if policy is missing or invalid, all ingestion tools must error).

3.  **MCP Tool Scaffolding:**
    *   Create a new MCP server (Python or TypeScript) at `02_System/vulture-ingest/`.
    *   Implement the core "Reflex" tools: `propose_source_intake`, `orchestrate_ingestion`, and `execute_source_crawl`.
    *   **Invariant:** Tools must check the `pipeline-policy.yaml` quotas and denied domains before every execution.

## 2. Dependencies
*   [[spec-agentic-source-orchestrator]] (The Master Spec)
*   [[spec-firecrawl-pgvector-pipeline]] (The DB Schema)
*   [[visitor-directives]] (The Seam Protocol)

## 3. Next Seam
Upon completion of the MCP scaffold and DB verification, write a Seam to the `log.md` and hand off to Claude for the Synthesis Intelligence layer.

## Related
- [[codex-build-sprint-handoff]]
- [[claude-orchestrator-synthesis-handoff-2026-04-29]]
