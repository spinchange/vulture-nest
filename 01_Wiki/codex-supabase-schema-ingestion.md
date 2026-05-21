---
title: 'Codex: Supabase Schema Ingestion'
author: gemini-cli
date: '2026-04-30'
status: active
type: spec
aliases:
  - codex-supabase-schema-ingestion
  - automate-supabase-schema
---

# Codex: Supabase Schema Ingestion

**Context:** The [[spec-agentic-source-orchestrator]] requires a specific PostgreSQL schema in Supabase to function (tables: `source_pages`, `source_chunks`, `source_events`; function: `match_documents`). Manual SQL execution is to be avoided where an automated path is available.

## Mission for Codex
Choose the correct database action for the active Supabase instance:

- Fresh install: apply `02_System/vulture-ingest/schema.sql`
- Existing ingest database: apply pending files under `02_System/vulture-ingest/migrations/`

The sidecar now tracks applied upgrades in `schema_migrations`, so Codex should favor the migration path whenever the base tables already exist.

### Execution Strategy (PowerShell)
Use the following protocol to bridge the schema gap:

1.  **Dependency Check:** Check for the `supabase` CLI. If missing, favor a direct `Invoke-RestMethod` approach using the `service_role` key.
2.  **SQL Execution:** 
    *   If a `run_sql` RPC or similar "God-mode" endpoint is available in the Supabase project settings, use it.
    *   Otherwise, generate a `apply-schema.ps1` script that utilizes the `pg_query` or equivalent if available in the environment.
3.  **Verification:** After application, execute `GET` requests to confirm `source_pages`, `source_events`, and `schema_migrations` are visible to PostgREST.

## Schema Reference
The authoritative DDL is maintained at: `02_System/vulture-ingest/schema.sql`

## Migration Reference

For in-place upgrades, the authoritative incremental path is:

- `02_System/vulture-ingest/apply-migration.ps1`
- `02_System/vulture-ingest/migrations/*.sql`

The migration runner applies sorted SQL files and records each successful file in `schema_migrations`.

### Manual Bridge (The "One-Time Fight")
If the automated execution strategy is blocked by missing credentials (e.g., `DATABASE_URL`) or restricted API access, the following manual step is required to unblock the entire pipeline:

1.  **Open the Supabase SQL Editor:** [https://supabase.com/dashboard/project/xvzuvsoeeznwmiopsoqj/sql/new](https://supabase.com/dashboard/project/xvzuvsoeeznwmiopsoqj/sql/new)
2.  **Choose the correct SQL source:**
    - Fresh database: copy `02_System/vulture-ingest/schema.sql`
    - Existing database: copy the next required file from `02_System/vulture-ingest/migrations/`
3.  **Run the SQL:** Click **Run**.
4.  **Signal Completion:** Once the "Success" message appears, tell the agent which path was used, e.g. **"Schema applied."** or **"Migration applied."**

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
