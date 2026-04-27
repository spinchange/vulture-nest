---
title: Codex Handoff — Build Sprint (2026-04-27)
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: fleeting
targets:
  - codex
aliases:
  - codex-build-sprint-2026-04-27
  - codex-implementation-path
---

# Codex Handoff: Build Sprint 2026-04-27

## Context

Claude completed a full synthesis + blueprint session today. Four specs are now written and waiting to be implemented. This handoff gives you a sequenced build path: **read the spec, implement it, verify it, commit it.** Execute in order — each task produces an artifact the next one can depend on.

Do not modify existing vault notes unless a task explicitly requires it. Do not run `run-maintenance.ps1` between every step — save it for the end. Vault health must be 100/100 before your final commit.

---

## Task 1 — Gardening Audit (Read-Only, No Risk)

**Spec:** `01_Wiki/spec-knowledge-gardening.md` §2.1–2.2  
**Deliverable:** Triage list appended to `02_System/log.md`  
**Estimated effort:** Low — SQL queries + reading

### What to do

Run the Thin Node and Orphan identification queries from the spec against the vault's SQLite database (location: check `02_System/` for the db path or `$env:VAULT_DB`).

**Thin Node query** (from §2.1):
```sql
SELECT note_id, title, word_count, outbound_link_count, inbound_link_count
FROM Notes
WHERE word_count < 80
  AND outbound_link_count <= 1
  AND status = 'active'
  AND type NOT IN ('community', 'fleeting')
ORDER BY word_count ASC;
```

**Orphan query** (from §2.2):
```sql
SELECT n.note_id, n.title, n.type, n.date
FROM Notes n
LEFT JOIN Links l ON l.target_id = n.note_id
  AND l.source_id NOT IN (
    SELECT note_id FROM Notes WHERE type = 'community' OR title LIKE '%index%'
  )
WHERE l.target_id IS NULL
  AND n.status = 'active'
  AND n.type IN ('permanent', 'literature', 'spec')
ORDER BY n.date ASC;
```

Append the results as a Triage List to `02_System/log.md` under a new heading:
```markdown
## [2026-04-27] Gardening Audit — Triage List
| note_id | failure_mode | metric | suggested_action |
|---|---|---|---|
| ... | Thin Node | 45 words, 0 links | Expand or Absorb |
| ... | Orphan | 0 inbound | Wire |
```

**Do not execute any remediation actions.** List only. Claude will review and decide which actions to execute.

---

## Task 2 — Chunker Implementation (Python)

**Spec:** `01_Wiki/spec-firecrawl-pgvector-pipeline.md` §3  
**Output file:** `02_System/chunker.py`  
**Tests:** `02_System/test_chunker.py`  
**Estimated effort:** Medium — ~80 lines of code + tests

### What to implement

Implement `chunk_markdown()` and `split_by_heading()` from the spec verbatim. The spec gives you the full algorithm — transcribe it into a standalone Python module.

Key function signatures:
```python
def split_by_heading(markdown: str) -> list[tuple[str, str]]:
    """Returns list of (heading_text, section_body) tuples."""

def sliding_window(text: str, max_tokens: int, overlap: int) -> Iterator[str]:
    """Yields overlapping token windows over text."""

def chunk_markdown(markdown: str, page_meta: dict) -> list[dict]:
    """Returns list of chunk dicts with all provenance fields."""
```

Each chunk dict must contain exactly these keys (from the spec):
- `content`, `content_hash`, `section_heading`, `chunk_index`, `chunk_total`
- `source_url`, `domain`, `page_title`, `crawled_at`

Use `tiktoken` for token counting (model: `text-embedding-3-small` uses `cl100k_base`). If `tiktoken` is unavailable, fall back to `len(text.split()) * 1.3` as an approximation.

### Tests to write (`test_chunker.py`)

Cover these cases with `pytest`:

| Test | Input | Assertion |
|---|---|---|
| No headings | Markdown with no `#` lines | Single `(preamble)` section; content appears in at least one chunk |
| Empty section body | `## Heading\n\n## Next Heading\n\nbody` | Heading with empty body is skipped (no zero-word chunk) |
| Min chunk enforcement | Section with 30 words | Chunk is discarded (`< 50 words` rule from spec §3.2) |
| Overlap correctness | Two consecutive windows | Last `overlap_tokens` words of window N match first `overlap_tokens` words of window N+1 |
| `chunk_total` backfill | Any input | Every chunk in the returned list has identical `chunk_total` equal to `len(chunks)` |
| Provenance passthrough | `page_meta` with all fields | All provenance fields appear on every chunk |

---

## Task 3 — Memory MCP Server (Python)

**Spec:** `01_Wiki/spec-memory-mcp.md`  
**Output file:** `02_System/memory_mcp/server.py`  
**Schema file:** `02_System/memory_mcp/schema.sql`  
**Estimated effort:** Medium — ~200 lines

### What to implement

Implement the Python MCP server from spec §6. The spec gives you the full code — your job is to fill in the gaps, wire it together, and verify it runs.

**Step 1 — Schema file.** Create `schema.sql` from spec §2. Include:
- `session_memories` table with all columns and `UNIQUE(session_id, key)`
- `vault_memories` table with all columns including `embedding BLOB`
- Both FTS5 virtual tables (`session_fts`, `vault_fts`)
- All six `AFTER INSERT/DELETE/UPDATE` triggers for FTS sync
- All indexes

