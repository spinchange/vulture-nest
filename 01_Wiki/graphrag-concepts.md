---
title: GraphRAG Concepts
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [knowledge-graph-rag, hierarchical-rag, global-vs-local-search]
---
# GraphRAG Concepts

**GraphRAG** (Knowledge Graph-based Retrieval-Augmented Generation) is an advanced RAG pattern that uses LLMs to extract a structured **Knowledge Graph** from unstructured text. This allows for reasoning across an entire corpus rather than just retrieving isolated snippets.

## The Core Innovation: Beyond Similarity
Traditional RAG (Vector Search) is "near-sighted"; it finds similar text chunks but cannot "connect the dots" between pages that don't share semantic vectors. GraphRAG builds a **Map of Knowledge** where nodes are Entities and edges are Relationships.

## Key Techniques for Agentic Wikis

### 1. Hierarchical Community Detection
Using algorithms like **Leiden**, GraphRAG clusters related notes into "communities."
- **Application:** This is the machine equivalent of a [[pkm-methods-moc|Map of Content (MOC)]]. While humans build MOCs for navigation, an agent can use Community Summaries to understand the "Big Picture" of a vault without reading every file.

### 2. Global vs. Local Search
- **Local Search:** "Tell me about Entity X." (Explores immediate links).
- **Global Search:** "What are the major themes in this vault?" (Uses community summaries to synthesize a holistic answer).

### 3. Entity & Relationship Extraction
GraphRAG treats text as a source of **Claims**.
- **The Seam:** This is where the boundary between **Flat Text** and **Structured Relational** data dissolves. A YANP note is the source, but the extracted Graph is the "Active Memory."

## Leverage for Humans-in-the-Loop
GraphRAG makes the agent's internal "world model" transparent:
- **Inspectability:** Humans can see the graph and correct a "broken link" or a "hallucinated relationship."
- **Traceability:** Every claim in the graph points back to a source `TextUnit` (the original note).

## Comparison: Wikilinks vs. GraphRAG
| Feature | Wikilinks (Human) | GraphRAG (Agent) |
| :--- | :--- | :--- |
| **Creation** | Manual / Intentional | Automatic / Extracted |
| **Granularity** | Page-to-Page | Entity-to-Entity |
| **Discoverability** | Navigational | Computational |
| **Maintenance** | High Effort | Algorithmic |

---
## References
- [[memory-spectrum]]
- [[llm-wiki-pattern]]
- [[agent-knowledge-vault]]
- [[hybrid-retrieval-spec]]
