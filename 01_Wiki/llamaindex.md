---
title: LlamaIndex
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [llamaindex-framework, data-agency, rag-framework]
---
# LlamaIndex

**LlamaIndex** is a comprehensive toolkit designed to build context-augmented agents. It bridges the gap between Large Language Models and private data through robust retrieval and indexing components.

## Key Components
*   **QueryEngine:** A component that retrieves relevant information (RAG) and provides a synthesized answer.
*   **VectorStoreIndex:** A searchable data structure for embeddings.
*   **LlamaHub:** A vast registry of community-contributed loaders, tools, and agent templates.

## Agency in LlamaIndex
LlamaIndex supports multiple agent patterns:
*   **Function Calling Agents:** For models with native tool-calling APIs.
*   **ReAct Agents:** For general-purpose reasoning over any LLM.
*   **Agentic RAG:** Using a `QueryEngine` as a tool, allowing the agent to decide when and how to search the data.

## State & Workflows
*   **Context:** A state-management object that allows agents to remember past interactions.
*   **Workflows:** An event-driven, async-first way to define agentic behavior as a sequence of discrete steps and events.

## See Also
* [[agentic-rag]]
* [[graph-orchestration]]
* [[agentic-frameworks-moc]]
