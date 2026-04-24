# LLM Wiki Pattern Summary

The **LLM Wiki pattern** is a framework for building a personal knowledge base where an LLM incrementally builds and maintains a persistent, structured, and interlinked collection of markdown files (a wiki) instead of relying on traditional query-time RAG (Retrieval-Augmented Generation).

## Core Philosophy
Unlike standard RAG, which re-discovers knowledge from raw sources for every query, the LLM Wiki pattern treats the knowledge base as a **compounding artifact**. The LLM synthesizes new information into the existing wiki structure, maintaining cross-references, resolving contradictions, and keeping summaries current.

## Architecture
1. **Raw Sources**: Immutable source documents (articles, papers, data) that serve as the ground truth.
2. **The Wiki**: A directory of markdown files (entity pages, concept summaries, indices) authored and maintained entirely by the LLM.
3. **The Schema**: A configuration file (e.g., `GEMINI.md` or `AGENTS.md`) that defines the wiki's structure, conventions, and operational workflows.

## Key Operations
- **Ingest**: The LLM reads a new source, discusses takeaways with the user, and updates all relevant wiki pages (often 10-15 files) to integrate the new knowledge.
- **Query**: The LLM uses the wiki to answer questions. Valuable insights or synthesized comparisons can be filed back into the wiki as new pages.
- **Lint**: Periodic health checks where the LLM identifies contradictions, stale information, orphan pages, or missing connections.

## Essential Files
- **index.md**: A content-oriented catalog of all wiki pages, allowing the LLM to navigate the knowledge base without complex vector infrastructure.
- **log.md**: A chronological, append-only record of all ingestions, queries, and maintenance tasks.

## Why it Works
By automating the "bookkeeping" (cross-referencing, filing, and consistency checks), the LLM removes the primary barrier to maintaining a personal wiki. The human focuses on curation and high-level inquiry, while the LLM ensures the knowledge base grows in value over time.
