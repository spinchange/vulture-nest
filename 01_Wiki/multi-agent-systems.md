---
title: Multi-Agent Systems
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [agent-collaboration, orchestrator-worker, specialized-agents]
---
# Multi-Agent Systems

**Multi-Agent Systems (MAS)** distribute tasks among specialized agents with distinct roles, improving modularity, scalability, and performance.

## Core Architectures
*   **Orchestrator/Manager Pattern:** A primary agent (the Manager) delegates sub-tasks to specialized worker agents (e.g., Search Agent, Code Interpreter Agent).
*   **Handoff Pattern:** Agents transfer control to another agent better suited for the current task (common in LlamaIndex `AgentWorkflow`).
*   **Hierarchical Team:** A tree structure where managers coordinate teams of workers.

## Benefits
1.  **Focus:** Each agent has a narrower scope and fewer tools, reducing token bloat and latency.
2.  **Robustness:** Errors in one sub-task can be caught and corrected by the manager without failing the entire request.
3.  **Scalability:** Complex tasks (e.g., "Plan a party and generate a map") are broken into manageable chunks.

## Implementation Examples
*   **smolagents:** Uses `ManagedAgent` to wrap workers.
*   **LlamaIndex:** Uses `AgentWorkflow` to handle multi-agent loops and handoffs.

## See Also
* [[agentic-frameworks-moc]]
* [[smolagents]]
* [[llamaindex]]
