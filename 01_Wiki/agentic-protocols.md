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

## Model Context Protocol ([[mcp-moc|MCP]])
Developed by Anthropic, **MCP** is an open standard designed as a "USB-C port for AI applications." It provides a universal interface for connecting models to external data and tools.

*   **Host/Client/Server Model:** Decouples the AI application (Host) from the capability provider (Server).
*   **Layered Design:** Separates the message semantics (**Data Layer**) from the communication channel (**Transport Layer**).
*   **Primitives:** Standardizes how **[[mcp-primitives|Tools, Resources, and Prompts]]** are discovered and used.
*   **Client Capabilities:** Enables servers to leverage the host's LLM (**[[mcp-client-features|Sampling]]**) or interact with the user (**Elicitation**).

For a deep dive, see **[[mcp-architecture]]**.

## Agent-to-Agent (A2A)
Developed by Google and now governed by the `a2aproject` organization, **A2A** is the peer-to-peer complement to MCP. Where MCP governs agent-to-tool communication, A2A governs agent-to-agent delegation and multi-turn collaboration between opaque, stateful agents.

*   **Agent Card / Skill Model:** Each agent publishes an **Agent Card** at `/.well-known/agent-card.json` declaring its identity, endpoints, authentication requirements, and a list of **Skills** — discrete advertised capabilities.
*   **Stateful Task Model:** Interaction is built around a **Task** object with a defined lifecycle (`SUBMITTED → WORKING → COMPLETED / FAILED / INPUT_REQUIRED / AUTH_REQUIRED`).
*   **Transport Flexibility:** Supports request/response, server-streaming SSE, and push notifications.

For the full technical model, see **[[a2a-protocol]]**. For the complementarity relationship with MCP, see **[[a2a-mcp-contrast]]**.

## See Also
* [[index]]
* [[a2a-protocol]]
* [[a2a-mcp-contrast]]
* [[multi-agent-systems]]
* [[agent-tools]]
* [[agentic-frameworks-moc]]
