---
title: "Spec: Agentic Source Orchestrator v2"
author: codex
date: "2026-04-29"
status: draft
type: spec
aliases:
  - agentic-source-orchestrator-v2
  - source-orchestrator-hardening-spec
  - content-reflex-protocol-v2
derived_from:
  - "[[spec-agentic-source-orchestrator]]"
---

# Spec: Agentic Source Orchestrator v2

**Purpose:** Define a hardened orchestration layer for the [[spec-firecrawl-pgvector-pipeline]] that turns web ingestion into a controlled, auditable, multi-agent workflow. This version strengthens the original spec by adding explicit lifecycle state, stricter human approval boundaries, provenance guarantees, failure handling, and measurable completion criteria.

---

## 1. Design Goals

The orchestrator exists to solve five concrete problems:

1.  **Controlled ingestion:** External content must enter the sidecar only through approved tools and policy gates.
2.  **Provenance preservation:** Every retrieved claim must retain a stable path back to source URL, crawl timestamp, and chunk identity.
3.  **Role clarity across agents:** Gemini, Codex, and Claude should collaborate through explicit handoff artifacts rather than implicit chat context.
4.  **Bounded autonomy:** Agents may propose, map, and validate, but expensive or high-risk actions require human approval.
5.  **Promotion discipline:** Sidecar material is evidence, not knowledge, until synthesized and approved into `01_Wiki/`.

---

## 2. Non-Goals

This orchestrator does not attempt to:

1.  Replace human editorial judgment for permanent notes.
2.  Crawl the open web opportunistically or continuously.
3.  Treat embeddings or similarity scores as truth.
4.  Let one agent perform discovery, ingestion, synthesis, and promotion without checkpoints.

---

## 3. Core Model

The system operates over four artifact classes:

| Artifact | Location | Purpose | Mutability |
|---|---|---|---|
| **Source Record** | sidecar DB | Canonical metadata for a crawled source. | Append/update by tools |
| **Chunk Record** | sidecar DB | Searchable content fragments with provenance. | Append-only except reindex |
| **Synthesis Draft** | `01_Wiki/` or staging area | Distilled claims grounded in chunks. | Agent-editable |
| **Permanent Note** | `01_Wiki/` | Human-approved knowledge artifact. | Human/agent editable after approval |

The orchestrator manages a **Source Intake Lifecycle**:

`proposed -> mapped -> approved -> crawled -> indexed -> verified -> synthesized -> promoted`

No stage may be skipped. Failed stages transition to `blocked` or `rejected` with a reason attached.

---

## 4. Multi-Agent Responsibilities

The original role split remains useful, but this version adds sharper boundaries.

| Agent | Primary Role | Allowed Actions | Not Allowed Without Handoff |
|---|---|---|---|
| **Gemini (Librarian)** | Gap detection and source proposal | Identify vault gaps, map source candidates, prepare intake request | Direct promotion into permanent notes |
| **Codex (Engineer)** | Tooling, schema, validation, policy enforcement | Run orchestration tools, validate schemas, verify ingest integrity, expose MCP surface | Editorial synthesis as final authority |
| **Claude (Chronicler)** | Distillation and note refinement | Build synthesis drafts, resolve overlap, structure claims for YANP | Trigger expensive crawl without prior approval state |

### 4.1 Role Invariant

At least two roles must touch any promoted knowledge artifact:

1.  One role acquires or validates source material.
2.  A different role synthesizes or approves the resulting note.

This reduces single-agent fabrication and enforces separation between retrieval and interpretation.

---

## 5. Trigger Conditions

The orchestrator is session-bound and must only activate from one of these triggers:

1.  **Explicit user directive**
    Example: "Ingest `https://docs.example.com` into the sidecar."
2.  **Gap discovery during active work**
    The agent detects that the vault lacks coverage for a concept material to the current task.
3.  **Verification failure**
    A draft note contains an unsupported or weakly supported claim.
4.  **Scheduled maintenance, if later implemented**
    Re-indexing or refresh runs must still honor policy and quota limits.

### 5.1 Mandatory Proposal Step

For triggers 2 through 4, the first agent must create a short proposal containing:

- target domain
- reason for ingestion
- expected knowledge gain
- estimated cost
- expected downstream consumer

No crawl begins until the proposal enters `approved`.

---

## 6. MCP Tool Surface

The orchestration layer is exposed as MCP tools. Each tool must be deterministic in contract even if the underlying crawl is not.

### 6.1 `propose_source_intake`

