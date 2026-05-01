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

Firecrawl's crawling feature allows for systematic retrieval of entire websites converted into clean, LLM-ready Markdown.

## Core Features
\ You can configure webhooks to receive real-time notifications as your crawl progresses. This allows you to process pages as they are scraped instead of waiting for the entire crawl to complete.\ \ cURL\ \ ```\ curl -X POST https://api.firecrawl.dev/v2/crawl \\ -H 'Content-Type: application/json' \\ -H 'Authorization: Bearer YOUR_API_KEY' \\ -d '{\ "url": "https://docs.firecrawl.dev",\ "limit": 100,\ "webhook": {\ "url": "https://your-domain.com/webhook",\ "metadata": {\ "any_key": "any_value"\ },\ "events": ["started", "page", "completed"]\ }\ }'\ ```\ \...

## Epistemic Status
Verified (T5) against the official Firecrawl documentation.

## Related
- [[spec-agentic-source-orchestrator]]
- [[firecrawl-map-capabilities]]
- [[firecrawl-scrape-capabilities]]
- [[firecrawl-api-v2-reference]]
