---
title: "Literature: HF Agents Course - Unit 1 & 2"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/hf-agents-course-unit1.md", "00_Raw/hf-agents-course-unit2.md"]
aliases: ["HF Agents Fundamentals", "Agentic Frameworks Comparison"]
---

# Literature: HF Agents Course - Fundamentals & Frameworks

This literature note covers the foundational theory and framework landscape from the Hugging Face Agents Course (Units 1 & 2).

## Unit 1: Foundations
- **Core Components**: Agents are defined by **LLMs (Brain)**, **Tools (Body)**, and the **Thought-Action-Observation (Workflow)** cycle.
- **ReAct (Reasoning + Acting)**: The primary prompting pattern where agents interleave reasoning steps with tool execution.
- **Stop and Parse**: The technical mechanism where the LLM yields control to an external executor to run a tool and return the observation.
- **Chat Templates**: Critical infrastructure for translating high-level conversation roles (System, User, Assistant) into model-specific special tokens.

## Unit 2: Framework Landscape (Control vs. Freedom)
The course identifies three primary architectural approaches:

### 1. smolagents (Hugging Face)
- **Focus**: "Freedom" via **Code Agents**.
- **Philosophy**: Minimalist abstractions; tools are called by the LLM writing and executing actual code snippets.

### 2. LlamaIndex
- **Focus**: "Data Agency" (RAG).
- **Philosophy**: Optimized for data ingestion and retrieval using `QueryEngines` and `Workflows` to bridge static data and action.

### 3. LangGraph (LangChain)
- **Focus**: "Control" & "State Management".
- **Philosophy**: Uses a Directed Acyclic Graph (DAG) or cyclic graph structure for deterministic, industrial-strength orchestration.

## Key Theoretical Concepts
- **State Management**: The distinction between transient context (LlamaIndex) and persistent, checkpointed state (LangGraph).
- **Agentic RAG**: Moving beyond simple retrieval to autonomous query reformulation and multi-step validation.

---
## See Also
- [[hf-agents-course-moc]]
- [[smolagents]]
- [[langgraph]]
- [[agentic-rag]]
- [[agent-thought-cycle]]