- **Goal:** Register a source request before any crawl activity.
- **Input:** `url`, `reason`, `requested_by_agent`, `expected_consumer`, `priority`
- **Output:** `intake_id`, normalized domain, initial policy verdict, rough cost band
- **Rules:** Must reject malformed URLs, denied domains, or duplicate active requests.

### 6.2 `orchestrate_ingestion`

- **Goal:** Map a site and produce an execution plan.
- **Input:** `intake_id`, `max_depth`, `path_hints`, `limit`
- **Action:** Calls Firecrawl `/map` or equivalent mapping stage.
- **Output:** URL candidates, estimated credits, domain summary, recommended include/exclude paths
- **Rules:** Must require human approval if estimated cost exceeds policy threshold or if path breadth suggests documentation sprawl.

### 6.3 `approve_intake_plan`

- **Goal:** Record human approval for a mapped plan.
- **Input:** `intake_id`, `approved_by`, `approved_limit`, `approved_paths`
- **Output:** approval stamp with timestamp
- **Rules:** Required before crawl execution when policy says HITL is mandatory.

### 6.4 `execute_source_crawl`

- **Goal:** Perform bounded crawl and persist raw documents.
- **Input:** `intake_id`, `include_paths`, `exclude_paths`, `limit`
- **Output:** crawl job id, fetched page count, raw failure count, consumed credits
- **Rules:** Must enforce `pipeline-policy.yaml`; must fail closed if approval is required and missing.

### 6.5 `index_crawled_source`

- **Goal:** Chunk, embed, and store source material in the sidecar.
- **Input:** `crawl_job_id`, `chunk_strategy`, `embedding_model`
- **Output:** source record id, chunk count, embedding status, duplicate count
- **Rules:** Must stamp every chunk with `source_url`, `retrieved_at`, `content_hash`, and `crawl_job_id`.

### 6.6 `verify_source_index`

- **Goal:** Validate that indexed content is queryable and policy-compliant.
- **Input:** `source_record_id`
- **Output:** verification report
- **Checks:**
  - chunk count > 0
  - embeddings present
  - provenance fields populated
  - no denied content types
  - sample retrieval returns coherent text

### 6.7 `semantic_search_sources`

- **Goal:** Retrieve sidecar evidence for synthesis.
- **Input:** `query`, `filter_domain`, `source_record_id`, `similarity_threshold`, `max_results`
- **Output:** attributed chunks with metadata
- **Rules:** Must return provenance fields by default; hiding provenance is not allowed.

### 6.8 `promote_synthesis_candidate`

- **Goal:** Convert a grounded synthesis draft into a promotion request.
- **Input:** `draft_path`, `supporting_chunk_ids`, `reviewer`, `target_note_path`
- **Output:** promotion packet with evidence manifest
- **Rules:** Must reject drafts that reference claims lacking supporting chunk ids.

---

## 7. Policy Contract

The policy file at `02_System/pipeline-policy.yaml` remains the machine authority for ingestion limits.

### 7.1 Minimum Policy Fields

```yaml
version: 2.0
quotas:
  max_credits_per_session: 100
  max_credits_per_month: 1000
  max_parallel_crawls: 2
  max_pages_per_source: 200
safety:
  denied_domains:
    - "*.social"
    - "reddit.com"
  denied_path_patterns:
    - "/changelog"
    - "/releases"
    - "/tags"
  allowed_file_types:
    - ".md"
    - ".html"
    - ".pdf"
  require_hitl_for_costs_over: 20
  require_hitl_for_new_domain: true
  require_hitl_for_reingestion_within_hours: 24
retrieval:
  min_similarity_threshold: 0.78
  max_chunks_per_query: 8
synthesis:
  max_claims_per_draft_without_review: 12
  require_citation_per_claim: true
  auto_promote_enabled: false
retention:
  keep_raw_documents_days: 30
  keep_failed_jobs_days: 14
```

### 7.2 Policy Enforcement Rules

1.  Tools must read policy at execution time, not compile time.
2.  If policy cannot be loaded, the tool must fail closed.
3.  Lower-level tools may be stricter than policy, never looser.

---

## 8. Provenance and Evidence Requirements

Every chunk stored in the sidecar must carry:

- `chunk_id`
- `source_record_id`
- `source_url`
- `domain`
- `retrieved_at`
- `content_hash`
- `crawl_job_id`
- `chunk_index`
- `embedding_model`

Every synthesis draft must carry:

- cited chunk ids per claim
- source URLs for non-trivial assertions
- retrieval timestamp or source freshness note when relevant

### 8.1 Claim Rule

A claim may be promoted into a permanent note only if it is:

1.  directly supported by one or more cited chunks, or
2.  clearly marked as an inference derived from cited chunks

