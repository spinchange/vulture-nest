---
title: 'Spec: Firecrawl + Postgres/pgvector Source Pipeline'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: spec
aliases:
  - firecrawl-pgvector-pipeline
  - source-ingestion-pipeline
  - research-assistant-pipeline
  - firecrawl-supabase-spec
---

# Spec: Firecrawl + Postgres/pgvector Source Pipeline

**Purpose:** Define the architecture for crawling external documentation sites, storing canonical source records in Postgres, chunking and embedding them with provenance, and retrieving semantically relevant chunks for a research assistant. This pipeline is **source material only** — it produces raw, attributed chunks for downstream synthesis agents. It is the ingestion layer of the vault's knowledge compiler.

```
External Docs/Sites
        │
        ▼
  [Firecrawl API]  ← crawl, clean, extract markdown
        │
        ▼
 [Canonical Store]  ← Postgres: one row per source page
        │
        ▼
 [Chunk + Embed]   ← split by heading → fixed-size, generate vectors
        │
        ▼
  [pgvector Index]  ← Supabase: HNSW cosine index on chunks
        │
        ▼
[match_documents()]  ← semantic search RPC → research assistant
```

---

## 1. Firecrawl — Crawl & Extraction Layer

Firecrawl is a hosted crawling service that returns LLM-optimized Markdown from any URL, handling JS rendering, bot detection, and content extraction. It is not a chunker — all splitting happens downstream.

### 1.1 Key Endpoints

| Endpoint | Use | Returns |
|---|---|---|
| `POST /v2/scrape` | Single page | Markdown + metadata, synchronous |
| `POST /v2/crawl` | Multi-page site | Job ID; poll for results (async) |
| `POST /v2/map` | Discover all URLs | URL list only, no content |
| `POST /v2/extract` | Structured LLM extraction | JSON matching a provided schema |
| `POST /v2/search` | Web search + extract | Top-N results as markdown |

### 1.2 Scrape Request

```json
POST /v2/scrape
{
  "url": "https://docs.firecrawl.dev/features/crawl",
  "formats": ["markdown", "links"],
  "onlyMainContent": true,
  "excludeTags": ["nav", "footer", "header", ".sidebar"],
  "waitFor": 1000
}
```

| Parameter | Type | Notes |
|---|---|---|
| `formats` | `string[]` | `"markdown"`, `"html"`, `"links"`, `"screenshot"`, `"extract"` |
| `onlyMainContent` | `bool` | Strips nav/footer/sidebar — **always true** for doc ingestion |
| `excludeTags` | `string[]` | CSS selectors to remove before extraction |
| `waitFor` | `int` (ms) | Wait for JS to render before scraping |

### 1.3 Scrape Response Object

```json
{
  "success": true,
  "data": {
    "markdown": "# Page Title\n\nContent...",
    "links": ["https://docs.example.com/page-2", "..."],
    "metadata": {
      "title": "Page Title",
      "description": "Meta description",
      "language": "en",
      "keywords": ["keyword1"],
      "statusCode": 200,
      "contentType": "text/html",
      "sourceURL": "https://docs.example.com/page-1"
    }
  }
}
```

### 1.4 Crawl Request (Multi-Page)

```json
POST /v2/crawl
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

Returns `{ "id": "crawl_job_abc123" }` immediately. Poll `GET /v2/crawl/{id}` until `status: "completed"`. Results are an array of the same scrape response objects.

**Rate limits:** Free 500 pages/month · Hobby 3k · Standard 100k (50 concurrent). Use `includePaths` aggressively to avoid wasting credits on irrelevant pages.

---

## 2. Postgres Schema — Canonical Source Store

Two tables: `source_pages` holds the raw canonical record (one per URL); `source_chunks` holds the processed chunks with embeddings and provenance. This separation means re-chunking or re-embedding never touches the canonical record.

```sql
-- Enable the pgvector extension (Supabase: already available in extensions schema)
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- for gen_random_uuid()

-- Canonical record: one row per crawled URL
CREATE TABLE source_pages (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    url          TEXT NOT NULL UNIQUE,
    title        TEXT,
    description  TEXT,
    language     TEXT DEFAULT 'en',
    markdown     TEXT NOT NULL,         -- raw Firecrawl output, untouched
    status_code  INT,
    crawled_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    etag         TEXT,                  -- HTTP ETag for dedup on re-crawl
    last_modified TEXT,                 -- HTTP Last-Modified header
    content_hash TEXT NOT NULL,        -- SHA-256 of markdown for change detection
    domain       TEXT GENERATED ALWAYS AS (
                     split_part(regexp_replace(url, 'https?://', ''), '/', 1)
                 ) STORED
);