**Step 2 — Server.** `server.py` must:
- Init the DB from `schema.sql` on startup (idempotent — use `IF NOT EXISTS`)
- Read `SESSION_ID` from `MEMORY_MCP_SESSION_ID` env var (default `"default"`)
- Handle all three tools: `commit_memory`, `search_memories`, `prune_memory`
- Implement the bulk-vault-prune guard from spec §3.2: reject `prune_memory(scope="vault")` with no `key`, `older_than`, or `tags` filter
- On clean exit (SIGTERM or EOF): delete `session_memories` rows for current `SESSION_ID` unless `MEMORY_MCP_SESSION_PERSIST=true`

**Step 3 — Smoke test.** Write a `test_memory_mcp.py` that:
1. Inits the DB in a temp directory
2. Calls `commit_memory(scope="vault", key="test", content="hello world", tags=["test"])`
3. Calls `search_memories(query="hello", scope="vault")` and asserts the result contains `"test"`
4. Calls `prune_memory(scope="vault", key="test")` and asserts `pruned_count == 1`
5. Calls `prune_memory(scope="vault")` with no other args and asserts it raises/returns an error (the bulk-prune guard)

**Dependencies:** `mcp` (Python MCP SDK), `sqlite3` (stdlib). No other dependencies.

---

## Task 4 — Rust Tier-0 Scaffold

**Spec:** `01_Wiki/rust-tier-0-patterns.md`  
**Output directory:** `00_Raw/tier-0/`  
**Estimated effort:** High — Rust project + passing tests

### What to implement

Scaffold a runnable Rust binary project from the spec. The spec gives you all the types and functions — your job is to produce a buildable project with passing unit tests.

**Project structure:**
```
00_Raw/tier-0/
  Cargo.toml
  src/
    main.rs
    capability.rs   ← Capability enum, CapabilitySet
    state.rs        ← StateTransfer, ValidationError
    gate.rs         ← gate_delegation(), gate_handoff()
    proof.rs        ← GuardrailProof, ValidatedEnvelope
    error.rs        ← GateError
```

**`Cargo.toml` dependencies** (use current stable versions):
```toml
[dependencies]
tokio       = { version = "1", features = ["full"] }
serde       = { version = "1", features = ["derive"] }
serde_json  = "1"
thiserror   = "1"
hmac        = "0.12"
sha2        = "0.10"
hex         = "0.4"
chrono      = { version = "0.4", features = ["serde"] }

[dev-dependencies]
tokio-test  = "0.4"
```

**What to implement from the spec:**

| Spec section | Module | Types / fns |
|---|---|---|
| §1 | `capability.rs` | `Capability` enum (all 10 variants), `CapabilitySet`, `UnauthorizedCaps` |
| §2 | `state.rs` | `StateTransfer`, `ValidationError`, `StateTransfer::validate()` |
| §3 | `main.rs` | `receive_state()`, `send_state()`, `GateError` |
| §4 | `gate.rs` | `gate_delegation()`, `gate_handoff()`, **both unit tests** |
| §5 | `proof.rs` | `GuardrailProof`, `GuardrailProof::sign()`, `ValidatedEnvelope` |
| §6 | `main.rs` | `main()` loop (stub — can `todo!()` the config/infer calls) |

**Acceptance criteria:**
- `cargo build` succeeds with no errors (warnings acceptable)
- `cargo test` passes both unit tests from spec §4:
  - `delegation_cannot_escalate` — must return `Err`
  - `delegation_within_scope_succeeds` — must return `Ok` with correct effective caps

**`main()` loop:** The two `todo!()` placeholders (`load_scope_from_config`, `infer_required_caps`) may remain as stubs that `panic!("not implemented")`. The loop structure, gate call, and envelope signing must be present and compile.

---

## Verification & Commit

After all four tasks:

1. Run `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1`. Vault health must be 100/100.
2. Run `pytest 02_System/test_chunker.py 02_System/test_memory_mcp.py -v`. All tests must pass.
3. Run `cargo test` in `00_Raw/tier-0/`. Both unit tests must pass.
4. Append a `## [2026-04-27] Codex Build Sprint` entry to `02_System/log.md` listing what was built and all test results.

**Commit message format:**
```
feat(impl): Codex build sprint — chunker, memory MCP, Rust Tier-0, gardening audit

Task 1: gardening triage list appended to 02_System/log.md
Task 2: chunker.py + test_chunker.py (N tests passing)
Task 3: memory_mcp/server.py + schema.sql + test_memory_mcp.py (N tests passing)
Task 4: 00_Raw/tier-0/ Rust project (cargo test: 2/2 passing)
```

---

## Pre-verified Facts (Do Not Re-derive)

- The three specs are accurate and ready to implement — they were written from researched docs, not invented.
- `spec-memory-mcp.md` §6 Python code has a known gap: the spec uses `os.environ` but the import is missing — add `import os` at the top.
- `chunk_markdown()` in the spec calls `sliding_window()` which is not fully defined in the spec body — implement it as a standard token-window iterator with the given `max_tokens` and `overlap` parameters.
- The Rust `GuardrailProof::sign()` in spec §5 requires the `hmac` trait to be in scope: `use hmac::Mac;`.
- `spec-knowledge-gardening.md` queries assume a `Notes` table with columns `note_id`, `title`, `word_count`, `outbound_link_count`, `inbound_link_count`, `status`, `type`, `date`. Verify the actual schema before running — adapt column names if needed.

---

## References
- [[spec-knowledge-gardening]] — Task 1 source
- [[spec-firecrawl-pgvector-pipeline]] — Task 2 source
- [[spec-memory-mcp]] — Task 3 source
- [[rust-tier-0-patterns]] — Task 4 source
- [[capability-lattice-spec]] — Rust type background
- [[pattern-capability-gating]] — the pattern Task 4 implements
- [[inter-agent-handoff-protocol]] — handoff format reference
- [[gemini-build-sprint-handoff]]
- [[claude-blueprint-handoff]]