Unmarked inference is treated as a synthesis defect.

---

## 9. State Machine and Failure Modes

### 9.1 Source Intake States

| State | Meaning | Exit Conditions |
|---|---|---|
| `proposed` | Source requested but not mapped | map or reject |
| `mapped` | URL graph and cost estimate prepared | approve, revise, or reject |
| `approved` | Human or policy approval complete | crawl |
| `crawled` | Raw documents fetched | index or block |
| `indexed` | Chunks stored with embeddings | verify |
| `verified` | Integrity checks passed | synthesize |
| `synthesized` | Draft created with evidence manifest | promote or revise |
| `promoted` | Permanent note approved | complete |
| `blocked` | Tooling, policy, or quality issue encountered | resolve or reject |
| `rejected` | Intake intentionally terminated | terminal |

### 9.2 Failure Classes

| Failure Class | Example | Required Response |
|---|---|---|
| **Policy failure** | Domain denied, quota exceeded | Stop immediately and log reason |
| **Acquisition failure** | Crawl timeout, 403s, empty map | Mark intake `blocked`; no partial promotion |
| **Index failure** | Embeddings missing, malformed chunk metadata | Re-run index or reject intake |
| **Retrieval failure** | Relevant chunks not found | Escalate to human or refine source scope |
| **Synthesis failure** | Claims lack evidence, overlap unresolved | Revise draft; do not promote |

Partial crawl success is not equivalent to verified ingestion.

---

## 10. Synthesis Loop

The sidecar exists to support note creation, not bypass it.

1.  **Select**
    An agent identifies a concept and queries the sidecar.
2.  **Retrieve**
    The agent gathers 5 to 8 relevant chunks, bounded by policy.
3.  **Distill**
    The agent creates a synthesis draft with claim-level citations.
4.  **Review**
    Another role or the human reviewer checks evidence coverage and overlap with existing notes.
5.  **Promote**
    The draft becomes a permanent note only after review and explicit promotion.

### 10.1 Draft Requirements

A synthesis draft should include:

- one-sentence scope
- claims section
- evidence section
- unresolved questions
- links to related notes

This keeps source-derived material clearly separated from editorial polish.

---

## 11. Handoff Protocol

All orchestration steps must produce a compact seam artifact for the next actor. A seam is not optional narration; it is structured operational state.

### 11.1 Required Seam Fields

- `intake_id`
- `current_state`
- `source_domain`
- `actions_completed`
- `open_risks`
- `next_recommended_action`
- `owner_role`

### 11.2 Example Seams

- **Gemini -> Codex:** "Intake `src_014` mapped for `docs.example.com`; estimated 14 credits; recommended paths `/guide` and `/api`; awaiting crawl execution."
- **Codex -> Claude:** "Intake `src_014` verified; 63 chunks indexed; provenance checks passed; use `source_record_id=sr_014` for synthesis."
- **Claude -> Human:** "Draft `01_Wiki/fleeting-synthesis-hnsw.md` prepared with 9 cited claims; 2 claims remain marked as inference pending review."

---

## 12. Observability and Audit

Every orchestration run should emit an append-only audit trail with:

- intake id
- acting agent
- tool invoked
- policy version
- credits consumed
- timestamps
- state transition
- outcome

### 12.1 Minimum Operational Metrics

- sources proposed per session
- approval rate
- crawl success rate
- average chunks per verified source
- promotion rate
- failed promotions due to missing evidence

Without these metrics, the system cannot be tuned responsibly.

---

## 13. Acceptance Criteria

This spec is satisfied when the system can demonstrate all of the following:

1.  A source request can move from `proposed` to `verified` with policy enforcement and audit logging.
2.  Human approval is required and enforced for high-cost or new-domain ingestion.
3.  `semantic_search_sources` always returns provenance-bearing evidence.
4.  A synthesis draft can be rejected automatically if claims lack supporting chunk ids.
5.  A permanent note can be traced back to the exact source records and chunks used to justify it.

---

## 14. Implementation Priorities

Recommended build order:

1.  Define intake and source record schemas.
2.  Implement policy loading and fail-closed enforcement.
3.  Implement proposal, map, approval, crawl, and verify tools.
4.  Add audit logging and seam artifact generation.
5.  Add synthesis promotion checks.

This sequence creates control before convenience.

---

## References

- [[spec-agentic-source-orchestrator]]
- [[spec-firecrawl-pgvector-pipeline]]
- [[pattern-human-in-the-loop]]
- [[pattern-progressive-handoff]]
- [[pattern-state-transfer]]
- [[agent-note-conventions]]
- [[visitor-directives]]
