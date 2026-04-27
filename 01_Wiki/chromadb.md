---
title: ChromaDB
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [chroma, vector-database, semantic-memory]
---
# ChromaDB

**ChromaDB** is an open-source embedding database designed to provide semantic memory for AI agents and applications. It allows for the storage, management, and retrieval of documents using vector similarity search.

## Core Capabilities
* **Semantic Search**: Find relevant documents based on meaning rather than just keyword matches.
* **Metadata Filtering**: Refine search results using structured metadata attributes.
* **Persistent Storage**: Save embeddings and documents locally or in the cloud for long-term recall.
* **Collection Management**: Organize data into logical groups (collections) with configurable indexing (e.g., HNSW).

## Integration with Agents
Chroma is frequently used as a "Long-term Memory" layer for agents, enabling:
1. **Context Retrieval (RAG)**: Injecting relevant facts into an agent's prompt based on the current conversation.
2. **Session Continuity**: Allowing agents to remember past interactions across multiple sessions.
3. **Knowledge Base Management**: Giving agents the ability to dynamically update and query their own documentation.

## [[mcp-moc|MCP]] Integration
Chroma provides a standardized **MCP Server**, allowing any [[mcp-architecture|MCP-compatible]] agent to interact with the database using common tools:
* `chroma_query_documents`: Perform semantic search.
* `chroma_add_documents`: Ingest new information.
* `chroma_list_collections`: Explore available data structures.

---
## References
* Source: `00_Raw/adk-documentation.md`
* [[agent-knowledge-vault]]
* [[mcp-architecture]]
* [[agentic-rag]]

