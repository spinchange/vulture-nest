---
title: OpenAI Agents SDK
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - agents-sdk
  - openai-agents
  - production-agents
type: permanent
---

# OpenAI Agents SDK

The **OpenAI Agents SDK** is the production-grade framework for building, running, and scaling AI agents. Unlike the experimental [[openai-swarm]], the Agents SDK is designed for applications where the developer owns the orchestration, tool execution, and state management.

## Core Capabilities

### 1. Agent Definitions
Agents are defined as specialists with specific contracts (instructions, models, and tools).
*   **Specialization:** Focus on defining clear contracts for single "specialist" agents.
*   **Providers:** Support for various model providers and configurations.

### 2. Orchestration & Handoffs
Supports multi-agent collaboration where one agent can "handoff" to another better suited for a sub-task.
*   **Control:** The application (server) owns the orchestration logic and determines who owns the reply at any given time.
*   **Patterns:** Parallel execution, hierarchical teams, and dynamic routing.

### 3. State & Results
Provides structured ways to handle the output of an agent run and manage resumable state.
*   **Run Objects:** Comprehensive return objects containing final outputs and trace data.
*   **Resumable State:** Strategies for continuing work across multiple turns or sessions.

### 4. Guardrails & Approvals
Built-in support for safety validation and human-in-the-loop (HITL) patterns.
*   **Approvals:** Mechanisms to pause or block work before risky actions are taken.
*   **Validation:** Ensuring agent outputs or tool arguments meet safety criteria.

## Tooling & Integrations

### [[mcp-moc|MCP]] (Model Context Protocol)
The Agents SDK natively supports **[[mcp-architecture|MCP]]** for integrating external tools and data sources. This allows agents to interact with a wide ecosystem of pre-built MCP servers.

### Sandbox Agents
Agents can be run in container-based environments with access to files, commands, and packages—ideal for code execution or file manipulation tasks.

## Comparison: Swarm vs. Agents SDK
| Feature | [[openai-swarm|Swarm]] | Agents SDK |
| :--- | :--- | :--- |
| **Status** | Experimental / Educational | Production-Ready |
| **State** | Stateless (Caller manages) | Resumable / Managed |
| **Orchestration** | Lightweight (Function-based) | Comprehensive / Tool-based |
| **Security** | Minimal | Guardrails / Sandbox / Approvals |

---
*Source: [[lit-openai-swarm]]*

