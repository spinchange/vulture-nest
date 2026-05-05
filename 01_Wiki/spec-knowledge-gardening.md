---
title: 'Spec: Knowledge Gardening & Pruning'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: spec
aliases:
  - knowledge-gardening
  - vault-pruning-protocol
  - gardening-spec
---

# Spec: Knowledge Gardening & Pruning

**Purpose:** Define the operational protocol for keeping the vault high-signal over time. As the vault grows, three failure modes emerge: **Thin Nodes** (low information density), **Orphaned Concepts** (unreachable from the graph), and **Concept Drift** (content that no longer matches its declared identity). This spec defines how to detect and remediate all three.

A Gardening Session is a structured audit-and-action cycle, not an ad-hoc cleanup. Each session should be logged in [[log]] with the date, candidates found, and actions taken.

---

## 1. Failure Mode Taxonomy

| Failure Mode | Definition | Risk |
|---|---|---|
| **Thin Node** | A note with low information density — too short or too sparsely connected to contribute synthesis value | Acts as a dead weight in retrieval; dilutes community reports |
| **Orphan** | A note with zero inbound wikilinks — unreachable from the rest of the graph | Never retrieved in graph traversal; knowledge siloed |
| **Concept Drift** | A note whose content has diverged from its `title` and `aliases` — the note is about something different than its declared identity | Breaks semantic retrieval; misleads agents that rely on the title |
| **Blob** | A note that has grown so large it contains multiple distinct concepts | Should be split; inhibits precision retrieval |
| **Shadow Duplicate** | Two notes with high content overlap (> 60% semantic similarity) | Fragmented knowledge; inconsistency risk |

---

## 2. Identification Metrics

### 2.1 Thin Node

A note qualifies as Thin if it meets **two or more** of the following:

| Metric | Thin threshold |
|---|---|
| Word count (body, excl. frontmatter) | < 80 words |
| Outbound wikilinks | ≤ 1 |
| Inbound wikilinks | 0 |
| Number of H2 sections | 0 (no structure) |
| `type` | `fleeting` with `status: active` and age > 14 days |

**Query (SQLite):**
```sql
SELECT note_id, title, word_count, outbound_link_count, inbound_link_count
FROM Notes
WHERE word_count < 80
  AND outbound_link_count <= 1
  AND status = 'active'
  AND type NOT IN ('community', 'fleeting')  -- communities are auto-generated; fleeting handled separately
ORDER BY word_count ASC;
```

**Agent action options:**
- **Expand:** Add synthesis prose, connections, and references to bring the note to full density.
- **Absorb:** Merge the thin note's content into the most-linked parent note, redirect all wikilinks, delete the thin note.
- **Archive:** If the concept is genuinely complete at low density (e.g., a pure cross-reference), set `status: archived`.

### 2.2 Orphaned Concept

