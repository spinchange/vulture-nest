---
title: 'Pattern: Supabase Flask Integration'
author: claude-sonnet-4-6
date: 2026-05-01
status: active
type: permanent
aliases: [supabase-flask-pattern, flask-supabase-ssr]
provenance:
  source_record_ids:
    - "31f3d047-c0e1-4c19-8c33-a3efeaab355f"
  chunk_ids:
    - "74973d96-0e55-496a-82e2-57a72259182d"
    - "5b049707-c646-4acd-8980-a72feca0b220"
  retrieved_at: "2026-05-01"
  acting_agent: "claude-chronicler"
---

# Pattern: Supabase Flask Integration

A server-side pattern for connecting a Flask application to Supabase using the Python client, with RLS as the authorization layer.

## Pattern Structure

**Context:** A Python Flask app needs to read from a Supabase-hosted PostgreSQL database without managing raw database connections.

**Forces:**
- Credentials must not be hardcoded or exposed
- Authorization should be enforced at the database layer, not just the application layer
- The Supabase client should not be re-instantiated on every request

**Solution:**

1. **Module-level singleton** — call `create_client()` once at import time, bind to a typed variable:
   ```python
   supabase: Client = create_client(
       os.environ.get("SUPABASE_URL"),
       os.environ.get("SUPABASE_PUBLISHABLE_KEY")
   )
   ```

2. **Environment-based config** — load credentials from `.env` via `python-dotenv`; never commit secrets

3. **Method-chain query API** — all queries follow `.table(name).select(cols).execute()`, with `.data` holding results:
   ```python
   response = supabase.table('instruments').select("*").execute()
   rows = response.data
   ```

4. **RLS as the authorization layer** — grant minimum permissions to the `anon` role and enforce access via Row Level Security policies; app code carries no auth logic for public reads

## Consequences
- Clean separation: Flask handles routing/rendering; Supabase handles data + auth
- RLS failures are silent from the app perspective (returns empty result, not an error) — test policies explicitly
- The publishable key is appropriate for server-side use; use the service key only when RLS must be bypassed (admin operations)

## Related Patterns
- [[lit-supabase-flask-quickstart]] — source literature note
- [[dotnet-agent-integration]] — comparable pattern in .NET context
