---
title: "Literature: HF Agents Course - Unit 3 & 4"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/hf-agents-unit3.md", "00_Raw/hf-agents-final-units.md"]
aliases: ["Agentic RAG Implementation", "GAIA Evaluation"]
---

# Literature: HF Agents Course - Applications & Evaluation

This literature note covers implementation patterns (Unit 3) and the evaluation benchmark (Unit 4) from the Hugging Face Agents Course.

## Unit 3: Implementation Patterns (Alfred the Gala Host)
- **Modular Tool Design**: Organizing code into `tools.py` (auxiliary logic) and `retriever.py` (RAG logic) for maintainability.
- **BM25 Retrieval**: Utilization of lexical (keyword) retrieval as a lightweight alternative for keyword-driven search tasks where semantic embeddings may be unnecessary or too costly.
- **Tool Composition**: The technique of binding multiple tool types (FunctionTool, QueryEngineTool) to a single agent for cross-domain mastery.

## Unit 4: Evaluation (GAIA Benchmark)
- **GAIA (General AI Assistants)**: A benchmark of 466 real-world tasks in the course material, designed to be simple for humans but difficult for LLMs.
- **Complexity Levels**:
    - **Level 1**: Basic tool use (< 5 steps).
    - **Level 2**: Complex coordination (5-10 steps).
    - **Level 3**: Long-term planning and deep multi-hop reasoning.
- **Evaluation Philosophy**: Measures successful task completion in an environment intended to resist shortcut gaming, with emphasis on multi-modal understanding and reasoning.

## Supplementary Deployment & Local Runtimes
The source bundle also included setup-oriented material that complements Units 3 and 4 without being the main focus of the application/evaluation sections.
- **Ollama**: Standard for local LLM inference.
- **LiteLLM**: Provides a provider-agnostic bridge (`LiteLLMModel`), allowing frameworks like `smolagents` to utilize local models seamlessly.

---
## See Also
- [[hf-agents-course-moc]]
- [[gaia-benchmark]]
- [[agent-evaluation]]
- [[agentic-rag]]
- [[mcp-moc]]
