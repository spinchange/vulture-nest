---
title: "Spec: Agentic Source Orchestrator v2"
author: codex
date: "2026-05-01"
status: active
type: permanent
aliases:
  - agentic-source-orchestrator-v2
  - source-orchestrator-hardening-spec
derived_from:
  - "[[spec-agentic-source-orchestrator]]"
---

# Spec: Agentic Source Orchestrator v2 (Hardening)

**Agentic Source Orchestrator v2** defines the hardened implementation layer for the vault's ingestion pipeline. It focuses on lifecycle control, human-in-the-loop (HITL) enforcement, and provenance guarantees.

## 1. Source Intake Lifecycle
The orchestrator manages sources through a strict 8-stage state machine. No stage may be skipped.
`proposed -> mapped -> approved -> crawled -> indexed -> verified -> synthesized -> promoted`

## 2. Multi-Agent Responsibilities
The system enforces the **Two-Role Invariant**: at least two distinct agent roles must touch any promoted artifact to reduce hallucination risk.
- **Gemini (Librarian)**: Detects gaps, proposes sources, prepares intake.
- **Codex (Engineer)**: Tool execution, schema validation, policy enforcement.
- **Claude (Chronicler)**: Distillation, draft building, YANP formatting.

## 3. MCP Tool Surface
The orchestration layer is exposed via 8 core tools:
1.  `propose_source_intake`: Register a URL and rationale.
2.  `orchestrate_ingestion`: Map the site and estimate costs.
3.  `approve_intake_plan`: Record human approval for execution.
4.  `execute_source_crawl`: Bounded fetch of raw documents.
5.  `index_crawled_source`: Chunking and embedding into sidecar.
6.  `verify_source_index`: Integrity check of indexed content.
7.  `semantic_search_sources`: Retrieve attributed evidence.
8.  `promote_synthesis_candidate`: Final gate for permanent note creation.

## 4. Policy Enforcement
Authority is centralized in `02_System/pipeline-policy.yaml`.
- **Fail-Closed**: If policy cannot be loaded, all ingestion tools must stop.
- **Thresholds**: Mandatory human approval for new domains or costs > 20 credits.

## 5. Handoff & Seams
Every orchestration step must produce a **Seam Artifact** containing the current state, open risks, and next recommended action. This ensures continuity across agent sessions.

---
## See Also
- [[spec-agentic-source-orchestrator]]
- [[spec-agentic-source-orchestrator-v3]]
- [[spec-firecrawl-pgvector-pipeline]]
- [[pattern-human-in-the-loop]]
