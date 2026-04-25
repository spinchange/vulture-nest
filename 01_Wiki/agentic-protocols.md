---
title: Agentic Protocols
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp, a2a, agent-interoperability]
---
# Agentic Protocols

As the ecosystem of AI agents matures, standardized protocols are emerging to ensure that models, tools, and agents can communicate seamlessly.

## Model Context Protocol (MCP)
Developed by Anthropic, **MCP** is an open standard designed as a "USB-C port for AI applications." It provides a universal interface for connecting models to external data and tools.

*   **Host/Client/Server Model:** Decouples the AI application (Host) from the capability provider (Server).
*   **Layered Design:** Separates the message semantics (**Data Layer**) from the communication channel (**Transport Layer**).
*   **Primitives:** Standardizes how **[[mcp-primitives|Tools, Resources, and Prompts]]** are discovered and used.
*   **Client Capabilities:** Enables servers to leverage the host's LLM (**[[mcp-client-features|Sampling]]**) or interact with the user (**Elicitation**).

For a deep dive, see **[[mcp-architecture]]**.

## Agent-to-Agent (A2A)
Developed by Google, **A2A** focuses on the collaboration between different autonomous systems.
*   **Purpose:** Standardizes how one agent requests help or hands off a task to another agent.
*   **Significance:** Enables massive, distributed multi-agent swarms.

## See Also
* [[multi-agent-systems]]
* [[agent-tools]]
* [[agentic-frameworks-moc]]
