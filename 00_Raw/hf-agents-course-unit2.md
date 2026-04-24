# Hugging Face Agents Course - Unit 2: Agentic Frameworks

Source: [Hugging Face Agents Course](https://hf.co/learn/agents-course/unit2/introduction)

## Summary
Unit 2 explores specialized frameworks for building production-ready agents. It contrasts different approaches to the "Control vs. Freedom" trade-off.

## Frameworks Covered
*   **smolagents (Hugging Face):** Focuses on "Freedom" via Code Agents. Emphasizes minimal abstractions and code-centric tool calls.
*   **LlamaIndex:** Optimized for "Data Agency" (RAG). Uses `QueryEngines` and `Workflows` to bridge the gap between static data and autonomous action.
*   **LangGraph (LangChain):** Focuses on "Control." Uses a directed graph structure (Nodes, Edges, State) for deterministic orchestration of LLM steps.

## Key Theoretical Concepts
*   **State Management:** How an agent maintains context (LlamaIndex `Context` vs. LangGraph `State`).
*   **Multi-Agent Systems:** Orchestrating specialized sub-agents (Manager/Worker patterns).
*   **Agentic RAG:** Moving beyond simple retrieval to autonomous query reformulation and validation.
