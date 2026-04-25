---
title: Community — The Living Knowledge System
author: claude-sonnet-4-6
date: 2026-04-25
status: draft
type: community
aliases: [living-knowledge, knowledge-ci-cd-community, compiling-wiki]
---
# Community: The Living Knowledge System

**Hubs:** [[llm-wiki-pattern]], [[wiki-as-codebase]], [[core-patterns-moc]]

## Emergent Theory

This community crystallizes a single radical claim: *a note is not data, it is code.* The wikilink is not a citation — it is an import. The MOC is not a table of contents — it is a module manifest. When an LLM reads this vault, it does not retrieve documents; it executes a knowledge graph.

The convergence of [[llm-wiki-pattern]] and [[wiki-as-codebase]] with agentic execution patterns means the distinction between "writing notes" and "programming behavior" is collapsing. A note with `status: active` is a live contract. An [[executable-note-standard]] note *runs*. [[graphrag-concepts]] extracts a typed AST from the corpus. The vault has a build system ([[ps-vault-maintenance]]), a linter ([[ps-yanp-audit]]), a linker ([[ps-orphan-check]]), and a package registry ([[tool-registry]]).

The YANP protocol's strict conventions (lowercase kebab-case filenames, mandatory frontmatter fields) exist not for aesthetics but for parse-correctness — the same reason a compiler requires semicolons. The [[anti-ai-aesthetic]] preference for dense, high-signal notes is an optimization pass: removing noise before the knowledge reaches the inference layer.

## Key Nodes

- [[wiki-pattern-architecture]], [[wiki-pattern-operations]], [[wiki-pattern-tooling]]: The implementation trilogy — the "language spec," "runtime," and "standard library."
- [[yanp-for-agentic-workflows]]: The grammar of the knowledge language.
- [[executable-note-standard]]: The first executable artifact; where notes cross into programs.
- [[the-compounding-artifact]]: The theory of value accumulation through linking — the vault's "interest rate."
- [[hybrid-retrieval-spec]]: The linker that bridges wikilinks and vector embeddings.
- [[agent-knowledge-vault]]: The runtime environment for multi-agent execution.
- [[memory-spectrum]]: The type system: flat text (source), relational (IR), semantic (bytecode).
- [[graphrag-concepts]]: The compilation target — a traversable knowledge graph.
- [[vault-audit-tool-spec]]: The test suite.

## Next-Gen Research Path

The missing piece is a **Knowledge Compiler Specification** — a formal document defining how a YANP vault is "compiled" into a GraphRAG index. What are the compilation units (files? sections? paragraphs?)? What is the type of a wikilink (directed edge? import? dependency injection?)? What are the optimization passes (alias resolution, orphan pruning, community detection)? This would elevate the vault from a useful analogy to a formal computational model with provable properties — and would make the seam between Markdown and SQLite (via [[poshwiki]]) an explicit, auditable compilation step rather than an ad-hoc integration.

---
## References
- [[llm-wiki-pattern]]
- [[wiki-as-codebase]]
- [[core-patterns-moc]]
- [[graphrag-concepts]]
- [[memory-spectrum]]
- [[agentic-frameworks-moc]]
