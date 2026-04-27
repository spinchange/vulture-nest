---
title: 'Community Report: Agentic Protocols'
author: gemini-cli
date: 2025-05-14T00:00:00.000Z
status: active
type: community-report
aliases:
  - agentic-protocols-report
  - agent-protocols-report
  - agency-communication-summary
---

# Community Report: Agentic Protocols

**Context:** This report synthesizes the standards and patterns governing AI agent communication and execution. It clusters 15 notes that define how agents interact with tools, other agents, and users.

## 1. Inter-Agent Communication

A core theme is the formalization of "Agent-to-Agent" (A2A) interactions.

*   **The A2A Protocol:** [[a2a-protocol]] establishes the baseline for handoffs and collaborative task execution.
*   **Protocol Contrast:** [[a2a-mcp-contrast]] highlights the differences between the capability-focused MCP and the workflow-focused A2A.

## 2. The Thought-Action Loop

The vault documents the internal logic and external execution patterns of agents.

*   **Cognitive Cycles:** [[agent-thought-cycle]] and the [[react-pattern]] (Reason + Act) describe how agents iterate through observations and reasoning before acting.
*   **Actions & Tools:** [[agent-actions]] and [[agent-tools]] define the primitives of agent capability. The [[agent-actions-unit]] provides a curriculum for understanding these mechanics.

## 3. Interfaces and Primitives

The technical substrate for agent interaction is well-represented.

*   **Data Exchange:** [[chat-templates]] and [[function-calling]] are the primary mechanisms for structuring LLM inputs and outputs.
*   **MCP Integration:** [[mcp-primitives]] and [[mcp-server-features]] define the standardized way tools are exposed to agents.

## 4. Evaluation and Human Interaction

*   **Benchmarks:** [[gaia-benchmark]] provides the standard for testing agentic reasoning on real-world tasks.
*   **HITL:** [[hitl-ui-patterns]] explores the design of interfaces for "Human-in-the-Loop" systems, ensuring safety and alignment.

---
## References
- [[agentic-protocols]]
- [[hf-agents-course-moc]]
- [[a2a-protocol]]
- [[mcp-primitives]]
