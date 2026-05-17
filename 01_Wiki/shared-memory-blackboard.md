---
title: Shared Memory Blackboard Pattern
author: claude-sonnet-4-6
date: 2026-05-07
status: active
type: permanent
aliases:
  - blackboard-pattern
  - rag-backed-shared-context
  - shared-blackboard
  - agent-blackboard
---
# Shared Memory Blackboard Pattern

The **Blackboard Pattern** is a multi-agent coordination architecture in which agents communicate indirectly through a shared, queryable data structure rather than calling each other directly. In its modern LLM-era form, the blackboard is a **RAG-backed store**: a vector index (with optional structured metadata) that agents write to and retrieve from semantically.

The pattern originates in classic AI (HEARSAY-II speech recognition, 1970s), where specialized "Knowledge Sources" each solved a fragment of a problem by reading and writing a shared global data structure. The controller watched the blackboard and decided which Knowledge Source to fire next. The shape maps cleanly onto contemporary multi-agent systems.

---

## Structure

```
┌─────────────────── BLACKBOARD (Shared RAG Store) ───────────────────┐
│  chunks + embeddings + metadata {author, timestamp, session, topic}  │
└───────────────────────────────────────────────────────────────────────┘
        ▲ write                              │ retrieve (semantic query)
        │                                    ▼
  Agent A (Specialist)               Agent B (Specialist)
  Agent C (Orchestrator) ────────────────────────────────► next action
```

Three roles:

| Role | Classical Term | Modern Form |
|---|---|---|
| Shared store | Blackboard | Vector store + optional relational sidecar |
| Specialist agents | Knowledge Sources | LLM agents with narrow capability scope |
| Coordinator | Controller | Orchestrator agent or routing layer |

---

## Coordination Flow

**Write side** (any agent after completing a work unit):
1. Produce output (analysis, draft, decision, retrieved fact)
2. Chunk output if long
3. Embed chunks and upsert to vector store with metadata: `author_agent`, `session_id`, `timestamp`, `topic_tags`
4. Optionally write a structured summary row to the relational sidecar for keyword/filter queries

**Read side** (any agent before acting):
1. Formulate a semantic query capturing what prior work is relevant
2. Retrieve top-*k* chunks from the store, filtered by topic or recency if needed
3. Inject retrieved context into the working prompt
4. Act on the synthesized context

The orchestrator doesn't need to know what each specialist produced — it queries the blackboard to decide what has been deposited and what remains to do.

---

## When to Use

The blackboard pattern is the right choice when:

- **Agents are asynchronous** — they run at different times and can't hand off state directly
- **The fleet is heterogeneous** — specialists don't share an interface or calling convention
- **Knowledge accumulates** — later agents need to build on what earlier agents discovered
- **The coordination question is "what do others know?"** rather than "who should I call next?"

Prefer direct tool calls ([[pattern-agent-as-tool]]) or A2A delegation ([[a2a-protocol]]) when agents need to coordinate synchronously or the scope of shared state is small and bounded.

---

## Contrast With Adjacent Patterns

| Pattern | Communication | Coupling | State queryability |
|---|---|---|---|
| **Blackboard** | Indirect (via store) | Loose — agents don't know each other | Semantic (vector retrieval) |
| [[pattern-state-transfer]] | Direct (passed struct) | Tight — sender knows receiver | Key/value access |
| [[a2a-protocol]] | Peer-to-peer messages | Moderate — agents exchange tasks | Task status only |
| [[workflow-agents]] | LangGraph state dict | Tight — graph topology is fixed | Struct field access |
| [[maker-checker-pattern]] | Sequential (maker → checker) | Tight — paired agents | None — checker reads maker output directly |

The blackboard's defining property is **temporal decoupling**: agent A can write at 09:00 and agent B can retrieve that contribution at 14:00 without any synchronization between them.

---

## Implementation Notes

### Metadata Schema

Every write should carry at minimum:

```json
{
  "source_agent": "gemini-cli",
  "session_id": "2026-05-07-T1",
  "topic": "rag-patterns",
  "timestamp": "2026-05-07T14:22:00Z",
  "content_type": "synthesis | draft | retrieval | decision"
}
```

Metadata enables **filtered retrieval** — agents can narrow to recent contributions, to a specific topic lane, or to a specific prior agent's outputs.

### Vector Store Options

| Store | Fit |
|---|---|
| Supabase pgvector | Managed, SQL filtering, good for hybrid retrieval |
| Chroma ([[chromadb]]) | Local, zero-config, good for prototyping |
| Pinecone | Production scale, metadata filtering at write time |
| PostgreSQL + pgvector | Full relational + vector in one store |

The vault's own Supabase-backed ingest pipeline (`vulture-ingest`) is a concrete implementation: Gemini crawls and writes, Claude retrieves via `semantic_search_sources`, Codex manages the pipeline. See [[agent-knowledge-vault]].

---

## Failure Modes

| Failure | Cause | Mitigation |
|---|---|---|
| **Stale context** | Embedding index lags behind writes | Synchronous upsert; versioned embeddings |
| **Write conflict** | Two agents write contradicting facts | Metadata timestamps + last-write-wins or merge strategy |
| **Semantic drift** | Old entries mislead on evolved topics | TTL or `status: archived` tagging in metadata |
| **Context flooding** | Retrieval returns diluted mix of everything | Tight topic metadata + filtered queries |
| **Missing attribution** | Agent acts on retrieved content without knowing its provenance | Require `source_agent` in every chunk |

---

## Relationship to the Memory Spectrum

The blackboard occupies the **Semantic Kernel** layer of [[memory-spectrum]]:

- **Flat text (wiki)** = human-readable source of truth, not queryable at scale
- **Relational sidecar** = structured decisions, tasks, session log — keyword-queryable
- **Blackboard (vector store)** = semantically queryable shared context — the layer that makes cross-agent coordination tractable at scale

The three layers are complementary. Production systems typically combine all three: the blackboard handles agent-to-agent coordination, the relational store handles structured state, and the wiki handles human-readable record.

[[modular-rag-hub]] covers how the retrieval step itself (Adaptive Routing, Self-RAG, GraphRAG) can be made more precise once the blackboard grows large enough to need query routing.

---

## See Also

- [[memory-spectrum]]
- [[agentic-rag]]
- [[modular-rag-hub]]
- [[agent-knowledge-vault]]
- [[adk-long-term-memory]]
- [[multi-agent-patterns-moc]]
- [[pattern-state-transfer]]
- [[a2a-protocol]]
- [[maker-checker-pattern]]
- [[graphrag-concepts]]
