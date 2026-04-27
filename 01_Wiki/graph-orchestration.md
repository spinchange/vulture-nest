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

## When to Use Graphs
1.  **Deterministic Paths:** When specific business logic must be followed (e.g., "Classify as spam first, then draft a reply").
2.  **Long-Running Tasks:** Where state must be saved and resumed.
3.  **Human Interventions:** Pausing for approval before an action.

## Frameworks
*   **LangGraph:** The industry standard for graph-based orchestration.
*   **LlamaIndex Workflows:** An event-driven alternative focusing on type-safe event passing.

## See Also
* [[langgraph]]
* [[llamaindex]]
* [[agentic-frameworks-moc]]

