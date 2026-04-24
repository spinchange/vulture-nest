---
title: Agentic RAG
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [autonomous-retrieval, reasoning-retrieval, data-agency]
---
# Agentic RAG

**Agentic Retrieval-Augmented Generation (RAG)** extends traditional RAG by providing an autonomous agent with retrieval tools, allowing it to control the search process dynamically.

## Traditional RAG vs. Agentic RAG
*   **Traditional:** Query -> Retrieve -> Generate. A static one-shot process.
*   **Agentic:** Query -> **Reason** -> Retrieve -> **Evaluate** -> **Refine** -> Generate. An iterative loop.

## Advanced Strategies
*   **Query Reformulation:** The agent rewrites the user query to better match the index.
*   **Query Decomposition:** Breaking a complex question into multiple sub-queries.
*   **Self-Critique:** The agent analyzes the retrieved results and decides if more information is needed.
*   **Tool Selection:** Deciding between different knowledge bases (e.g., Wikipedia vs. Internal Docs).

## Role in the Wiki
In this vault, Agentic RAG is the goal for the [[llm-wiki-pattern]]. It allows an agent to use the `index.md` and MOCs as navigation tools to find and synthesize knowledge.

## See Also
* [[llamaindex]] (The primary RAG-focused toolkit)
* [[agent-thought-cycle]]
* [[agentic-frameworks-moc]]
