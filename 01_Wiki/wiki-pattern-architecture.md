---
title: Wiki Pattern Architecture
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [three-layer-architecture, wiki-layers]
---
# Wiki Pattern Architecture

The [[llm-wiki-pattern]] is built on a three-layer architecture that separates the source of truth from the synthesis and the rules of operation.

## 1. Raw Sources
A curated collection of immutable documents (articles, papers, data files). The LLM reads from these but never modifies them. This is the **Source of Truth**.

## 2. The Wiki
A directory of LLM-generated markdown files (summaries, entity pages, concept pages). The LLM owns this layer entirely, maintaining consistency and cross-references. This is the [[the-compounding-artifact]].

## 3. The Schema
A configuration document (like `GEMINI.md`) that defines the structure, conventions, and workflows. It governs how the LLM interacts with the other layers.

## See Also
*   [[llm-wiki-pattern]]
*   [[wiki-pattern-operations]]
