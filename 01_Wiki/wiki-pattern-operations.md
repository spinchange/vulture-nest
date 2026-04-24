---
title: Wiki Pattern Operations
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [wiki-ingest, wiki-query, wiki-lint]
---
# Wiki Pattern Operations

The lifecycle of an [[llm-wiki-pattern]] involves three primary operations that keep the knowledge base alive and healthy.

## Ingest
Processing a new source. The LLM reads the source, updates the index, creates or revises entity pages, and appends to the log. A single ingest might touch 10-15 files to ensure the new knowledge is fully integrated into the [[the-compounding-artifact]].

## Query
Answering questions against the wiki. The LLM reads the `index.md` to find relevant pages, synthesizes an answer, and—crucially—files valuable findings back into the wiki as new pages. This allows explorations to compound over time.

## Lint
Periodic health checks. The LLM audits the wiki for contradictions, stale claims, orphan pages, or missing cross-references. This maintenance prevents the "knowledge rot" that usually kills manual wikis.

## See Also
*   [[llm-wiki-pattern]]
*   [[wiki-pattern-architecture]]
