---
title: 'Spec: Agentic Source Orchestrator v3'
author: claude-sonnet-4-6
date: '2026-04-29'
status: draft
type: spec
aliases:
  - agentic-source-orchestrator-v3
  - synthesis-intelligence-spec
  - content-reflex-protocol-v3
derived_from:
  - "[[spec-agentic-source-orchestrator]]"
  - "[[spec-agentic-source-orchestrator-v2]]"
---

# Spec: Agentic Source Orchestrator v3

**Purpose:** Extend the orchestration layer defined in [[spec-agentic-source-orchestrator-v2]] with a synthesis intelligence model — the criteria and protocols governing knowledge quality, evidence reliability, conflict resolution, and draft promotion that determine whether a sidecar chunk deserves to become a permanent claim. v2 defined *how ingestion is controlled*. v3 defines *what makes synthesized knowledge trustworthy*.

---

## 1. Design Lineage

The three versions represent three distinct concerns:

| Version | Author | Core Concern | Contribution |
|---|---|---|---|
| v1 | Gemini | Coordination | Roles, triggers, basic MCP surface, seam protocol |
| v2 | Codex | Control | Lifecycle state, HITL enforcement, policy schema, failure taxonomy, audit trail |
| v3 | Claude | Quality | Epistemic tiers, evidence reliability, conflict resolution, synthesis rubric, staleness |

v3 inherits all constraints from v2 without modification. Every enforcement rule in v2 remains binding. This version adds layers above the ingestion pipeline: the rules that govern synthesis judgment, not just ingestion mechanics.

---

## 2. The Vault-as-Compiler Thesis

The sidecar is a build artifact, not a knowledge artifact. This distinction governs every synthesis decision.

- **Source material (sidecar):** Raw, unprocessed, attributed text. Equivalent to object files — cannot be executed as knowledge.
- **Synthesis draft:** Distilled, structured claims with explicit evidence bindings. Equivalent to linked but untested code.
- **Permanent note:** Human-reviewed, YANP-compliant, cross-linked knowledge. Equivalent to a shipped module.

Promotion gates are compilation steps. A claim that passes the gate has been type-checked against evidence. A claim that bypasses the gate is undefined behavior in the knowledge graph.

This thesis grounds three practical rules:

1. A synthesis draft that cannot be traced to source chunks is not a draft — it is a hallucination artifact.
2. A permanent note that cannot be re-derived from its cited chunks has an evidence gap.
3. Updating a permanent note requires re-running the evidence check against current sidecar state.

See [[the-compounding-artifact]] for the broader case for treated knowledge as compiled output.

---

## 3. Epistemic Risk Model

Not all unsupported claims carry equal risk. The orchestrator must classify synthesis failures by epistemic risk tier:

### 3.1 Risk Tiers

| Tier | Description | Example | Required Action |
|---|---|---|---|
| **T0 — Fabrication** | Claim has no supporting chunk and no inference marker | "Redis supports ACID transactions" with no source | Reject immediately; flag for human review |
| **T1 — Weak evidence** | Claim has cited chunks but chunks are tangential or low-similarity | Claim about HNSW performance citing an introductory overview | Require explicit human review before promotion |
| **T2 — Inference unmarked** | Claim is a valid inference from chunks but is not labeled as inference | Agent synthesizes a conclusion without marking it derived | Mark as inference; allow promotion with annotation |
| **T3 — Stale evidence** | Claim has cited chunks from sources older than policy freshness threshold | Claim about a library version from docs ingested 6 months ago | Add staleness annotation; flag for re-ingestion signal |
| **T4 — Conflict** | Claim contradicts an existing permanent note citing different evidence | Incoming chunk contradicts an existing synthesized claim | Trigger conflict resolution protocol (Section 5) |
| **T5 — Verified** | Claim is directly supported by high-similarity, domain-appropriate, fresh chunks | Claim about API behavior with exact documentation chunks | Eligible for promotion without additional escalation |

The promote gate must compute the tier of each claim before the promotion packet is assembled. A draft with any T0 or unresolved T4 claims must be rejected. T1 and T2 require annotation; T3 requires a staleness stamp.

### 3.2 Tier Computation Inputs

| Input | Where it comes from |
|---|---|
| Similarity score | `semantic_search_sources` result |
| Source freshness | `retrieved_at` vs. policy `freshness_threshold_days` |
| Inference marker | Synthesizing agent's annotation in the draft |
| Conflict check | Cross-reference against existing permanent notes at promotion time |
| Domain appropriateness | Whether the source domain is relevant to the claim topic |

---

## 4. Evidence Reliability

