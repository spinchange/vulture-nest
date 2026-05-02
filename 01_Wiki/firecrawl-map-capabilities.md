---
title: Firecrawl Map Capabilities
author: gemini-cli
date: 2026-04-30
status: active
type: permanent
aliases:
  - firecrawl-map
provenance_source_ids:
  - "76b301cc-f34a-49f1-90fb-89bb9b9c481f"
provenance_chunk_ids:
  - "3e892a27-8051-428b-9090-e69465a36686"
  - "b4f20958-d722-4e55-a935-4e6907f44aae"
  - "a0f1c9cf-b493-42ef-ba25-0df15fdff1cb"
provenance_retrieved: "2026-05-01T03:52:17Z"
provenance_agent: "claude-chronicler"
---

# Firecrawl Map Capabilities

The Firecrawl `map` endpoint is the discovery-only counterpart to crawl: it enumerates candidate URLs on a site without retrieving full page bodies.

## Role in the Ingestion Pipeline
- Use `map` to understand the URL surface of a domain before spending crawl credits.
- Use it when you need to choose bounds, refine include/exclude patterns, or estimate the scope of a docs section.
- It complements [[firecrawl-crawling-capabilities]] rather than replacing it.

## What Map Returns
In the vault's mental model, `map` returns URL discovery results only:
- candidate URLs
- enough structure to decide what to crawl next
- no markdown body extraction

That makes `map` the lowest-cost recon step in the Firecrawl family represented here.

## Practical Use
- Start with `map` when the site structure is unknown.
- Promote promising sections into a bounded `crawl`.
- Use `scrape` when you already know the exact page you want.

## Why Keep It Separate from Crawl
- `map` answers: "What is here?"
- `crawl` answers: "Fetch these pages and give me content."
- `scrape` answers: "Fetch this one page now."

That distinction matters operationally because discovery, retrieval, and synthesis have different cost and risk profiles.

## Known Parameters and Limits
The local pipeline spec does not provide the same level of parameter detail for `map` that it provides for `scrape` and `crawl`. Treat this note as a conceptual reference first, not an exhaustive parameter sheet.

## Caveats
- This rewrite is based on the pipeline spec's description of `POST /v2/map` as "Discover all URLs" plus surrounding ingestion design, not a live endpoint walkthrough.
- If the vault begins using `map` programmatically, this note should be extended with concrete request and response examples from the implementation path.

## Related
- [[spec-firecrawl-pgvector-pipeline]]
- [[protocol-source-ingestion-runbook]]
- [[firecrawl-crawling-capabilities]]
- [[firecrawl-scrape-capabilities]]
- [[firecrawl-api-v2-reference]]
