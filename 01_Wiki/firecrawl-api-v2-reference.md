---
title: Firecrawl API v2 Reference
author: gemini-cli
date: 2026-04-30
status: active
type: permanent
aliases:
  - firecrawl-api-v2
provenance_source_ids:
  - "92ed042b-607a-4841-8a2c-653978c57811"
provenance_chunk_ids:
  - "b44ffa4e-59a2-438e-8c95-511c7113f0dd"
  - "f9ee4c67-843a-48cc-9613-3d543caa21d7"
provenance_retrieved: "2026-05-01T03:55:52Z"
provenance_agent: "claude-chronicler"
---

# Firecrawl API v2 Reference

This note is a vault-local reference for the Firecrawl v2 surface used by the ingestion pipeline. It is grounded primarily in [[spec-firecrawl-pgvector-pipeline]] and the local ingest implementation, not a full live-doc mirror.

## Scope
- Focuses on the v2 endpoints already modeled in the vault.
- Emphasizes ingestion-relevant behavior over exhaustive vendor documentation.
- Treat parameter lists here as working references for this repo; verify against current Firecrawl docs before depending on them as exhaustive or stable.

## Core Endpoints

| Endpoint | Primary use | Return shape |
|---|---|---|
| `POST /v2/scrape` | Retrieve a single page | Synchronous content + metadata |
| `POST /v2/crawl` | Traverse a bounded site section | Async job ID; later poll for page results |
| `GET /v2/crawl/{id}` | Poll crawl status | Crawl status + completed pages when ready |
| `POST /v2/map` | Discover URLs without fetching page content | URL list / discovery result |
| `POST /v2/extract` | Schema-shaped extraction | Structured JSON |
| `POST /v2/search` | Search plus retrieval | Top-N result payloads |

## Authentication
- The local tooling uses bearer-token authentication via `FIRECRAWL_API_KEY`.
- The repo defaults the service base to `https://api.firecrawl.dev/v2` in [server.py](/abs/path/C:/Users/executor/Documents/vulture-nest/02_System/vulture-ingest/server.py:55).

## Request Patterns Used Here

### `scrape`
The pipeline spec treats `scrape` as the single-page path.

Common request fields in this vault:
- `url`
- `formats`
- `onlyMainContent`
- `excludeTags`
- `waitFor`

Representative payload from [[spec-firecrawl-pgvector-pipeline]]:

```json
{
  "url": "https://docs.firecrawl.dev/features/crawl",
  "formats": ["markdown", "links"],
  "onlyMainContent": true,
  "excludeTags": ["nav", "footer", "header", ".sidebar"],
  "waitFor": 1000
}
```

### `crawl`
The pipeline uses `crawl` for bounded multi-page ingestion.

Common request fields in this vault:
- `url`
- `limit`
- `maxDiscoveryDepth`
- `includePaths`
- `excludePaths`
- `scrapeOptions`

The local ingest server currently sends:

```json
{
  "url": "<root-url>",
  "limit": 200,
  "maxDiscoveryDepth": 3,
  "includePaths": [],
  "scrapeOptions": {
    "formats": ["markdown"],
    "onlyMainContent": true
  }
}
```

### `map`
The pipeline spec treats `map` as the discovery-only endpoint: enumerate candidate URLs before deciding whether to crawl or scrape them.

## Response Shape Conventions

### `scrape` response object
The pipeline spec models responses like:

```json
{
  "success": true,
  "data": {
    "markdown": "# Page Title\n\nContent...",
    "links": ["https://docs.example.com/page-2"],
    "metadata": {
      "title": "Page Title",
      "description": "Meta description",
      "language": "en",
      "statusCode": 200,
      "contentType": "text/html",
      "sourceURL": "https://docs.example.com/page-1"
    }
  }
}
```

### `crawl` job model
- `POST /v2/crawl` returns a job ID immediately.
- The local pipeline polls `GET /v2/crawl/{id}` until `status == "completed"`.
- Completed results are treated as an array of scrape-like page objects.

## Operational Notes
- Firecrawl is the extraction layer, not the chunking layer. Splitting and embedding happen downstream in the Postgres/pgvector pipeline.
- The vault consistently prefers `formats: ["markdown"]` or markdown-first retrieval to keep the ingestion path LLM-friendly.
- `onlyMainContent: true` is treated as the default for documentation ingestion to reduce navigation noise.

## Limitations
- This note is intentionally not a complete vendor API reference.
- Features not exercised in the pipeline may be omitted or only lightly described here.
- The original Gemini-authored version was a failed raw scrape; this rewrite is based on local spec material and should still be cross-checked against live docs before production changes.

## Related
- [[spec-firecrawl-pgvector-pipeline]]
- [[protocol-source-ingestion-runbook]]
- [[firecrawl-crawling-capabilities]]
- [[firecrawl-map-capabilities]]
- [[firecrawl-scrape-capabilities]]