Similarity scores are not sufficient evidence quality signals. A chunk can score high similarity and still be a poor basis for a claim if it is from an inappropriate source, is decontextualized, or is internally ambiguous.

### 4.1 Evidence Quality Dimensions

Beyond similarity, each cited chunk should be evaluated on:

- **Domain fit:** Is the source domain authoritative for the claim topic? A blog post is lower authority than official documentation.
- **Chunk coherence:** Is the chunk self-contained or does it require surrounding context to be meaningful?
- **Recency:** How old is the retrieved content relative to the claim?
- **Redundancy:** Is the claim supported by multiple independent chunks, or a single point of failure?

### 4.2 Minimum Evidence Standard

A claim is promotion-eligible only if:

1. At least one cited chunk has similarity >= policy `min_similarity_threshold` (from v2 policy schema)
2. The source domain is not in the `denied_domains` list and is appropriate for the claim topic
3. The chunk was retrieved within policy `freshness_threshold_days` of the promotion date, or a staleness annotation is attached

For high-stakes claims (those that would become load-bearing assertions in MOC-level notes), at least two independent chunks from different sources should corroborate the claim.

---

## 5. Conflict Resolution Protocol

This is the most common synthesis failure mode and the one most likely to silently degrade knowledge quality. The system must detect and resolve conflicts, not ignore them.

### 5.1 Conflict Types

| Type | Definition |
|---|---|
| **Direct contradiction** | Incoming claim directly negates a claim in an existing permanent note |
| **Version conflict** | Incoming claim describes behavior of a library/protocol version that differs from the documented one |
| **Scope conflict** | Existing note makes a general claim; incoming chunk applies only to a specific case or condition |
| **Temporal conflict** | Existing claim was accurate at a prior date but the incoming chunk reflects a more recent state |

### 5.2 Detection

At `promote_synthesis_candidate` time, the promoting agent must:

1. Query the vault for existing permanent notes that share topic keywords with the synthesis draft.
2. For each related note, compare the draft's claims against that note's claims for logical contradiction.
3. Classify any detected conflicts by type.

This check is mandatory, not optional. A promotion packet submitted without a conflict check result is rejected by policy.

### 5.3 Resolution Paths

| Resolution | When to Use | Action |
|---|---|---|
| **Update existing note** | Incoming evidence is fresher, more authoritative, and supersedes the existing claim | Revise the existing permanent note with updated claim and new evidence manifest; preserve prior claim in a `prior_claim` section with its provenance |
| **Narrow existing note** | Incoming evidence shows the existing claim is valid but overly general | Add scope qualifier to existing note; add the incoming chunk as supporting evidence for the narrowed claim |
| **Create parallel note** | Both claims are valid under different conditions or versions | Keep existing note; create a new note for the conditioned claim; link both via wikilinks |
| **Flag for human arbitration** | Contradicting claims are both well-evidenced; the agent cannot determine which is correct | Set claim to T4 blocked; write a structured conflict report; do not promote |

A conflict report must include both sides' evidence, similarity scores, source domains, and retrieval timestamps. It is surfaced to the human as an `AUTH_REQUIRED` escalation using the [[pattern-human-in-the-loop]] protocol.

---

## 6. Synthesis Quality Rubric

v2 defines what a synthesis draft *must contain* structurally. v3 defines what makes a draft *ready to promote*.

### 6.1 Draft Gate Criteria

A synthesis draft passes promotion review if and only if:

| Criterion | Threshold |
|---|---|
| **Evidence coverage** | Every non-trivial claim has at least one cited chunk id |
| **Inference labeling** | All inferences are explicitly marked "Derived from:" |
| **Conflict resolution** | All T4 conflicts resolved or escalated to human |
| **Tier distribution** | No T0 claims present; T1 claims have reviewer annotation |
| **Atomic scope** | Draft covers exactly one concept per YANP atomicity requirement |
| **Wikilink integrity** | All internal references resolve to existing note stems |
| **Staleness stamps** | T3 claims carry `evidence_retrieved_at` and a re-ingestion signal |

### 6.2 Concept Decomposition

A source document frequently spans multiple concepts. The synthesis loop must decompose before drafting, not during.

When retrieving chunks for a concept query, if the result set contains chunks that clearly belong to two distinct concept domains, the agent must:

1. Split the retrieval into two queries, one per concept.
2. Create separate synthesis drafts — one per concept.
3. Link the drafts to each other via wikilinks.

Forcing multiple concepts into one note violates YANP atomicity and degrades future retrieval quality. The cost of decomposition at draft time is always lower than the cost of splitting a promoted note.

### 6.3 Synthesis Scope Statement

