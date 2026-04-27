---
title: "Hierarchical Graph Synthesis"
author: gemini-cli
date: 2026-04-26
status: draft
type: permanent
aliases:
  - graph-synthesis
  - community-detection-rag
  - hierarchical-moc
---

# Hierarchical Graph Synthesis

**Context:** The vault has achieved **Neural Retrieval** via the [[semantic-embedding-pipeline]], but still lacks **Global Context**. An agent can find *relevant* notes but cannot yet describe the *entire* vault's knowledge structure. This spec defines the move from local similarity to hierarchical synthesis—closing the [[karpathy-vision-gap-analysis|Karpathy Gap]].

## 1. The "Community" Primitive

A **Community** is a group of notes identified as semantically or structurally related via [[graphrag-concepts#1-hierarchical-community-detection|Community Detection]].

*   **Node:** A single Permanent or Literature note.
*   **Edge:** Either a symbolic Wikilink or a neural Semantic Link (cosine similarity > 0.82).
*   **Community Note:** A machine-generated note (analogous to a [[pkm-methods-moc|Map of Content]]) that summarizes the claims and entities within a specific cluster.

## 2. Synthesis Workflow (The Compiler)

To build the hierarchy, the vault must "compile" its notes:

1.  **Clustering:** Use an algorithm (e.g., Leiden) on the SQLite `Links` and `NoteEmbeddings` tables to identify communities at different granularities (Level 0: The whole vault, Level 1: Major domains, Level 2: Specific clusters).
2.  **Extraction:** For each community, an agent reads the titles and summaries of all member notes.
3.  **Summarization:** The agent generates a **Community Report** that:
    *   Defines the core theme of the cluster.
    *   Lists the primary entities and their relationships.
    *   Identifies internal contradictions or knowledge gaps.
4.  **Registration:** These reports are saved to `01_Wiki/community-reports/` and linked into the global `index.md`.

## 3. Addressing the "Learned Representation" Gap

To satisfy the **Software 2.0** requirement, the graph must evolve based on usage:

*   **Co-occurrence Tracking:** When an agent (or human) retrieves multiple notes in a single turn, we record a `CoOccurrenceEvent` in a new SQLite table.
*   **Weight Adjustment:** Edges between notes that are frequently used together are "strengthened" (weight increased).
*   **Dynamic Clustering:** The community detection algorithm is re-run periodically using these usage-weighted edges, allowing the vault's structure to reorganize based on how it is actually *used*, not just how it was *written*.

## 4. Multi-Agent Role Assignment

*   **The Ingester (Gemini):** Extracts entities and initial links from raw sources.
*   **The Summarizer (Claude):** Generates high-level community reports (stronger synthesis/reasoning).
*   **The Auditor (Codex):** Verifies that the synthesized graph accurately reflects the source files and maintains YANP/Lattice integrity.

## 5. Strategic Goal: Global Search
Once synthesized, an agent can answer: *"What is our overall philosophy on multi-agent trust?"* by reading the Level 1 and 2 community reports, rather than attempting to ingest 200+ individual files.

---
## References
- [[graphrag-concepts]]
- [[karpathy-vision-gap-analysis]]
- [[semantic-embedding-pipeline]]
- [[capability-lattice-spec]]
