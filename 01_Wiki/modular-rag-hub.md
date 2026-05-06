---
title: Modular RAG Hub
author: claude-sonnet-4-6
date: 2026-05-06
status: active
type: permanent
aliases: [modular-rag, adaptive-rag, self-rag, agentic-retrieval-hub]
---
# Modular RAG Hub

**Modular RAG** is the architectural evolution beyond naive Retrieve-Then-Generate pipelines. Where naive RAG applies a single fixed retrieval step, Modular RAG decomposes retrieval into independently configurable, swappable components: routers, retrievers, rerankers, and critics. Each component has a defined interface; the orchestrator composes them at runtime based on query characteristics.

This hub routes to the key Modular RAG sub-patterns.

---

## The Modular Stack

```
Query
  │
  ▼
[Router] ─── decides which retrievers to invoke and in what order
  │
  ▼
[Retrievers] ─── dense, sparse, graph, structured (parallel or sequential)
  │
  ▼
[Reranker] ─── cross-encoder or LLM-as-judge relevance scoring
  │
  ▼
[Critic / Self-RAG] ─── decides if retrieved context is sufficient
  │       └── if NOT: reformulate query, invoke retrievers again
  ▼
[Generator] ─── final LLM synthesis over validated context
```

---

## Adaptive Routing

**Adaptive Routing** is the query classification step that selects the retrieval strategy before any retrieval occurs. The router prevents every query from hitting every retriever — a naive pattern that is expensive, slow, and produces noisy merged results.

### Router Types

| Router | Decision Basis | Use Case |
|---|---|---|
| **Rule-based** | Keyword or regex triggers | Simple domain dispatch |
| **Classifier** | Fine-tuned embedding or LLM classifier | Structured taxonomy of query types |
| **LLM-as-Router** | Zero-shot LLM judgment with schema output | Flexible, extensible — highest latency |
| **Confidence-based** | Route based on retriever confidence scores from the previous step | Fallback cascades |

### Routing Targets

A router typically dispatches to:
- **Dense retrieval** (vector similarity) for semantic / natural-language questions
- **Sparse retrieval** (BM25/keyword) for exact terminology, proper nouns, code identifiers
- **Graph traversal** ([[graphrag-concepts|GraphRAG]]) for relational or multi-hop questions
- **Structured query** (SQL/SPARQL) for tabular or ontology-anchored data
- **No retrieval** (direct LLM generation) for simple factual or reasoning-only questions

---

## Self-RAG

**Self-RAG** (Self-Reflective RAG) adds a critique loop after retrieval: the model itself decides whether the retrieved documents are relevant enough to answer the query, and whether its generated answer is actually supported by the retrieved context. If either check fails, the loop iterates.

### Self-RAG Decision Points

Self-RAG inserts classifier tokens (or structured LLM judgment calls) at three points:

| Decision Point | Token / Output | Meaning |
|---|---|---|
| Pre-generation | `[Retrieve]` / `[No Retrieve]` | Is retrieval needed for this query? |
| Post-retrieval | `[Relevant]` / `[Irrelevant]` per passage | Which retrieved chunks are actually useful? |
| Post-generation | `[Supported]` / `[Partially]` / `[Contradiction]` | Is the answer grounded in the context? |

On `[Irrelevant]` or `[Contradiction]`, the loop reformulates the query (query rewriting or query expansion) and retrieves again, up to a configured max-retry limit.

### Self-RAG vs. Agentic RAG

| Dimension | [[agentic-rag|Agentic RAG]] | Self-RAG |
|---|---|---|
| Decision maker | External agent with tool calls | Internal model with classifier tokens |
| Loop control | Agent orchestrator | Token-conditioned generation |
| Latency | Higher (separate agent hops) | Lower (single model pass) |
| Flexibility | High — can call arbitrary tools | Limited to retrieval reformulation |

Self-RAG is better for cost/latency-sensitive pipelines; Agentic RAG is better when the failure modes require calling diverse tool types.

---

## Hyperbolic Embeddings

Standard vector embeddings (Euclidean space) are inefficient for **hierarchical data** — the volume of Euclidean space doesn't grow fast enough to preserve tree distances without distortion. **Hyperbolic embeddings** map data into a Poincaré disk (negatively curved space) where the available volume grows exponentially with radius, mirroring the exponential branching of hierarchies.

**When to use:**
- Document collections with strong categorical / ontology structure (medical codes, legal taxonomies, product catalogs)
- Knowledge graphs where entity relationships are predominantly `is-a` or `part-of`
- Multi-level topic hierarchies where leaf nodes should be far from root but close to siblings

**Practical state (May 2026):** Libraries like `geoopt` (PyTorch) and `geomstats` support Poincaré disk models. Performance advantages over Euclidean are strongest at low embedding dimensions (32–64d). At 256d+, Euclidean models close the gap. Start with standard dense embeddings; reach for hyperbolic when hierarchical distortion is measurably hurting retrieval quality.

---

## GraphRAG + Agentic Planner Hybrid

[[graphrag-concepts|GraphRAG]] builds an entity-relationship graph over the corpus and answers queries by traversing the graph rather than (only) retrieving chunks. Combining it with an agentic planner produces a **Graph-Agent Hybrid**:

```
Planner Agent
  │
  ├── Sub-task: entity lookup → Graph traversal → entity subgraph
  ├── Sub-task: relationship reasoning → Graph path query → relationship chain
  └── Sub-task: supporting evidence → Dense retrieval over chunk store
  │
  Synthesizer Agent
  └── Merges graph subgraph + chunk evidence → final answer
```

**Key advantage over pure GraphRAG:** The planner can mix graph and dense retrieval strategies within a single answer — using the graph for relational reasoning and chunk retrieval for supporting quotations. Pure GraphRAG forces all reasoning through the graph, which is slow for simple semantic queries.

**Key advantage over pure Agentic RAG:** The graph's pre-computed structure lets the planner issue precise relational queries (e.g., "all papers that cite X and also cite Y") that would require multiple uncertain LLM steps in a purely chunk-based retrieval system.

---

## Where to Start

- **Dense + Sparse only, small corpus** → [[agentic-rag]] patterns; [[llamaindex]] `QueryEngineTool`
- **Large, heterogeneous corpus** → Add Adaptive Routing to route by query type
- **Factual accuracy is critical** → Add Self-RAG critique loop
- **Hierarchical knowledge (taxonomies, ontologies)** → Evaluate Hyperbolic Embeddings
- **Relational multi-hop questions** → [[graphrag-concepts|GraphRAG]] + planner hybrid

---

## References

- [[agentic-rag]]
- [[graphrag-concepts]]
- [[hybrid-retrieval-spec]]
- [[llamaindex]]
- [[llm-as-a-judge]]
- [[multi-agent-patterns-moc]]
- [[agentic-frameworks-moc]]