Every draft must open with a single sentence that declares exactly what concept the draft covers and what it does not cover. If the agent cannot write this sentence without qualifications, the draft scope is too broad.

---

## 7. Knowledge Freshness and Re-ingestion

v2's retention policy defines how long raw documents are kept. This section defines when *knowledge claims* become stale and what the re-ingestion signal looks like.

### 7.1 Staleness Conditions

A permanent note's claims may become stale when:

1. The underlying source's content changes (version bump, docs rewrite, deprecation).
2. The `retrieved_at` timestamps on cited chunks exceed `freshness_threshold_days`.
3. A new ingestion from the same domain produces chunks that contradict the existing claim.

### 7.2 Staleness Detection

The `verify_source_index` tool (v2 §6.6) should be extended to flag chunks whose `retrieved_at` exceeds the policy freshness threshold. When flagged:

- The chunk remains in the sidecar for retrieval.
- Queries that return stale chunks annotate the result with `stale: true`.
- Synthesis agents must not promote claims grounded solely in stale chunks without a T3 annotation.

### 7.3 Re-ingestion Trigger

A staleness signal should generate a lightweight re-ingestion proposal (using `propose_source_intake` from v2 §6.1) with:

- `reason: "staleness — chunks exceed freshness threshold"`
- `priority: low` unless the affected notes are MOC-level or load-bearing
- A diff of affected note stems, so the re-ingestion can be scoped to relevant paths

Re-ingestion does not automatically update permanent notes. It refreshes the sidecar; the synthesis loop must be re-run explicitly, and the resulting updated draft must go through the full promotion gate.

---

## 8. Retrieval Reliability

The sidecar is only as useful as the queries that retrieve from it. Poor query strategy is an invisible failure — the orchestrator runs without error but retrieves the wrong chunks, and the synthesis produces plausible-sounding hallucinations.

### 8.1 Query Failure Signals

An agent should treat the following as retrieval quality warnings:

- All top results share the same source domain (single-source concentration)
- Similarity scores cluster near the `min_similarity_threshold` (borderline relevance)
- Retrieved chunks share identical or near-identical text (deduplication missed)
- None of the top results directly address the concept being queried

When two or more of these signals are present, the agent must escalate rather than proceed to synthesis. The retrieval failure class from v2 §9.2 applies.

### 8.2 Query Strategy

To improve retrieval quality:

1. **Multi-angle querying:** Issue 2-3 queries at slightly different framings of the same concept. Merge unique results. Discard near-duplicates by content hash.
2. **Negative constraint:** When the concept has known adjacent topics, include filter terms to exclude off-topic chunks.
3. **Domain pinning:** When evidence is needed from a specific authoritative source, use `filter_domain` rather than relying on similarity to surface the right source.

### 8.3 Retrieval Audit in Promotion Packet

The promotion packet (assembled by `promote_synthesis_candidate`) must include the queries used to retrieve the cited chunks. This allows the reviewer to assess whether the retrieval strategy was appropriate, not just whether the retrieved chunks are cited.

---

## 9. Cross-Agent Synthesis Arbitration

v2 enforces the two-role rule: at least two roles must touch any promoted artifact. v3 addresses the case where two agents independently synthesize from overlapping evidence.

### 9.1 When Arbitration Triggers

Arbitration is needed when:

1. Two agents produce synthesis drafts for the same concept.
2. Two drafts produce contradicting claims from the same source material.
3. A draft targets the same note stem as a draft already in the synthesis queue.

### 9.2 Arbitration Protocol

1. The second agent to submit a draft for an already-queued concept detects the collision (by checking the staging area for existing draft stems before submission).
2. The second agent reads the existing draft's claims and evidence.
3. The second agent produces a reconciliation: a merged draft that adopts the stronger evidence for each claim and marks any remaining disputes.
4. The merged draft replaces both originals as the single promotion candidate.
5. Both originating agents' actions are recorded in the audit trail.

If the two drafts are irreconcilable (e.g., different synthesis models produce fundamentally different conceptual framings), the conflict is escalated to the human using the T4 protocol from §5.3.

---

## 10. Provenance Link Maintenance

Permanent notes must remain traceable to the sidecar chunks that justified them. This link degrades if source records are pruned, domains are re-ingested, or chunk IDs change during reindexing.

### 10.1 Provenance Manifest

When a permanent note is promoted, its frontmatter must include a `provenance` block:

```yaml
provenance:
  source_record_ids:
    - "sr_014"
  chunk_ids:
    - "chk_0142"
    - "chk_0143"
  retrieved_at: "2026-04-29T10:22:00Z"
  intake_ids:
    - "src_014"
```

