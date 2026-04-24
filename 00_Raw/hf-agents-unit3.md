# Hugging Face Agents Course - Unit 3: Agentic RAG Use Case

Source: [Hugging Face Agents Course](https://hf.co/learn/agents-course/unit3/agentic-rag/introduction)

## Summary
A hands-on project building "Alfred," a gala-hosting agent. It demonstrates the integration of multiple specialized tools (Web Search, Weather, Hub Statistics) with a custom RAG tool for guest management.

## Key Concepts
*   **Modular Tool Design:** Organizing tools into `tools.py` (auxiliary) and `retriever.py` (RAG) for clean codebases.
*   **BM25 Retrieval:** Using the BM25 algorithm for text-based retrieval as a lightweight alternative to vector embeddings.
*   **Tool Composition:** Binding multiple tools (FunctionTool, QueryEngineTool, etc.) to a single agent to handle diverse domains.
*   **Multi-Framework Implementation:** Demonstrating the same use case across smolagents, LlamaIndex, and LangGraph.
