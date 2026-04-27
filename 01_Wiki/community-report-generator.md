---
title: Community Report Generator
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: spec
aliases:
  - community-summarizer
  - level-1-report-generator
  - graphrag-summarizer
---

# Community Report Generator

**Context:** The [[hierarchical-graph-synthesis]] spec defines *that* Level-1 Community Reports should exist and outlines the Summarizer role (Claude). This spec defines *how* an agent implements the Summarizer: the exact algorithm from k-means clustering of note embeddings through to a saved, linked Community Report note.

---

## 1. Inputs

The generator operates on three data sources available from the [[semantic-embedding-pipeline]]:

| Source | SQLite Table | Key Columns |
|---|---|---|
| Note embeddings | `NoteEmbeddings` | `note_id`, `embedding` (float array) |
| Wikilink graph | `Links` | `source_id`, `target_id`, `weight` |
| Note metadata | `Notes` | `note_id`, `title`, `type`, `status`, `file_path` |

Only notes with `status = active` and `type IN ('permanent', 'literature', 'community')` are eligible for clustering. Fleeting, spec, and handoff notes are excluded — they represent process artifacts, not settled knowledge.

---

## 2. Clustering Algorithm

### 2.1 Hybrid Edge Weight Construction

Pure embedding similarity misses structural intent (explicit wikilinks). Pure wikilink graphs miss semantic proximity. The generator combines both:

```
W(i, j) = α · CosineSim(embed_i, embed_j) + (1 - α) · LinkWeight(i, j)
```

Where:
*   `α = 0.6` — semantic signal is weighted higher than structural signal.
*   `CosineSim` is computed between normalized embedding vectors.
*   `LinkWeight(i, j) = 1.0` if a wikilink exists between i and j (bidirectional), `0.0` otherwise.

Edges below `W < 0.35` are pruned before clustering to keep the graph sparse.

### 2.2 K-Means on Embeddings (Level-1)

For Level-1 reports (major domain clusters), use k-means directly on the embedding vectors:

```python
from sklearn.cluster import KMeans
import numpy as np

# Load embeddings for eligible notes
embeddings = load_embeddings(db, eligible_note_ids)  # shape: (N, D)

# Determine k: one cluster per expected domain (~8 for this vault)
k = estimate_k(embeddings, method="elbow", k_range=range(4, 16))

kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
labels = kmeans.fit_predict(embeddings)
```

**Why k-means over Leiden?** K-means on dense embedding vectors is deterministic (given `random_state`), requires no graph construction, and produces balanced clusters aligned with semantic meaning. Leiden on the wikilink graph is sparser and better suited for Level-2 (sub-community) detection where explicit links are the signal.

### 2.3 Level-2 Sub-Clusters (Leiden)

Within each Level-1 cluster, apply the Leiden community detection algorithm to the hybrid-weighted subgraph to identify tighter sub-communities:

```python
import igraph as ig
import leidenalg

# Build igraph from hybrid edge weights for notes in this L1 cluster
g = build_subgraph(hybrid_weights, cluster_note_ids)
partition = leidenalg.find_partition(
    g, leidenalg.ModularityVertexPartition,
    weights='weight', seed=42
)
```

Level-2 clusters are the inputs to the most detailed community reports.

---

## 3. Report Generation

### 3.1 Agent Prompt Protocol

For each cluster (whether Level-1 or Level-2), the Summarizer agent receives:

```
SYSTEM:
You are the Synthesizer agent for the vulture-nest knowledge vault.
Generate a Community Report for the following cluster of notes.
Output format: Markdown with mandatory sections (Theme, Entities, Claims, Gaps, Tags).

USER:
Cluster ID: {cluster_id}
Level: {1 | 2}
Member Notes ({n} total):
{for each note: "- [[{note_id}]] ({type}): {title} — {one-line summary}"}

Parent Cluster (if Level-2): [[{parent_community_report}]]

Generate the Community Report now.
```

### 3.2 Required Report Sections

| Section | Purpose |
|---|---|
| **Theme** | 1-2 sentence distillation of the cluster's core knowledge domain |
| **Primary Entities** | Key concepts, protocols, tools, or agents discussed across member notes |
| **Key Claims** | 3-7 bullet assertions that represent the cluster's collective stance |
| **Internal Tensions** | Contradictions or unresolved debates between member notes |
| **Knowledge Gaps** | What the cluster *implies* but has not yet captured |
| **Member Notes** | Wikilinked list of all member notes |
| **Tags** | 3-5 kebab-case tags for cross-cluster retrieval |

### 3.3 Report Frontmatter

```yaml
---
title: 'Community Report: {theme_title}'
author: claude-sonnet-4-6
date: '{generation_date}'
status: active
type: community
cluster_id: '{cluster_id}'
level: {1 | 2}
parent_cluster: '{parent_cluster_id | null}'
member_count: {n}
aliases:
  - community-{cluster_id}
---
```

---

## 4. Registration and Linking

After generation, the report must be integrated into the vault graph:

1.  **Save** to `01_Wiki/community-reports/{cluster_id}.md`.
2.  **Add wikilinks** from the report to all member notes (via `[[note_id]]` in the Members section).
3.  **Back-link** each member note by appending `- [[community-reports/{cluster_id}]]` to its References section.
4.  **Index entry:** Add a line to `01_Wiki/index.md` under `## Emergent Communities`.
5.  **Embed link** from Level-2 report to its Level-1 parent report.

---

## 5. Regeneration Policy

Community reports are **invalidated** when:
*   A member note's content changes significantly (embedding drift > 0.15 from cluster centroid).
*   A new note is added whose embedding falls within 0.10 cosine distance of the cluster centroid.
*   The vault grows by more than 10% in note count since the last clustering run.

The [[hierarchical-graph-synthesis#3-addressing-the-learned-representation-gap|co-occurrence tracker]] adjusts edge weights after every retrieval session; re-clustering is triggered when total edge weight delta exceeds a threshold (configurable, default: 5%).

---

## 6. Multi-Agent Role Assignment

Per the [[hierarchical-graph-synthesis#4-multi-agent-role-assignment|role assignment]] in the synthesis spec:

| Agent | Role | Input | Output |
|---|---|---|---|
| **Gemini (Ingester)** | Embedding + link extraction | Raw source files | `NoteEmbeddings`, `Links` tables |
| **Claude (Summarizer)** | Cluster report generation | Cluster membership lists | Community Report markdown |
| **Codex (Auditor)** | Integrity verification | Report + member notes | Diff + YANP compliance check |

---

## References
- [[hierarchical-graph-synthesis]]
- [[semantic-embedding-pipeline]]
- [[graphrag-concepts]]
- [[karpathy-vision-gap-analysis]]
- [[capability-lattice-spec]]
- [[index]]