This block is written at promotion time by `promote_synthesis_candidate` and must not be manually edited.

### 10.2 Link Integrity Check

The `verify_source_index` tool should accept a `note_path` parameter that reads the note's `provenance` block and verifies:

- All `source_record_ids` still exist in the sidecar.
- All `chunk_ids` are retrievable and match the `content_hash` recorded at ingestion.
- No cited chunks have been marked stale beyond the policy threshold.

A failed link integrity check does not invalidate the note — the knowledge claim may still be valid — but it triggers a T3 staleness annotation and adds the note to the re-ingestion queue.

---

## 11. Synthesis Loop (Extended)

This extends v2 §10 with the quality gates defined above.

```
1. QUERY
   Agent issues 2–3 query variants for the target concept.
   Check retrieval quality signals (§8.1).
   Flag and escalate if retrieval quality is low.

2. DECOMPOSE
   Assess whether the result set spans multiple concepts (§6.2).
   If yes: split into separate loops. Continue with one concept.

3. DISTILL
   Build synthesis draft with claim-level citations.
   Mark inferences explicitly.
   Write scope statement.

4. TIER-CLASSIFY
   Assess each claim against the epistemic risk model (§3.1).
   Reject T0 claims immediately.
   Annotate T1, T2, T3 claims.
   Flag T4 claims for conflict resolution.

5. CONFLICT RESOLVE
   Run conflict check against existing permanent notes (§5.2).
   Choose resolution path for each T4 conflict.
   Escalate irresolvable conflicts to human.

6. GATE CHECK
   Verify draft against promotion rubric (§6.1).
   Reject draft if any gate criterion fails.
   Return to DISTILL if fixable without new retrieval.

7. PROMOTE
   Assemble promotion packet with evidence manifest,
   retrieval queries, tier classification, and conflict report.
   Submit to promote_synthesis_candidate.
   Record provenance block in target note frontmatter.
```

---

## 12. Additional Policy Fields

Extending v2 §7.1:

```yaml
synthesis:
  # v2 fields retained
  max_claims_per_draft_without_review: 12
  require_citation_per_claim: true
  auto_promote_enabled: false
  # v3 additions
  freshness_threshold_days: 90
  min_corroborating_chunks_for_moc_level_claims: 2
  require_conflict_check_before_promotion: true
  require_query_audit_in_promotion_packet: true
  require_scope_statement_in_draft: true
  decomposition_required_if_concepts_exceed: 1
  require_provenance_block_in_permanent_note: true
```

---

## 13. Acceptance Criteria (Extended)

Inherits all v2 acceptance criteria. Additionally, the system is considered compliant when:

1. A synthesis draft containing a T0 claim is automatically rejected before promotion.
2. A promotion packet submitted without a conflict check is rejected by the tool.
3. A permanent note promoted from sidecar evidence contains a `provenance` block traceable to specific chunk IDs.
4. When two chunks from different domains produce contradicting claims, the conflict is surfaced to the human before either claim is promoted.
5. A re-ingestion proposal is generated automatically when a permanent note's cited chunks exceed the freshness threshold.
6. When a source document spans two distinct concepts, two separate notes are produced — not one compound note.

---

## 14. Implementation Sequence (Extended)

Extends v2 §14. Build the v2 sequence first, then:

6. Implement epistemic tier classifier as a standalone function callable from `promote_synthesis_candidate`.
7. Implement conflict detection: query vault notes by keyword, compare claims for contradiction.
8. Implement the decomposition check: assess result set diversity before drafting.
9. Implement freshness tracking: add `stale: true` annotation to `verify_source_index` output.
10. Implement provenance block writer in `promote_synthesis_candidate`.
11. Add link integrity check to `verify_source_index` when `note_path` is supplied.
12. Add retrieval audit to promotion packet structure.

This sequence ensures synthesis quality gates exist before knowledge is compounded into the permanent graph.

---

## References

- [[spec-agentic-source-orchestrator]] — v1 origin
- [[spec-agentic-source-orchestrator-v2]] — v2 engineering hardening
- [[spec-firecrawl-pgvector-pipeline]] — ingestion backend
- [[the-compounding-artifact]] — vault-as-compiler thesis
- [[pattern-human-in-the-loop]] — conflict escalation and AUTH_REQUIRED protocol
- [[pattern-progressive-handoff]] — cross-agent handoff structure
- [[pattern-state-transfer]] — state preservation across synthesis phases
- [[pattern-capability-gating]] — pre-promotion authorization checks
- [[agent-note-conventions]] — YANP atomicity requirement
- [[visitor-directives]]
