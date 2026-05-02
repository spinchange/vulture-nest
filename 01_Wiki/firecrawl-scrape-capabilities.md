---
title: Firecrawl Scrape Capabilities
author: gemini-cli
date: 2026-04-30
status: active
type: permanent
aliases:
  - firecrawl-scrape
provenance_source_ids:
  - "0806512a-29d2-4c09-86fc-e863bb771eb5"
provenance_chunk_ids:
  - "a89bc8bf-9b1a-4657-9c3f-a149d273c326"
provenance_retrieved: "2026-05-01T03:54:18Z"
provenance_agent: "claude-chronicler"
---

# Firecrawl Scrape Capabilities

Firecrawl's `scrape` endpoint is the single-page retrieval path: fetch one URL, extract cleaned content, and return it synchronously with metadata.

## What Scrape Is For
- Targeted retrieval of one known page.
- Fast validation of a source before broader crawling.
- Pulling markdown and lightweight metadata into the canonical source store.

## Working Request Shape
The pipeline spec models scrape like this:

```json
{
  "url": "https://docs.firecrawl.dev/features/crawl",
  "formats": ["markdown", "links"],
  "onlyMainContent": true,
  "excludeTags": ["nav", "footer", "header", ".sidebar"],
  "waitFor": 1000
}
```

## Important Options
- `formats`: determines which representations are returned. The local spec mentions `markdown`, `html`, `links`, `screenshot`, and `extract`.
- `onlyMainContent`: strips navigation-heavy regions and is the default posture for documentation ingestion in this vault.
- `excludeTags`: removes known noisy elements before extraction.
- `waitFor`: allows JavaScript-rendered pages to settle before retrieval.

## Response Shape
The pipeline spec expects a synchronous response with:
- extracted content such as `markdown`
- optional related data such as `links`
- `metadata` including title, description, status code, content type, language, and source URL

## Distinction from Crawl and Map
- [[firecrawl-crawling-capabilities]]: multi-page traversal with async polling.
- [[firecrawl-map-capabilities]]: URL discovery without content retrieval.
- `scrape` is the atomic retrieval unit underneath broader ingestion flows.

## Operational Guidance
- Use scrape first when you only need one page or want to test extraction quality on a candidate URL.
- Keep `onlyMainContent: true` for docs ingestion unless you explicitly need navigation or surrounding chrome.
- Treat "clean Markdown" as useful extracted text, not as a guarantee of perfect structural fidelity.

## Caveats
- This note is derived from the local pipeline spec rather than a full live Firecrawl endpoint audit.
- If the vault starts relying on less common scrape options, expand this note with concrete examples from implementation and tests.

## Related
- [[spec-firecrawl-pgvector-pipeline]]
- [[protocol-source-ingestion-runbook]]
- [[firecrawl-crawling-capabilities]]
- [[firecrawl-map-capabilities]]
- [[firecrawl-api-v2-reference]]
