---
title: OpenAI Agents SDK
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [openai-agents, production-agents-sdk]
---
# OpenAI Agents SDK

The **OpenAI Agents SDK** is the production-ready evolution of the experimental [[openai-swarm|Swarm]] framework. It provides a robust, code-first approach to building, running, and scaling multi-agent systems.

## Core Philosophy
Unlike fully-hosted agent solutions, the SDK is designed for applications that want to own:
* **Orchestration**: Direct control over how agents interact and hand off tasks.
* **Tool Execution**: Running code and APIs within the application's own security boundary.
* **State Management**: Handling conversation history and persistent data.
* **Approvals**: Explicit human-in-the-loop checkpoints.

## Key Components
* **Agent Definitions**: Clear separation of instructions, tools, and model configuration.
* **Sandbox Agents**: Container-based environments that provide secure execution for files, commands, and packages.
* **Guardrails**: Integrated mechanisms for safety, validation, and user approvals.
* **Orchestration**: Support for complex patterns like handoffs, parallel execution, and hierarchical teams.

## Advanced Patterns
* **Realtime API Integration**: Building voice and low-latency interactive agents.
* **MCP Integration**: Leveraging the [[mcp-architecture|Model Context Protocol]] for standardized tool and resource access.
* **Observability**: Built-in hooks for tracking agent reasoning, tool calls, and results.

---
## References
* Source: `00_Raw/openai-agents-and-swarm.md`
* [[openai-swarm]]
* [[agentic-frameworks-moc]]
* [[mcp-architecture]]
