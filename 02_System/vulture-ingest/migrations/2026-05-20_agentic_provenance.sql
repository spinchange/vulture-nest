ALTER TABLE source_pages
    ADD COLUMN IF NOT EXISTS proposed_by TEXT,
    ADD COLUMN IF NOT EXISTS proposed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS mapped_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS approval_mode TEXT,
    ADD COLUMN IF NOT EXISTS crawl_job_id TEXT,
    ADD COLUMN IF NOT EXISTS indexed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS indexed_by TEXT,
    ADD COLUMN IF NOT EXISTS verified_by TEXT,
    ADD COLUMN IF NOT EXISTS promoted_by TEXT,
    ADD COLUMN IF NOT EXISTS provenance_context JSONB;

UPDATE source_pages
SET provenance_context = '{}'::jsonb
WHERE provenance_context IS NULL;

ALTER TABLE source_pages
    ALTER COLUMN provenance_context SET DEFAULT '{}'::jsonb,
    ALTER COLUMN provenance_context SET NOT NULL;

CREATE INDEX IF NOT EXISTS idx_source_pages_status ON source_pages(status);
CREATE INDEX IF NOT EXISTS idx_source_pages_indexed_by ON source_pages(indexed_by);
CREATE INDEX IF NOT EXISTS idx_source_pages_promoted_by ON source_pages(promoted_by);

CREATE TABLE IF NOT EXISTS source_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    page_id         UUID REFERENCES source_pages(id) ON DELETE CASCADE,
    source_url      TEXT NOT NULL,
    lifecycle_stage TEXT NOT NULL,
    event_type      TEXT NOT NULL,
    acting_agent    TEXT NOT NULL DEFAULT 'codex-engineer',
    requested_by    TEXT,
    human_approved  BOOLEAN,
    note_path       TEXT,
    details         JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_source_events_page_id ON source_events(page_id);
CREATE INDEX IF NOT EXISTS idx_source_events_source_url ON source_events(source_url);
CREATE INDEX IF NOT EXISTS idx_source_events_stage ON source_events(lifecycle_stage);
CREATE INDEX IF NOT EXISTS idx_source_events_agent ON source_events(acting_agent);
