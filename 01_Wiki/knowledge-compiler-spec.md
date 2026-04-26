---
title: Knowledge Compiler Specification
author: 'gemini-cli, claude-sonnet-4-6'
date: 2026-04-26T00:00:00.000Z
status: active
type: permanent
aliases:
  - yanp-compiler
  - knowledge-compiler
---

# Knowledge Compiler Specification

This document provides the formal specification for compiling a YANP-compliant vault into a queryable, structured knowledge graph. It treats the vault not as a collection of documents, but as a codebase to be compiled.

## 1. Core Principles

- **Source:** YANP-compliant Markdown files (`.md`) in `01_Wiki/`.
- **Compiler:** The `ps-vault-maintenance` script orchestrates the compilation process.
- **Target:** A structured SQLite database (`wiki.db`) and a static HTML web portal.

## 2. Compilation Units

The fundamental unit of compilation is a **YANP Note** (a single `.md` file). The compiler must parse the following components within each note:

- **Frontmatter:** Parsed as a structured metadata block.
- **Headings (`##`):** Demarcate distinct logical sections or "sub-modules".
- **Paragraphs:** Treated as text content associated with the preceding heading.
- **Wikilinks (`''[[...]]''`):** Parsed as typed dependencies between compilation units.
- **Code Blocks:** Parsed as literal code, potentially with language identifiers.

## 3. Link Typing (Dependency Analysis)

Wikilinks are not uniform. The compiler must infer the type of a link based on context:

- **`[[note-a]]` in a paragraph:** A simple **reference** or association.
- **`[[note-b]]` under a `## References` or `## See Also` heading:** A **citation**.
- **`[[moc-a]]` in the **Hubs** line (top-level prose before the first `##`):** An **import** of a module or category.

The formal `link_type` values for the §5 schema are:

| Type | Value | Trigger context |
|---|---|---|
| Reference | `ref` | Wikilink in any non-References body section |
| Citation | `cite` | Wikilink under `## References` or `## See Also` |
| Import | `import` | Wikilink in the **Hubs** line before the first heading |

**Alias normalization:** The `''[[note|Display Text]]''` syntax is resolved at parse time. The target is the slug before the pipe; the display text is discarded. This is the invariant implemented in `sync-vault-graph.ps1` via `.Split('|')[0].Trim()`.

> **Current limitation:** `sync-vault-graph.ps1` v1 stores all links as untyped edges — the `link_type` column is a target state for v2. Section-context awareness (which heading a link appears under) is not yet implemented.

## 4. Compilation Pipeline (Optimization Passes)

The compilation process should follow a series of passes, orchestrated by `ps-vault-maintenance.ps1`:

1.  **Lexical Analysis (`audit-yanp.ps1`):** Verify YANP compliance (file names, frontmatter).
2.  **Dependency Resolution (`check-broken-links.ps1`):** Identify and report broken wikilinks (compilation errors).
3.  **Orphan Analysis (`orphan-check.ps1`):** Identify notes that are not linked to from anywhere else in the graph (warnings).
4.  **Code Generation (Static Site):** `generate-wiki.ps1` converts Markdown to HTML.
5.  **Code Generation (Graph):** `sync-vault-graph.ps1` populates the `Links` table in `wiki.db`. v1 performs a **full rebuild** each run: deletes all rows and re-inserts them in a single transaction. Correct for the current vault size; not incrementally scalable.
6.  **Graph Analysis (Read-Only):** `find-thin-nodes.ps1` identifies notes below a minimum in/out-link threshold. `generate-wiki-stats.ps1` produces aggregate metrics (note count, link count, hub rankings). These are analysis passes — they do not mutate the database.

## 5. Target Schema (SQLite)

### 5.1 Current Implementation (v1)

`sync-vault-graph.ps1` creates one table:

```sql
CREATE TABLE IF NOT EXISTS Links (
    Source TEXT,   -- note basename (no extension), e.g. "mcp-architecture"
    Target TEXT    -- raw wikilink target after alias normalization
);
CREATE INDEX IF NOT EXISTS idx_links_source ON Links(Source);
CREATE INDEX IF NOT EXISTS idx_links_target ON Links(Target);
```

Note basenames are used directly as identifiers — no numeric IDs. Human-readable but makes slug renames destructive (all `Source`/`Target` rows referencing the old slug go stale).

### 5.2 Target Schema (v2)

The full compilation target adds typed nodes, typed edges, and section-level granularity:

```sql
CREATE TABLE notes (
    id      INTEGER PRIMARY KEY,
    slug    TEXT UNIQUE NOT NULL,   -- basename, kebab-case (YANP invariant)
    title   TEXT NOT NULL,
    type    TEXT,                   -- frontmatter `type` field
    status  TEXT,                   -- frontmatter `status` field
    author  TEXT,
    mtime   INTEGER                 -- Unix epoch of last file modification
);

CREATE TABLE links (
    id          INTEGER PRIMARY KEY,
    source_id   INTEGER REFERENCES notes(id) ON DELETE CASCADE,
    target_id   INTEGER REFERENCES notes(id) ON DELETE SET NULL,
    link_type   TEXT CHECK(link_type IN ('ref', 'cite', 'import')),
    section     TEXT                -- heading under which the link appears, nullable
);

CREATE TABLE sections (
    id       INTEGER PRIMARY KEY,
    note_id  INTEGER REFERENCES notes(id) ON DELETE CASCADE,
    heading  TEXT NOT NULL,
    level    INTEGER,               -- heading depth: 2 = ##, 3 = ###
    content  TEXT                   -- raw Markdown body of the section
);

CREATE INDEX idx_links_source ON links(source_id);
CREATE INDEX idx_links_target ON links(target_id);
CREATE INDEX idx_links_type   ON links(link_type);
CREATE INDEX idx_notes_slug   ON notes(slug);
CREATE INDEX idx_notes_status ON notes(status);
```

**Migration path from v1:** The v1 `Links` table becomes a backwards-compatible view over the new schema:

```sql
CREATE VIEW Links AS
    SELECT s.slug AS Source, t.slug AS Target
    FROM links l
    JOIN notes s ON l.source_id = s.id
    LEFT JOIN notes t ON l.target_id = t.id;
```

`target_id` is nullable (`SET NULL`) because a wikilink may reference a note that hasn't been compiled yet — a broken link at the graph level, not a hard constraint violation.

---
## References
- [[community-living-knowledge-system]]
- [[ps-vault-maintenance]]
- [[yanp-for-agentic-workflows]]
- [[graphrag-concepts]]
- [[wiki-as-codebase]]
- [[hybrid-retrieval-spec]]
