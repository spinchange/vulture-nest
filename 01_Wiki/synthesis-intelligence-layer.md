---
title: 'Synthesis Intelligence Layer'
author: claude-sonnet-4-6
date: '2026-04-30'
status: active
type: permanent
aliases:
  - intelligence-layer
  - epistemic-gates
  - synthesis-mind
---

# Synthesis Intelligence Layer

The Synthesis Intelligence Layer is the "Mind" of the [[spec-agentic-source-orchestrator]]. It governs what ingested material is allowed to become permanent knowledge by enforcing epistemic gates at every stage of the synthesis pipeline.

The complementary "Body" (infrastructure, state machine, SQL schemas) is built by Codex; see [[codex-orchestrator-build-handoff-2026-04-29]].

---

## Scope Statement

This note covers the four intelligence components that the Chronicler (Claude) owns within the orchestrator: the epistemic risk classifier, conflict resolution templates, provenance block generator, and synthesis quality rubric. It does not cover the ingestion infrastructure, policy enforcement, or MCP server wiring.

---

## Components

### 1. Epistemic Risk Classifier (`epistemic_classifier.py`)

Classifies every claim in a synthesis draft against the T0–T5 risk tiers defined in [[spec-agentic-source-orchestrator]] §3. The classifier evaluates each claim's supporting evidence chunks and returns the most restrictive applicable tier.

| Tier | Gate Logic |
|---|---|
| T0 — Fabrication | Zero evidence chunks supplied |
| T1 — Weak Evidence | No chunk meets the `min_similarity_threshold` |
| T2 — Unmarked Inference | Inference language present but no `[Derived]` annotation |
| T3 — Stale Evidence | All strong chunks older than `freshness_threshold_days` |
| T4 — Conflict | Negation mismatch detected against existing wiki claims |
| T5 — Verified | At least one fresh, high-similarity chunk supports the claim |

**MCP tool:** `classify_synthesis_draft` — accepts a `claims` list (each with `text` and `chunks`), returns per-claim tiers plus an `overall_tier` for the draft.

### 2. Conflict Resolution Templates (`conflict_templates.py`)

Arbitration prompt templates for the three conflict types identified in §5 of the master spec:

| Conflict Type | Description |
|---|---|
| `direct_contradiction` | A says X, incoming source says ¬X |
| `version_skew` | Both true but for different versions or time periods |
| `scope_overlap` | Incoming claim overlaps but does not contradict existing note |

Each template produces a structured **Conflict Report** (JSON) with four resolution options: Update, Narrow, Parallelize, Escalate. Choosing `Escalate` forces `auth_required: true`, triggering an `AUTH_REQUIRED` [[pattern-human-in-the-loop]] gate.

**MCP tool:** `get_conflict_resolution_template` — accepts `conflict_type` and context variables, returns the filled arbitration prompt.

### 3. Provenance Block Generator (`provenance.py`)

Generates the YANP `provenance` frontmatter block required on every permanent note promoted through the orchestrator (§7). Links the Wiki note back to the specific Supabase chunk IDs and source record IDs that supported it.

```yaml
provenance:
  source_record_ids: ["sr_abc"]
  chunk_ids: ["chk_1", "chk_2"]
  retrieved_at: "2026-04-30T12:00:00Z"
  acting_agent: "claude-chronicler"
```

**MCP tool:** `build_provenance_block` — accepts chunk and source record IDs; optional `render_yaml: true` flag returns the YAML text ready for frontmatter insertion.

### 4. Synthesis Quality Rubric (`synthesis_rubric.py`)

Checks a synthesis draft for YANP atomicity compliance before the promotion step:

- Word count within bounds (50–800 words)
- Section count ≤ 5
- Scope Statement section present
- No concept-boundary crossing phrases detected

Returns `passed: bool`, `atomicity_score` (0.0–1.0), and per-issue suggestions.

**MCP tool:** `run_synthesis_rubric` — accepts `draft_text`, returns the full rubric result.

---

## Integration Point

All four tools are registered in `02_System/vulture-ingest/server.py` alongside the existing ingestion tools (`propose_source_intake`, `orchestrate_ingestion`, `execute_source_crawl`). The synthesis tools consume policy thresholds from `02_System/pipeline-policy.yaml` at runtime — changing `min_similarity_threshold` or `freshness_threshold_days` in the policy file propagates automatically to the classifier.

---

## Next Seam

Once Codex completes the infrastructure seam (schema migrations, `index_crawled_source`, `verify_source_index`, `promote_synthesis_candidate`), the first **End-to-End** ingestion test can run: ingest a source → classify claims → check rubric → generate provenance → promote to `01_Wiki/`.

---

## References

- [[spec-agentic-source-orchestrator]] — Master spec: T0–T5 tiers, §3, §5, §7
- [[pattern-human-in-the-loop]] — AUTH_REQUIRED escalation pattern
- [[agent-note-conventions]] — YANP frontmatter standards
- [[codex-orchestrator-build-handoff-2026-04-29]] — Complementary infrastructure build
