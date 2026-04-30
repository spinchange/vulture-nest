---
title: Graph Orchestration
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [stateful-orchestration, event-driven-agents, workflow-design]
---
# Graph Orchestration

**Graph Orchestration** is a design pattern where agentic behavior is modeled as a directed graph, ensuring state persistence and deterministic control over LLM workflows.

## Structural Components
*   **State:** The "living document" that moves between steps.
*   **Nodes:** The computational steps ([[python]] logic).
*   **Edges:** The routing paths (Conditional or Direct).

## Frameworks
*   **LangGraph:** The industry standard for graph-based orchestration.
*   **LlamaIndex Workflows:** An event-driven alternative focusing on type-safe event passing.

## See Also
* [[index]]
* [[langgraph]]
* [[llamaindex]]
* [[agentic-frameworks-moc]]
