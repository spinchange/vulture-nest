---
title: 'Codex: Supabase Schema Ingestion'
author: gemini-cli
date: '2026-04-30'
status: active
type: engineering
aliases:
  - codex-supabase-schema-ingestion
  - automate-supabase-schema
---

# Codex: Supabase Schema Ingestion

**Context:** The [[spec-agentic-source-orchestrator]] requires a specific PostgreSQL schema in Supabase to function (tables: `source_pages`, `source_chunks`; function: `match_documents`). Manual SQL execution is to be avoided.

## Mission for Codex
Ingest and apply the schema located at `02_System/vulture-ingest/schema.sql` to the active Supabase instance.

### Execution Strategy (PowerShell)
Use the following protocol to bridge the schema gap:

1.  **Dependency Check:** Check for the `supabase` CLI. If missing, favor a direct `Invoke-RestMethod` approach using the `service_role` key.
2.  **SQL Execution:** 
    *   If a `run_sql` RPC or similar "God-mode" endpoint is available in the Supabase project settings, use it.
    *   Otherwise, generate a `apply-schema.ps1` script that utilizes the `pg_query` or equivalent if available in the environment.
3.  **Verification:** After application, execute a `GET` request to `/rest/v1/source_pages?select=id&limit=1` to confirm the table is visible to PostgREST.

## Schema Reference
The authoritative DDL is maintained at: `02_System/vulture-ingest/schema.sql`

### Manual Bridge (The "One-Time Fight")
If the automated execution strategy is blocked by missing credentials (e.g., `DATABASE_URL`) or restricted API access, the following manual step is required to unblock the entire pipeline:

1.  **Open the Supabase SQL Editor:** [https://supabase.com/dashboard/project/xvzuvsoeeznwmiopsoqj/sql/new](https://supabase.com/dashboard/project/xvzuvsoeeznwmiopsoqj/sql/new)
2.  **Paste & Run the DDL:** Copy the content from `02_System/vulture-ingest/schema.sql` and click **Run**.
3.  **Signal Completion:** Once the "Success" message appears, tell the agent: **"Schema applied."**

## Status Update (2026-04-30)
Codex attempted the automated mission and confirmed:
- `PGRST205`: Tables are missing from the schema cache.
- `supabase-cli` and `psql` are missing from the host environment.
- No `DATABASE_URL` is configured in the environment.

**Blockage:** Automation requires either a direct PostgreSQL connection string or the `run_sql` RPC to be enabled.

## Next Seam
Once the "One-Time Fight" is complete, Gemini will resume Stage 4 (Index) from the cached crawl results in `02_System/.tmp/crawl_result.json`.

## Related
- [[spec-firecrawl-pgvector-pipeline]]
- [[codex-orchestrator-integration-handoff-2026-04-30]]
