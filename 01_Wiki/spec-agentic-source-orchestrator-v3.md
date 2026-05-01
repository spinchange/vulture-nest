---
title: 'Spec: Agentic Source Orchestrator v3'
author: claude-sonnet-4-6
date: '2026-05-01'
status: active
type: permanent
aliases:
  - agentic-source-orchestrator-v3
  - synthesis-intelligence-spec
  - content-reflex-protocol-v3
derived_from:
  - "[[spec-agentic-source-orchestrator]]"
  - "[[spec-agentic-source-orchestrator-v2]]"
---

# Spec: Agentic Source Orchestrator v3 (Synthesis Intelligence)

**Agentic Source Orchestrator v3** extends the orchestration layer with a **Synthesis Intelligence Model**. It defines the protocols for knowledge quality, evidence reliability, conflict resolution, and draft promotion.

## 1. The Vault-as-Compiler Thesis
Synthesis is viewed as a compilation process where raw source material is "compiled" into permanent knowledge.
- **Source Material (Sidecar)**: Raw object files (unprocessed text).
- **Synthesis Draft**: Linked but untested code (claims with evidence).
- **Permanent Note**: Shipped module (verified knowledge).

## 2. Epistemic Risk Model
Claims are classified into risk tiers to govern their promotion path:
- **T0 — Fabrication**: Unsupported claim. **Reject.**
- **T1 — Weak Evidence**: Tangential support. **Requires human review.**
- **T2 — Inference Unmarked**: Valid but unlabeled inference. **Annotate & promote.**
- **T3 — Stale Evidence**: Supporting chunks exceed freshness threshold. **Staleness stamp.**
- **T4 — Conflict**: Contradicts existing permanent notes. **Trigger resolution protocol.**
- **T5 — Verified**: High-similarity, fresh, authoritative support. **Auto-promote eligible.**

## 3. Conflict Resolution Protocol
Mandatory detection and resolution of contradictions between incoming claims and existing knowledge.
- **Update**: If new evidence is more authoritative and fresher.
- **Narrow**: If new evidence identifies a specific case or limit to a general claim.
- **Parallel**: If both claims are valid under different conditions.
- **Arbitrate**: Escalate to human if the agent cannot resolve.

## 4. Synthesis Quality Rubric
A draft is ready for promotion only if it meets these criteria:
1.  **Evidence Coverage**: Every non-trivial claim has a cited chunk ID.
2.  **Inference Labeling**: All derivations are explicitly marked.
3.  **Atomic Scope**: Covers exactly one concept (per YANP).
4.  **Wikilink Integrity**: All internal references resolve to existing stems.
5.  **Scope Statement**: Opens with a single sentence defining the concept boundary.

## 5. Implementation Sequence
1.  **Epistemic Tier Classifier**: Standalone function for `promote_synthesis_candidate`.
2.  **Conflict Detection**: Keyword-based cross-referencing of existing notes.
3.  **Decomposition Check**: Pre-drafting assessment of result set diversity.
4.  **Provenance Writer**: Automatic generation of `provenance` blocks in note frontmatter.

---
## See Also
- [[the-compounding-artifact]]
- [[spec-agentic-source-orchestrator-v2]]
- [[knowledge-gardening-principles]]
- [[pattern-human-in-the-loop]]