CREATE INDEX idx_source_pages_url    ON source_pages(url);
CREATE INDEX idx_source_pages_domain ON source_pages(domain);
CREATE INDEX idx_source_pages_hash   ON source_pages(content_hash);

-- Chunks: one row per embedded chunk, all provenance carried inline
CREATE TABLE source_chunks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    page_id         UUID NOT NULL REFERENCES source_pages(id) ON DELETE CASCADE,

    -- Content
    content         TEXT NOT NULL,
    content_hash    TEXT NOT NULL,      -- SHA-256 of chunk text; skip re-embed if unchanged

    -- Provenance (fully denormalized for fast retrieval — no join needed at query time)
    source_url      TEXT NOT NULL,
    domain          TEXT NOT NULL,
    page_title      TEXT,
    section_heading TEXT,               -- nearest H1/H2/H3 above this chunk
    chunk_index     INT NOT NULL,       -- 0-based position within the page
    chunk_total     INT NOT NULL,       -- total chunks for this page
    crawled_at      TIMESTAMPTZ NOT NULL,

    -- Vector
    embedding       extensions.vector(1536),   -- set D to match your embedding model

    -- Timestamps
    embedded_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chunks_page_id      ON source_chunks(page_id);
CREATE INDEX idx_chunks_content_hash ON source_chunks(content_hash);
CREATE INDEX idx_chunks_domain       ON source_chunks(domain);

-- HNSW index for cosine similarity (build after initial bulk insert)
CREATE INDEX idx_chunks_embedding ON source_chunks
    USING hnsw (embedding extensions.vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);
```

**Why HNSW over IVFFlat?**
- HNSW builds on an empty table — no training step, so it's safe for incremental inserts.
- Better query speed-recall tradeoff at the cost of higher memory.
- `m=16` and `ef_construction=64` are good defaults; tune up to `m=32, ef_construction=128` for higher recall at the cost of index build time.

**Embedding dimensions:** Set `vector(D)` to match your model:

| Model | D |
|---|---|
| OpenAI `text-embedding-3-small` | 1536 |
| OpenAI `text-embedding-ada-002` | 1536 |
| OpenAI `text-embedding-3-large` | 3072 |
| Cohere `embed-english-v3.0` | 1024 |
| `gte-small` (open source) | 384 |

---

## 3. Chunking Strategy

Firecrawl returns clean Markdown — the pipeline splits it before embedding. **Recommended: heading-aware hybrid chunking.**

### 3.1 Algorithm

```python
import re, hashlib
from typing import Iterator

MAX_CHUNK_TOKENS = 512    # ~400 words
OVERLAP_TOKENS   = 50     # ~40 words; carry context across chunk boundary

def chunk_markdown(markdown: str, page_meta: dict) -> list[dict]:
    """Split markdown by heading, then fixed-size within each section."""
    sections = split_by_heading(markdown)  # list of (heading, text) tuples
    chunks = []
    idx = 0

    for heading, section_text in sections:
        for window in sliding_window(section_text, MAX_CHUNK_TOKENS, OVERLAP_TOKENS):
            chunks.append({
                "content":         window,
                "content_hash":    sha256(window),
                "section_heading": heading,
                "chunk_index":     idx,
                "source_url":      page_meta["url"],
                "domain":          extract_domain(page_meta["url"]),
                "page_title":      page_meta["title"],
                "crawled_at":      page_meta["crawled_at"],
            })
            idx += 1

    # Backfill chunk_total now that we know it
    for c in chunks:
        c["chunk_total"] = idx

    return chunks

def split_by_heading(markdown: str) -> list[tuple[str, str]]:
    """Split on H1/H2/H3 headings. Returns list of (heading_text, section_body)."""
    pattern = re.compile(r'^(#{1,3} .+)$', re.MULTILINE)
    parts = pattern.split(markdown)
    # parts alternates: [preamble, heading, body, heading, body, ...]
    result = [("(preamble)", parts[0])]
    for i in range(1, len(parts), 2):
        heading = parts[i].lstrip('#').strip()
        body    = parts[i+1] if i+1 < len(parts) else ""
        if body.strip():
            result.append((heading, body))
    return result

