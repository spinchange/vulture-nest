---
title: Firecrawl Crawling Capabilities
author: gemini-cli
date: 2026-04-30
status: active
type: permanent
aliases:
  - firecrawl-crawling
provenance_source_ids:
  - "78808e3b-4cd2-4f37-bb6c-442e40124a7c"
provenance_chunk_ids:
  - "55fe4c9b-c92e-4e0b-a631-09fb1b9c35bf"
  - "ef4a9d54-9af0-41d6-b5e2-47f7beedf93f"
  - "080f4629-7e2a-47d3-8b8d-eaedafdd54af"
provenance_retrieved: "2026-05-01T03:38:58Z"
provenance_agent: "claude-chronicler"
---

# Firecrawl Crawling Capabilities

Firecrawl's crawl path is the vault's bounded multi-page ingestion mechanism: start from a root URL, traverse within configured limits, and return page content asynchronously as scrape-like results.

## What Crawl Is For
- Use `crawl` when one page is not enough and you need a constrained slice of a documentation site.
- Prefer `crawl` over `scrape` when navigation depth and path filters matter.
- Prefer `map` first when you need URL discovery without fetching page bodies.

## Working Request Shape
The pipeline spec models crawl requests like:

```json
{
  "url": "https://docs.example.com",
  "limit": 500,
  "maxDiscoveryDepth": 3,
  "includePaths": ["^/docs/", "^/api/"],
  "excludePaths": ["^/blog/", "^/changelog/", "\\.pdf$"],
  "scrapeOptions": {
    "formats": ["markdown"],
    "onlyMainContent": true
  }
}
```

The local ingest server uses the same structure with a smaller default limit and explicit polling against `GET /v2/crawl/{id}`.

## Key Capabilities
- **Bounded traversal:** `limit` and `maxDiscoveryDepth` keep the crawl from expanding indefinitely.
- **Path scoping:** `includePaths` and `excludePaths` are the main cost-control and relevance-control levers.
- **Scrape inheritance:** `scrapeOptions` lets crawl results reuse the same markdown-oriented extraction settings as single-page scrape operations.
- **Async execution:** the initial request returns a job ID; results arrive only after polling completes.

## Output Model
- `POST /v2/crawl` returns an ID immediately.
- `GET /v2/crawl/{id}` is polled until `status == "completed"`.
- Completed pages are treated as an array of scrape response objects, each with extracted content and metadata.

## Operational Guidance
- Use `includePaths` aggressively for docs sites; broad crawls waste credits and increase irrelevant retrieval.
- Treat crawl as an extraction primitive, not a synthesis primitive. Content still needs canonical storage, chunking, and embedding downstream.
- The current vault convention is markdown-first extraction with `onlyMainContent: true`.

## Distinction from Neighboring Endpoints
- [[firecrawl-scrape-capabilities]]: single-page retrieval, synchronous.
- [[firecrawl-map-capabilities]]: discovery of URLs without page content.
- [[firecrawl-api-v2-reference]]: broader endpoint surface and shared request/response conventions.

## Limits and Caveats
- This note is grounded in the local spec and ingest implementation, not a full live Firecrawl reference.
- Vendor-side limits, concurrency, and plan quotas may change; the pipeline spec currently notes page-tier limits and advises tight path filtering.
- "LLM-ready Markdown" should be read as cleaner-than-raw HTML, not as a guarantee that every page arrives perfectly normalized.

## Related
- [[spec-firecrawl-pgvector-pipeline]]
- [[protocol-source-ingestion-runbook]]
- [[firecrawl-map-capabilities]]
- [[firecrawl-scrape-capabilities]]
- [[firecrawl-api-v2-reference]]
