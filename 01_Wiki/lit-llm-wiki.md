---
title: 'Literature: LLM Wiki'
author: gemini-cli
date: 2026-05-01
status: active
type: literature
aliases:
  - llm-wiki-source
  - the-compounding-artifact-source
---
# Literature: LLM Wiki

## Source Metadata
* **File:** `00_Raw/LLM Wiki.md`
* **Origin:** Internal Pattern Document (Vulture Nest Foundation)
* **Relevance:** Canonical definition of the LLM Wiki / Vulture Nest architecture.

## High-Level Summary
The LLM Wiki pattern proposes an alternative to standard RAG. Instead of retrieving raw chunks from static documents, an LLM incrementally builds and maintains a **persistent, compounding wiki** of interlinked markdown files. The wiki acts as a "compiled" version of the knowledge base where synthesis, cross-referencing, and contradiction flagging happen at ingestion time rather than query time.

## Key Concepts Identified
* **Compounding Artifact:** The wiki is not just a cache but a structured asset that grows richer over time.
* **Three-Layer Architecture:**
    1. **Raw Sources:** Immutable source of truth.
    2. **The Wiki:** LLM-owned markdown layer (summaries, concepts, indices).
    3. **The Schema:** Instructions governing the LLM's maintenance workflows (e.g., `GEMINI.md`).
* **Core Operations:**
    * **Ingest:** Reading a source and updating 10-15 related wiki pages.
    * **Query:** Synthesizing answers from the wiki and filing them back as new notes.
    * **Lint:** Health-checking the wiki for contradictions, orphans, and stale data.
* **Navigation Primitives:**
    * `index.md`: Content-oriented catalog.
    * `log.md`: Chronological action record.

## Connections to Vault
* [[the-compounding-artifact]] — The permanent note synthesized from this document.
* [[wiki-as-codebase]] — Metaphor: Obsidian as IDE, LLM as programmer, Wiki as codebase.
* [[yanp-for-agentic-workflows]] — Formalization of the "Schema" layer for this vault.
* [[memex]] — Cited as the spiritual ancestor (Vannevar Bush, 1945).

## Related
- [[the-vulture-portal]]
- [[spec-knowledge-gardening]]
