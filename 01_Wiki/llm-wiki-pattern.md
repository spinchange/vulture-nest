---
title: LLM Wiki Pattern
author: claude-sonnet-4-6
date: 2026-04-25
status: active
type: permanent
aliases: [wiki-pattern, agentic-wiki]
---
# LLM Wiki Pattern

The **LLM Wiki Pattern** is a method for building personal knowledge bases where an LLM acts as an active maintainer of a persistent, interlinked markdown wiki. Unlike standard RAG (Retrieval-Augmented Generation), it treats knowledge synthesis as a **compile-time problem**, not a runtime one. The distinction is load-bearing.

## Core Components
The pattern is defined by its structure and its functional lifecycle:
*   **[[wiki-pattern-architecture]]**: The three-layer split between Raw Sources, the Wiki, and the Schema.
*   **[[wiki-pattern-operations]]**: The functional loop of Ingesting, Querying, and Linting.
*   **[[the-compounding-artifact]]**: The principle that the knowledge base grows in value with every interaction.

## The Case Against Vector-Only RAG

A vector database is a lossy compression of meaning. It maps text into a high-dimensional space where proximity is a proxy for semantic similarity — but proximity is not equivalence, and approximation is not understanding.

The structural problems with pure vector retrieval:

**No graph.** Chunks float in an undifferentiated space. There is no concept of "this idea connects to that idea via a specific, named relationship." A wiki link is a typed edge. A vector neighbor is a statistical correlation.

**No provenance.** A retrieved chunk carries no author, no date, no status. The agent cannot know whether it is reading a settled conclusion, a speculative draft, or a retracted hypothesis. YANP frontmatter encodes this metadata explicitly and durably.

**No auditability.** When a vector database is updated, the mutation is invisible. There is no diff, no commit, no reviewable change. Every wiki mutation is a git commit — inspectable, reversible, attributable to a specific agent at a specific time.

**No centrality.** All chunks are equal peers in a vector space. A wiki graph has **hubs** — notes with many inbound links that represent settled, load-bearing knowledge. The link graph is a natural importance signal that vectors cannot replicate.

## Auditable Memory: The Git Invariant

The wiki's most underappreciated property is **auditability**. Every synthesis the LLM produces is a git diff. This creates the Git Invariant:

> Any change to the knowledge base is traceable to a specific agent, at a specific time, with a specific rationale preserved in the commit message.

This is not an academic distinction. It means:
- Regressions are catchable: if a note encodes an incorrect conclusion, `git blame` traces the error to its source commit.
- Multi-agent collaboration is safe: when Gemini and Claude both edit the vault, write conflicts are resolved by merge, not by silent overwrite.
- The human retains a hard gate: changes do not propagate until `git push`. No vector database offers this control point.

The [[the-compounding-artifact|Compounding Artifact]] depends on auditability. A knowledge base that cannot be inspected cannot be trusted. A knowledge base that cannot be trusted cannot compound.

## Ahead-of-Time vs. Just-In-Time Synthesis

RAG defers synthesis to query time. Every query triggers: retrieve → stuff context → LLM synthesizes. This is **Just-in-Time (JIT)** — cheap to populate, expensive and inconsistent to query. Synthesis quality varies by query phrasing, context window pressure, and the retrieval lottery.

The LLM Wiki Pattern inverts this. Contradictions are resolved at ingestion. Cross-references are established during triage. Emergent theories are extracted and promoted to permanent notes before anyone asks for them. This is **Ahead-of-Time (AOT) Synthesis** — expensive to maintain, cheap and deterministic to read.

The wiki is a **pre-compiled knowledge graph**. When a query arrives, the synthesis work is already done. The inference call becomes verification, not discovery.

## The Thin Node Problem

A "Thin Node" is a hub note that connects many ideas but contains no original synthesis. It is a junction without substance — a table of contents masquerading as an essay.

Thin Nodes are dangerous precisely because they look healthy. The graph shows high connectivity. The content is hollow. The solution is deliberate densification: every hub must contain **Vulture Theory** — original argument derived from the connections it manages, not merely a list of them.

A hub that lists its neighbors without synthesizing them is a map with no terrain. It tells you where things are. It does not tell you what they mean together.

## Connection to History

The pattern descends from Vannevar Bush's [[memex]] (1945) — specifically the concept of "associative trails" between documents — and Douglas Engelbart's [[augmenting-human-intellect]] program. The key difference is execution: Bush imagined microfilm and mechanical linkage; we have markdown, git, and LLMs operating at token scale.

The [[zettelkasten]] method provides the atomicity principle: one idea per note, explicit links between notes. The LLM adds the active maintenance layer that Luhmann had to perform manually across decades of physical slips.

## See Also
- [[wiki-as-codebase]]
- [[the-compounding-artifact]]
- [[yanp-for-agentic-workflows]]
- [[wiki-pattern-architecture]]
- [[wiki-pattern-operations]]
- [[memex]]
- [[augmenting-human-intellect]]