A note with `inbound_link_count = 0` from *other permanent/literature notes* (system notes like `index.md` don't count as meaningful inbound links).

```sql
SELECT n.note_id, n.title, n.type, n.date
FROM Notes n
LEFT JOIN Links l ON l.target_id = n.note_id
  AND l.source_id NOT IN (SELECT note_id FROM Notes WHERE type = 'community' OR title LIKE '%index%')
WHERE l.target_id IS NULL
  AND n.status = 'active'
  AND n.type IN ('permanent', 'literature', 'spec')
ORDER BY n.date ASC;
```

**Agent action options:**
- **Wire:** Find 2–3 thematically related notes and add `[[orphan-note]]` wikilinks to their References sections.
- **Absorb:** If the concept belongs inside a larger note, merge and redirect.
- **Archive:** If the concept is complete and genuinely standalone (rare), demote to `status: archived`.

### 2.3 Concept Drift

Drift is measured by comparing the embedding of the note's title + aliases against the embedding of its full body content. A high drift score means the note has "wandered" away from its declared identity.

**Detection algorithm:**
```python
import numpy as np

def drift_score(note_id: str, db) -> float:
    title_aliases = db.get_title_and_aliases(note_id)   # e.g., "rust-tier-0-patterns Rust Safe Core tier-0-substrate"
    body_text = db.get_body_text(note_id)
    
    title_emb = embed(title_aliases)   # call embedding model
    body_emb  = embed(body_text)
    
    cosine_sim = np.dot(title_emb, body_emb) / (np.linalg.norm(title_emb) * np.linalg.norm(body_emb))
    return 1.0 - cosine_sim  # 0.0 = perfect alignment; 1.0 = completely unrelated

# Flag notes with drift_score > 0.30
```

**Supplementary signal (no embedding required):**
- Aliases contain terms that do not appear in the body text.
- The note has accumulated ≥ 3 dated appendix sections that collectively redirect to a different topic.
- The note's `type` field no longer matches its content structure (e.g., `type: permanent` but it reads like a fleeting session log).

**Agent action options:**
- **Retitle:** Update `title` and `aliases` to match current content.
- **Refocus:** Rewrite the body to realign with the declared title — move drifted content to a new note.
- **Split:** If both the original concept AND the drifted content are valuable, split into two separate notes.

### 2.4 Blob Detection

A note qualifies as a Blob if it meets **two or more** of the following:

| Metric | Blob threshold |
|---|---|
| Word count | > 1,500 words |
| Number of H2 sections | > 8 |
| Title contains "and" or "/" | e.g., "A and B Patterns" |
| Number of distinct concepts in aliases | ≥ 4 unrelated terms |
| Embedding variance across sections | > 0.25 (measured by section-level embeddings) |

### 2.5 Shadow Duplicate Detection

Two notes qualify as Shadow Duplicates if their body embedding cosine similarity > 0.82 AND they share < 20% of their wikilinks (meaning they are not intentionally complementary notes on the same topic from different angles).

```sql
SELECT a.note_id as note_a, b.note_id as note_b, e.similarity
FROM NoteEmbeddingSimilarity e
JOIN Notes a ON e.note_a_id = a.note_id
JOIN Notes b ON e.note_b_id = b.note_id
WHERE e.similarity > 0.82
  AND a.note_id < b.note_id  -- avoid duplicates in result set
ORDER BY e.similarity DESC;
```

---

## 3. Remediation Actions

### 3.1 Absorb (Merge Into Parent)

Use when: a thin node or orphan belongs conceptually inside a larger, better-connected note.

**Protocol:**
1. Identify the target (absorbing) note.
2. Append the thin note's unique content to the target under a new H3 section.
3. In every note that wikilinked to the thin note, replace `[[thin-note]]` with `[target-note#new-section|thin-note]`.
4. Set the thin note's frontmatter to `status: archived` and add a redirect line: `> Merged into [target-note] on YYYY-MM-DD.`
5. Do **not** delete the thin note file — Git history and inbound links from external sources may still reference it.
6. Log the merge in [[log]].

### 3.2 Split (Concept → MOC + Children)

Use when: a Blob has grown to contain multiple distinct first-class concepts.

**Protocol:**
1. Identify the distinct sub-concepts (each becomes a child note).
2. Create each child note as a new `type: permanent` file with full frontmatter.
3. Replace the Blob's content sections with wikilinks to the child notes.
4. Promote the Blob to `type: community` or keep as a `permanent` MOC-style note (depending on whether it serves as a hub or a synthesis).
5. Update the `index.md` to reflect the new structure.
6. Verify no new orphans are created by the split — all child notes must be wikilinked from at least the parent.

**When to promote to MOC:** If the original note was functioning as a hub (lots of inbound links, minimal unique prose), convert it to a MOC explicitly. Set `type: community` and restructure as a bullet-list of `[[child-note]] — one-line summary` entries.

### 3.3 Wire (Add Inbound Links)

Use when: an orphan is genuinely valuable but simply missed during the linking phase.

**Protocol:**
1. Search the vault for notes that discuss related concepts (semantic search on the orphan's title + body).
2. For the top 3–5 results, add `[[orphan-note]]` to their References section with a one-line annotation.
3. Verify the orphan itself links back to those notes.
4. Log in [[log]].

### 3.4 Retitle / Refocus (Drift Correction)

**Protocol:**
1. Read the full note body to determine its actual current topic.
2. If the current content is coherent but the title is stale: update `title`, `aliases`, and the H1 heading. Update all inbound wikilinks that used the old title text.
3. If the note mixes old and new content: extract the new-topic content into a fresh note. Leave the original focused on its declared topic. Wire the two notes to each other.
4. Re-embed the note after changes to reset its position in the semantic graph.

---

## 4. Gardening Session Protocol

A complete Gardening Session runs in four phases:

### Phase 1: Audit (Automated)
Run the identification queries and algorithms above. Produce a **Triage List** — a markdown table in `02_System/log.md` with columns: `note_id | failure_mode | metric_value | suggested_action`.

Expected session scope: 5–15 candidates per 50 notes added since the last session.

### Phase 2: Triage (Agent Review)
For each candidate, the gardening agent reads the note and confirms or overrides the suggested action. Valid outcomes: `Expand`, `Absorb`, `Wire`, `Split`, `Retitle`, `Archive`, `OK (false positive)`.

Rule: **Never delete** — only archive. Deletion is a destructive action that breaks Git history and external links.

### Phase 3: Action (Execution)
Execute actions in this order to minimize link breakage:
1. **Splits** first — new notes exist before their parent is restructured.
2. **Merges / Absorbs** second — redirect links after target notes are updated.
3. **Wires** third — link additions are pure additions, no breakage risk.
4. **Retitles** last — update all inbound links after the note is stable.

### Phase 4: Verification
After all actions:
```sql
-- Confirm no new orphans were created
SELECT note_id, title FROM Notes
WHERE inbound_link_count = 0 AND status = 'active' AND type = 'permanent';

-- Confirm no broken wikilinks (links pointing to non-existent notes)
SELECT source_id, target_ref FROM Links WHERE resolved = 0;
```

Log the session summary: notes audited, actions taken, net orphan count change, net thin node count change.

---

## 5. Cadence

| Trigger | Action |
|---|---|
| Every 50 notes added | Full Gardening Session |
| Any new Literature note created | Wire-only session (ensure the lit note is linked from its subject's permanent notes) |
| Community Report Generator run | Check for drift: do existing community reports still align with current note embeddings? |
| Manual request | Ad-hoc session on a specific sub-graph |

---

## References
- [[agent-note-conventions]]
- [[wiki-pattern-operations]]
- [[hierarchical-graph-synthesis]]
- [[semantic-embedding-pipeline]]
- [[community-report-generator]]
- [[system-index]]
- [[knowledge-gardening-principles]]
