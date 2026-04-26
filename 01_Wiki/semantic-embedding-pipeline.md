---
title: Semantic Embedding Pipeline
author: claude-sonnet-4-6
date: 2026-04-26
status: active
aliases: [embedding pipeline, auto-link pipeline, neural retrieval]
type: reference
---

# Semantic Embedding Pipeline

The semantic embedding pipeline adds a neural retrieval layer to the vault's symbolic link graph. It addresses the core limitation identified in the [[karpathy-vision-gap-analysis]]: the compounding mechanism previously required an agent or human to *write* a link for a connection to exist. This pipeline makes the vault discover and propose its own missing connections.

## Architecture

Three scripts form the pipeline, each building on the last:

```
sync-embeddings.ps1  →  suggest-links.ps1  →  auto-link.ps1
     (embed)               (discover)            (judge + write)
```

The embedding vectors are stored in the `NoteEmbeddings` table in [[poshwiki]] (`wiki.db`), alongside the existing `Pages` and `Links` tables. No external vector store is required.

## Scripts

### sync-embeddings.ps1
Embeds all notes in `01_Wiki/` using the Gemini `gemini-embedding-001` model (768 dimensions). Incremental: SHA256-hashes each note's content and skips notes that haven't changed since last embedding.

- **API**: Gemini `embedContent` endpoint (`v1beta`)
- **Model**: `gemini-embedding-001` (available on free tier)
- **Rate limit**: 1200ms between calls (~50 RPM, safe under 100 RPM limit)
- **Retry**: 5 attempts, 60s backoff on 429
- **Env var**: `GEMINI_API_KEY`

```powershell
# Full sync
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/sync-embeddings.ps1

# Force re-embed all notes
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/sync-embeddings.ps1 -Force
```

### suggest-links.ps1
Loads all embeddings, pre-normalizes vectors, computes pairwise cosine similarity (~25k pairs for 224 notes), and surfaces pairs above a threshold that have no existing wikilink in either direction.

```powershell
# Default: threshold 0.80, top 20
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/suggest-links.ps1

# Tunable
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/suggest-links.ps1 -Threshold 0.85 -TopN 50
```

### auto-link.ps1
Takes top-N suggestion pairs, reads both notes, asks Claude to decide link directionality, and writes wikilinks directly into the markdown files. Logs every action to `02_System/log.md`.

- **API**: Anthropic Messages API (`claude-haiku-4-5-20251001` by default)
- **Rate limit**: 4s between judge calls
- **Env var**: `ANTHROPIC_API_KEY`
- **Link placement**: appends to existing `## Related` section, or creates one

```powershell
# Dry run first — see decisions without writing
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/auto-link.ps1 -DryRun

# Run for real (default: top 20 pairs above 0.85)
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/auto-link.ps1

# Lower threshold to catch more candidates
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/auto-link.ps1 -Threshold 0.82 -TopN 30
```

## Full Maintenance Cycle

```powershell
# 1. Embed new/changed notes
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/sync-embeddings.ps1

# 2. Check semantic orphan count
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/suggest-links.ps1

# 3. Auto-link (repeat with lower threshold until candidates < 40)
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/auto-link.ps1 -Threshold 0.85
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/auto-link.ps1 -Threshold 0.82

# 4. Sync graph after each auto-link pass
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/sync-vault-graph.ps1
```

`sync-embeddings.ps1` also runs as step 8/8 in `run-maintenance.ps1` (optional — skips gracefully if `GEMINI_API_KEY` is absent).

## Semantic Search

`vulture-search.ps1` gained a `-Semantic` flag that embeds the query and returns nearest-neighbor notes:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/vulture-search.ps1 -Query "session types" -Semantic
```

This adds a `[SEMANTIC NEIGHBORS]` tier to results alongside the existing symbolic graph expansion.

## Design Decisions

**Why Gemini for embeddings, Claude for judging?**
The Gemini free tier provides `gemini-embedding-001` with 1500 RPD at no cost — sufficient for incremental vault maintenance. The generative quota (`generateContent`) on the same key had `limit: 0`, making it unavailable for the judge role. Claude Haiku is better at nuanced directional reasoning anyway and costs fractions of a cent per decision.

**Why store embeddings as JSON text in SQLite rather than a vector extension?**
`sqlite-vec` would require loading a native extension into PoShWiKi's .NET SQLite setup. JSON text is simple, portable, and sufficient — cosine similarity over 224 notes in PowerShell completes in under 10 seconds.

**Why 0.80 as the floor threshold?**
Empirically, pairs below 0.80 tend to share vocabulary rather than concepts. The initial run showed 164 candidates above 0.80; after four passes the count stabilised around 51, suggesting that floor is approximately correct for this vault's content density.

## Baseline Results (2026-04-26)

First run against the full vault:

| Metric | Before | After |
|--------|--------|-------|
| Total links | 1,478 | 1,621 |
| Semantic orphans (>0.80) | 164 | ~51 |
| New links written | — | 143 |
| Notes embedded | — | 224 |

## Related

- [[poshwiki]]
- [[ps-vault-maintenance]]
- [[ps-vulture-search]]
- [[karpathy-vision-gap-analysis]]
- [[wiki-as-codebase]]
- [[the-compounding-artifact]]
