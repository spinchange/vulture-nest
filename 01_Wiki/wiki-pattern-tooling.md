---
title: Wiki Pattern Tooling
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [wiki-tools, qmd, dataview, marp]
---
# Wiki Pattern Tooling

The [[llm-wiki-pattern]] can be enhanced by a specific ecosystem of tools that improve search, presentation, and data management.

## Search and Retrieval
*   **qmd:** A local search engine for markdown files that uses hybrid BM25/vector search. It can be used by the LLM via CLI or [[mcp-moc|MCP]] server to navigate larger wikis.
*   **Dataview:** An Obsidian plugin that allows for dynamic, database-like queries over page frontmatter (e.g., listing all `active` notes by `date`).

## Content Capture
*   **Obsidian Web Clipper:** Converts web articles directly to markdown, serving as a primary intake for `00_Raw/`.
*   **Local Image Management:** Storing images in a fixed directory (e.g., `raw/assets/`) allows the LLM to reference them as stable artifacts.

## Presentation and Output
*   **Marp:** A markdown-based slide deck format. Allows the LLM to generate presentations directly from synthesized wiki pages.
*   **Canvas:** Obsidian's spatial layout tool for mapping out complex relationships between notes visually.

## See Also
*   [[llm-wiki-pattern]]
*   [[wiki-pattern-operations]]

