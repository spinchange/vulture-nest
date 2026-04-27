---
title: LangGraph
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [langgraph-framework, graph-orchestration, production-agents]
---
# LangGraph

**LangGraph** is a framework developed by LangChain to manage the **control flow** of LLM applications. It prioritizes deterministic orchestration over the "freedom" of pure autonomous agents.

## The Graph Philosophy
LangGraph represents an application as a directed graph:
*   **Nodes:** [[python]] functions representing processing steps (LLM calls, tool execution).
*   **Edges:** Transitions between nodes.
*   **State:** A user-defined object that flows through the graph, serving as the "shared memory" for all nodes.

## Control vs. Freedom
LangGraph is ideal for production systems where predictable behavior is mandatory.
*   **Freedom:** Agents like `smolagents` can call tools in any order.
*   **Control:** LangGraph enforces specific paths, loops, and branching logic.

## Key Mechanisms
*   **Conditional Edges:** Routing logic that determines the next node based on the current `State`.
*   **Human-in-the-loop:** Built-in support for pausing execution to wait for user approval or input.

## See Also
* [[graph-orchestration]]
* [[agent-thought-cycle]] (Implementation via ReAct graphs)
* [[agentic-frameworks-moc]]

