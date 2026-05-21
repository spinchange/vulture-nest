---
title: 'Spec: Agentic Source Orchestrator'
author: gemini-cli
date: '2026-04-29'
status: active
type: spec
aliases:
  - agentic-source-orchestrator
  - source-orchestrator-master
  - knowledge-compiler-protocol
  - content-reflex-protocol
---

# Spec: Agentic Source Orchestrator

**Purpose:** Define the unified multi-agent orchestration layer for the [[spec-firecrawl-pgvector-pipeline]]. This spec establishes the "Knowledge Compiler" protocol, transforming raw web ingestion into a hardened, auditable, and epistemically verified knowledge graph within the YANP framework.

---

## 1. The Multi-Agent Trinity (Roles)

Execution is distributed across the fleet to enforce the **Two-Role Invariant**: *No single agent may both ingest source material and promote it to a permanent note.*

| Agent | Responsibility | Primary Metrics |
|---|---|---|
| **Gemini (Librarian)** | **Gap Detection & Discovery:** Identifies vault gaps, maps source candidates, manages the Index and Log. | Gap-to-Crawl Ratio, Index Accuracy. |
| **Codex (Engineer)** | **Control & Infrastructure:** Manages the state machine, SQL schemas, MCP Tool implementation, and policy enforcement. | System Uptime, Policy Compliance, Audit Integrity. |
| **Claude (Chronicler)** | **Synthesis & Intelligence:** Distills claims from chunks, resolves conflicts, and ensures epistemic quality. | Evidence Coverage, Claim-to-Evidence Ratio. |

---

## 2. The Source Intake Lifecycle (State Machine)

The orchestrator manages a strict 8-stage lifecycle. No stage may be bypassed.

1.  **Proposed:** Agent registers a source request based on a vault gap or user directive.
2.  **Mapped:** Firecrawl `/map` identifies the URL graph and cost estimate.
3.  **Approved:** Human or policy gate grants permission to crawl.
4.  **Crawled:** Raw Markdown is fetched and stored in the sidecar.
5.  **Indexed:** Content is chunked, embedded, and stamped with provenance.
6.  **Verified:** Integrity checks (coherence, metadata, sample retrieval) pass.
7.  **Synthesized:** A draft note is created with claim-level evidence citations.
8.  **Promoted:** The draft is reviewed and merged as a Permanent Note in `01_Wiki/`.

---

## 3. Epistemic Risk & Quality Gates

The system treats knowledge as **Compiled Output**. Claims must pass the following risk classification before promotion:

| Tier | Classification | Action Required |
|---|---|---|
| **T0 — Fabrication** | No supporting evidence or inference marker. | **Reject immediately.** |
| **T1 — Weak Evidence** | Tangential or low-similarity chunks. | Flag for human arbitration. |
| **T2 — Unmarked Inference** | Valid conclusion but missing "Derived" label. | Annotate and proceed. |
| **T3 — Stale Evidence** | Evidence retrieved > 90 days ago. | Stamp as stale; queue re-ingestion. |
| **T4 — Conflict** | Contradicts existing permanent notes. | Trigger Conflict Resolution (§5). |
| **T5 — Verified** | Direct support from high-similarity, fresh chunks. | Eligible for promotion. |

---

## 4. The MCP Tool Surface (The Reflex)

The orchestrator is exposed via a unified MCP server, ensuring all agents share the same operational interface.

*   `propose_source_intake`: Register a request; validates against `denied_domains`.
*   `orchestrate_ingestion`: Generates the map and cost estimate.
*   `execute_source_crawl`: Performs the crawl; enforces the credit quota.
*   `index_crawled_source`: Chunks and embeds using the Heading-Aware strategy.
*   `verify_source_index`: Runs integrity and provenance audits.
*   `semantic_search_sources`: Retrieves attributed chunks with metadata.
*   `promote_synthesis_candidate`: Compiles the "Promotion Packet" for review.

---

## 5. Conflict Resolution & Arbitration

When an incoming claim contradicts the existing graph, the agent must choose a resolution path:

1.  **Update:** New evidence is fresher/more authoritative. Supersede old claim.
2.  **Narrow:** Existing claim is too general. Add scope qualifiers.
3.  **Parallelize:** Both are true under different conditions (e.g., versions). Create conditioned notes.
4.  **Escalate:** High-stakes contradiction. Trigger `AUTH_REQUIRED` for human review.

---

## 6. Policy Framework (`pipeline-policy.yaml`)

```yaml
version: 1.0
quotas:
  max_credits_per_session: 100
  max_pages_per_source: 200
safety:
  denied_domains: ["*.social", "reddit.com"]
  require_hitl_for_costs_over: 20
  require_hitl_for_new_domain: true
synthesis:
  freshness_threshold_days: 90
  min_similarity_threshold: 0.78
  require_provenance_block: true
```

---

## 7. Provenance & Audit Trail

Every permanent note promoted via this orchestrator MUST contain YAML provenance fields in its frontmatter:

```yaml
provenance_source_ids: ["sr_123"]
provenance_chunk_ids: ["chk_456", "chk_457"]
provenance_retrieved: "2026-04-29T12:00:00Z"
provenance_agent: "claude-chronicler"
```

This creates a stable link between the **Wiki (Permanent Knowledge)** and the **Sidecar (Evidence Chunks)**.

At the storage layer, the sidecar also maintains agentic lifecycle provenance:
- `source_pages` records the latest proposer, approval mode, indexing agent, verification agent, promotion agent, and a JSON `provenance_context`.
- `source_events` is the append-only audit stream for lifecycle transitions such as `mapped`, `indexed`, `verification_passed`, and `promotion_written`.

The design intent is split-brain safe:
- `source_pages` gives the current state snapshot for retrieval and dashboards.
- `source_events` preserves the ordered history needed for seam review, operator audit, and role-separation checks.

For live databases, additive changes to this sidecar schema should ship as versioned SQL files under `02_System/vulture-ingest/migrations/` rather than relying on a full replay of `schema.sql`. `schema.sql` remains the fresh-install baseline; migration files are the contract for in-place upgrades. Applied migrations are recorded in `schema_migrations` so operators can audit which upgrades have been run against a given ingest database.

---
## References
- [[protocol-source-ingestion-runbook]] — Operational procedures and multi-agent role sequence
- [[spec-firecrawl-pgvector-pipeline]]
- [[firecrawl-crawling-capabilities]]
- [[firecrawl-map-capabilities]]
- [[firecrawl-scrape-capabilities]]
- [[firecrawl-api-v2-reference]]
- [[the-compounding-artifact]]
- [[visitor-directives]]
- [[agent-note-conventions]]
