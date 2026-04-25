---
title: Agentic RAG
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [autonomous-retrieval, reasoning-rag]
---
# Agentic RAG

**Agentic RAG** (Retrieval-Augmented Generation) moves beyond simple "retrieve-then-generate" pipelines by giving the agent the autonomy to reformulate queries, validate results, and decide if more data is needed.

## Key Patterns
*   **Query Expansion**: The agent generates multiple versions of a user's query to catch different semantic nuances.
*   **Self-Correction**: If the initial retrieval is irrelevant, the agent identifies the failure and tries a different strategy or data source.
*   **Multi-Step Reasoning**: The agent uses a tool to find one piece of information, which it then uses to form the next search query.

## Tooling
Frameworks like **LlamaIndex** are specifically optimized for Agentic RAG, providing `QueryEngineTool` abstractions that let an agent treat a knowledge base as an interactive API.

---
## References
* Source: `00_Raw/hf-agents-course-unit2.md`, `00_Raw/hf-agents-unit3.md`
* [[llamaindex]]
* [[agentic-frameworks-moc]]
* [[hybrid-retrieval-spec]]
