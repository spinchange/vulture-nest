CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS source_pages (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    url           TEXT NOT NULL UNIQUE,
    title         TEXT,
    description   TEXT,
    language      TEXT DEFAULT 'en',
    markdown      TEXT NOT NULL,
    status_code   INT,
    crawled_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    etag          TEXT,
    last_modified TEXT,
    content_hash  TEXT NOT NULL,
    status        TEXT NOT NULL DEFAULT 'Crawled',
    verified_at   TIMESTAMPTZ,
    promoted_at   TIMESTAMPTZ,
    promoted_note_path TEXT,
    domain        TEXT GENERATED ALWAYS AS (
        split_part(regexp_replace(url, 'https?://', ''), '/', 1)
    ) STORED
);

CREATE INDEX IF NOT EXISTS idx_source_pages_url ON source_pages(url);
CREATE INDEX IF NOT EXISTS idx_source_pages_domain ON source_pages(domain);
CREATE INDEX IF NOT EXISTS idx_source_pages_hash ON source_pages(content_hash);

CREATE TABLE IF NOT EXISTS source_chunks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    page_id         UUID NOT NULL REFERENCES source_pages(id) ON DELETE CASCADE,
    content         TEXT NOT NULL,
    content_hash    TEXT NOT NULL,
    source_url      TEXT NOT NULL,
    domain          TEXT NOT NULL,
    page_title      TEXT,
    section_heading TEXT,
    chunk_index     INT NOT NULL,
    chunk_total     INT NOT NULL,
    crawled_at      TIMESTAMPTZ NOT NULL,
    embedding       extensions.vector(1536),
    embedded_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chunks_page_id ON source_chunks(page_id);
CREATE INDEX IF NOT EXISTS idx_chunks_content_hash ON source_chunks(content_hash);
CREATE INDEX IF NOT EXISTS idx_chunks_domain ON source_chunks(domain);

CREATE INDEX IF NOT EXISTS idx_chunks_embedding ON source_chunks
    USING hnsw (embedding extensions.vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);

CREATE OR REPLACE FUNCTION match_documents(
    query_embedding extensions.vector(1536),
    match_threshold FLOAT DEFAULT 0.75,
    match_count INT DEFAULT 10,
    filter_domain TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    content TEXT,
    source_url TEXT,
    domain TEXT,
    page_title TEXT,
    section_heading TEXT,
    chunk_index INT,
    crawled_at TIMESTAMPTZ,
    similarity FLOAT
)
LANGUAGE SQL
STABLE
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
    ORDER BY c.embedding <=> query_embedding
    LIMIT match_count;
$$;
