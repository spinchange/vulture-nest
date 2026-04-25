---
title: Hybrid Retrieval Specification
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [hybrid-rag, semantic-linking-spec, retrieval-tiers]
---
# Hybrid Retrieval Specification

This specification defines the dual-layer strategy for navigating the vault, bridging the gap between human-curated **Deterministic Links** and AI-driven **Semantic Discovery**.

## Tier 1: Deterministic Retrieval (Wikilinks)
*   **Mechanism**: Standard `[[Wikilinks]]` and MOC structures.
*   **Precision**: 100%.
*   **Use Case**: Navigating established hierarchies (e.g., `[[rust-moc]]` -> `[[rust-ownership]]`).
*   **Agent Rule**: Always follow explicit Wikilinks first. If a specific note is linked, assume it is the authoritative source for the context.

## Tier 2: Semantic Discovery (ChromaDB)
*   **Mechanism**: Vector similarity search via [[chromadb]].
*   **Discovery**: High.
*   **Use Case**: Finding "Hidden Relationships" where explicit links do not yet exist (e.g., finding that a concept in `[[foundry-local]]` relates to a security pattern in `[[mcp-security]]`).
*   **Agent Rule**: Use `chroma_query_documents` when a Wikilink traversal fails to resolve a query or when "exploration" is requested.

## The Bridge: Semantic Link Recommendations
To prevent "Knowledge Islands," agents should use Tier 2 to strengthen Tier 1.

### The "Discovery-Link" Workflow:
1.  **Ingestion**: After synthesizing a new note, generate a 2-sentence semantic summary.
2.  **Query**: Run `chroma_query_documents` using that summary.
3.  **Cross-Reference**: Compare the results with the current note's Wikilinks.
4.  **Recommendation**: If a result has a similarity score > 0.8 but is **not** linked, suggest adding a Wikilink to the "See Also" section.

## Technical Implementation (Agent Instructions)
When tasked with "Researching" or "Connecting" knowledge:
1.  **Map Traversal**: Start at the relevant MOC.
2.  **Semantic Expansion**: For each key concept, query ChromaDB: 
    *   `chroma_query_documents(query="[Concept Summary]", n_results=3)`
3.  **Synthesis**: Combine the hard-linked facts with the semantically discovered context to provide a "Universal" answer.

---
## References
* [[yanp-for-agentic-workflows]]
* [[chromadb]]
* [[wiki-as-codebase]]