def sha256(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()
```

### 3.2 Chunking Rules of Thumb

| Decision | Guidance |
|---|---|
| Chunk size | 256–512 tokens for precise retrieval; 512–1024 for richer context |
| Overlap | 10–20% of chunk size; ensures no fact is cut across a boundary |
| Split boundaries | Always prefer heading → paragraph → sentence over mid-sentence cuts |
| Minimum chunk | Discard chunks < 50 words — too thin to embed meaningfully |
| Section heading | Carry the **nearest ancestor heading** (H1 > H2 > H3), not just the immediate one |

---

## 4. Deduplication

Two levels prevent wasted API calls and embedding credits.

### 4.1 URL-Level (ETag / Last-Modified)

Before re-crawling a URL, issue an HTTP HEAD request:
```python
resp = httpx.head(url, headers={"If-None-Match": stored_etag})
if resp.status_code == 304:
    return  # content unchanged — skip Firecrawl entirely
```

Store `etag` and `last_modified` in `source_pages`. Update on every full crawl.

### 4.2 Content-Level (SHA-256 Hash)

After chunking, check if each chunk's `content_hash` already exists:
```sql
SELECT id FROM source_chunks WHERE content_hash = $1;
```
If the hash exists, skip the embedding API call and reuse the existing row. This reduces embedding costs ~90% for stable documentation sites on re-crawl.

**Upsert pattern** for `source_pages`:
```sql
INSERT INTO source_pages (url, title, markdown, content_hash, crawled_at, etag, ...)
VALUES ($1, $2, $3, $4, NOW(), $5, ...)
ON CONFLICT (url) DO UPDATE
    SET markdown      = EXCLUDED.markdown,
        content_hash  = EXCLUDED.content_hash,
        crawled_at    = EXCLUDED.crawled_at,
        etag          = EXCLUDED.etag
    WHERE source_pages.content_hash != EXCLUDED.content_hash;
-- WHERE clause: only update if content actually changed
```

When a page's `content_hash` changes on re-crawl: delete its old chunks (`ON DELETE CASCADE` handles this), re-chunk, re-embed, insert fresh chunks.

---

## 5. Semantic Search — `match_documents` RPC

Supabase's PostgREST layer cannot call pgvector operators directly from the client. Wrap the similarity query in a Postgres function:

```sql
CREATE OR REPLACE FUNCTION match_documents(
    query_embedding extensions.vector(1536),
    match_threshold  FLOAT   DEFAULT 0.75,
    match_count      INT     DEFAULT 10,
    filter_domain    TEXT    DEFAULT NULL   -- optional: restrict to one site
)
RETURNS TABLE (
    id              UUID,
    content         TEXT,
    source_url      TEXT,
    domain          TEXT,
    page_title      TEXT,
    section_heading TEXT,
    chunk_index     INT,
    crawled_at      TIMESTAMPTZ,
    similarity      FLOAT
)
LANGUAGE SQL STABLE
AS $$
    SELECT
        c.id,
        c.content,
        c.source_url,
        c.domain,
        c.page_title,
        c.section_heading,
        c.chunk_index,
        c.crawled_at,
        1 - (c.embedding <=> query_embedding) AS similarity
    FROM source_chunks c
    WHERE
        (filter_domain IS NULL OR c.domain = filter_domain)
        AND 1 - (c.embedding <=> query_embedding) > match_threshold
    ORDER BY c.embedding <=> query_embedding   -- ascending distance = descending similarity
    LIMIT match_count;
$$;
```

**Call from TypeScript (supabase-js):**
```typescript
const { data, error } = await supabase.rpc('match_documents', {
    query_embedding:  await embed(userQuery),   // float[] from your embedding model
    match_threshold:  0.75,
    match_count:      8,
    filter_domain:    'docs.firecrawl.dev'      // null for all domains
});
// data: Array<{ id, content, source_url, section_heading, similarity }>
```

**Call from Python:**
```python
results = supabase.rpc('match_documents', {
    'query_embedding': embed(user_query),
    'match_threshold': 0.75,
    'match_count': 8,
}).execute()
```

**Similarity threshold guidance:**
- `> 0.85` — high precision, low recall (near-exact match)
- `0.75–0.85` — balanced (recommended default)
- `0.60–0.75` — broad retrieval; useful for exploratory research
- `< 0.60` — nearly all chunks; not useful for RAG

---

## 6. Research Assistant Assembly

The pipeline produces chunks; a research assistant wraps them with a synthesis step:

```
User query
    │
    ▼
embed(query) → query_embedding
    │
    ▼
match_documents(query_embedding, threshold=0.75, count=8)
    │
    ▼
Deduplicate by page (take top-N chunks per source_url to avoid over-representing one page)
    │
    ▼
Build context window:
  For each chunk:
    "[Source: {page_title} — {section_heading}]\n{content}\n"
    "[URL: {source_url}, crawled {crawled_at}]\n\n"
    │
    ▼
LLM prompt:
  SYSTEM: "You are a research assistant. Answer using only the provided sources.
           Cite sources by URL for every claim."
  USER:   "{user_query}\n\n---SOURCES---\n{context_window}"
    │
    ▼
Response with inline citations → vault note (type: literature or fleeting)
```

**Provenance in the response:** Every claim the assistant makes can be traced back to a `source_url` + `section_heading` + `chunk_index` + `crawled_at`. This triad is the attribution record — sufficient to re-fetch and verify any claim.

---

## 7. Ingestion Script Skeleton (Python)

```python
import httpx, hashlib, asyncio
from supabase import create_client

FIRECRAWL_KEY = os.environ["FIRECRAWL_API_KEY"]
SUPABASE_URL  = os.environ["SUPABASE_URL"]
SUPABASE_KEY  = os.environ["SUPABASE_SERVICE_KEY"]

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

async def ingest_site(root_url: str, include_paths: list[str] = None):
    # 1. Crawl
    job = httpx.post("https://api.firecrawl.dev/v2/crawl",
        headers={"Authorization": f"Bearer {FIRECRAWL_KEY}"},
        json={
            "url": root_url,
            "limit": 200,
            "maxDiscoveryDepth": 3,
            "includePaths": include_paths or [],
            "scrapeOptions": {"formats": ["markdown"], "onlyMainContent": True}
        }).json()

    # 2. Poll until done
    while True:
        status = httpx.get(f"https://api.firecrawl.dev/v2/crawl/{job['id']}",
            headers={"Authorization": f"Bearer {FIRECRAWL_KEY}"}).json()
        if status["status"] == "completed":
            pages = status["data"]
            break
        await asyncio.sleep(5)

    # 3. For each page: upsert canonical record + chunk + embed
    for page in pages:
        md   = page["data"]["markdown"]
        meta = page["data"]["metadata"]
        url  = meta["sourceURL"]
        h    = sha256(md)

        # Upsert canonical record
        supabase.table("source_pages").upsert({
            "url": url, "title": meta.get("title"), "markdown": md,
            "content_hash": h, "status_code": meta.get("statusCode"),
        }, on_conflict="url").execute()

        # Re-chunk only if content changed
        existing = supabase.table("source_pages")\
            .select("id").eq("url", url).eq("content_hash", h).execute()
        if not existing.data:
            continue  # hash unchanged from previous run

        page_id = existing.data[0]["id"]

        # Delete stale chunks
        supabase.table("source_chunks").delete().eq("page_id", page_id).execute()

        # Chunk, embed, insert
        chunks = chunk_markdown(md, {"url": url, "title": meta.get("title"),
                                      "crawled_at": datetime.utcnow().isoformat()})
        for chunk in chunks:
            existing_embed = supabase.table("source_chunks")\
                .select("id").eq("content_hash", chunk["content_hash"]).execute()
            if existing_embed.data:
                continue  # reuse existing embedding

            embedding = await embed(chunk["content"])  # your embedding model call
            supabase.table("source_chunks").insert({
                **chunk, "page_id": page_id, "embedding": embedding
            }).execute()
```

---

## 8. Connections to Vault

This pipeline is the **ingestion layer** for all external sources referenced in the vault. Its output (chunks + provenance) feeds:

- [[semantic-embedding-pipeline]] — which handles *internal* vault note embeddings; this spec handles *external* source embeddings. The two can share the same Supabase instance with separate tables.
- [[community-report-generator]] — community reports can be grounded in external source chunks, not just internal notes.
- [[spec-memory-mcp]] — the Memory MCP Server can be extended to serve `source_chunks` rows in addition to agent memories (same `match_documents` pattern, separate resource: `memory://sources`).
- [[lit-mcp-architecture]] — the `match_documents` RPC is a natural fit for an MCP Tool (`search_sources`), exposing this pipeline to any MCP-compatible agent.

---

## References
- [[semantic-embedding-pipeline]]
- [[spec-memory-mcp]]
- [[lit-mcp-architecture]]
- [[community-report-generator]]
- [[graphrag-concepts]]
- [[hybrid-retrieval-spec]]
