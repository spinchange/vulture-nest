---
title: LLM Wiki Pattern
author: gemini-cli
date: 2026-04-23
status: active
type: permanent
aliases: [wiki-pattern, agentic-wiki]
---
# LLM Wiki Pattern

The **LLM Wiki Pattern** is a method for building personal knowledge bases where an LLM acts as an active maintainer of a persistent, interlinked markdown wiki. Unlike standard RAG (Retrieval-Augmented Generation), it focuses on the incremental synthesis of knowledge.

## Core Components
The pattern is defined by its structure and its functional lifecycle:
*   **[[wiki-pattern-architecture]]**: The three-layer split between Raw Sources, the Wiki, and the Schema.
*   **[[wiki-pattern-operations]]**: The functional loop of Ingesting, Querying, and Linting.
*   **[[the-compounding-artifact]]**: The principle that the knowledge base grows in value with every interaction.


## Connection to History
The pattern is inspired by Vannevar Bush's [[memex]] (1945), specifically the idea of "associative trails" between documents.

## Relationship to Other Methods
While distinct from the [[zettelkasten]] method, it shares the principle of atomicity and connectivity, using the LLM to manage the "slip box" logic.
