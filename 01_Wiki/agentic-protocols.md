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

*   **Agent Card / Skill Model:** Each agent publishes an **Agent Card** at `/.well-known/agent-card.json` declaring its identity, endpoints, authentication requirements, and a list of **Skills** — discrete advertised capabilities. The Agent Card is the A2A structural equivalent of an MCP server manifest; a Skill is the A2A equivalent of an MCP Tool.
*   **Stateful Task Model:** Interaction is built around a **Task** object with a defined lifecycle (`SUBMITTED → WORKING → COMPLETED / FAILED / INPUT_REQUIRED / AUTH_REQUIRED`). Tasks support multi-turn dialogue — the agent can pause and request additional input or credentials before resuming.
*   **Transport Flexibility:** Supports request/response (`SendMessage`), server-streaming SSE (`SendStreamingMessage`), and push notifications to a client-registered webhook for fully async delivery — all operating over the same JSON-RPC or gRPC bindings.
*   **Authentication:** Delegates entirely to OAuth 2.0 / OIDC. Auth schemes are declared in the Agent Card; credentials are acquired out-of-band and passed via HTTP headers. This makes A2A suitable for cross-organization agent federation.
*   **Parts:** Message content is expressed as typed **Part** objects — `TextPart`, `FilePart` (URL or inline bytes), `DataPart` (structured JSON) — with MIME type negotiation.

For the full technical model, see **[[a2a-protocol]]**. For the complementarity relationship with MCP, see **[[a2a-mcp-contrast]]**.

## See Also
* [[a2a-protocol]]
* [[a2a-mcp-contrast]]
* [[multi-agent-systems]]
* [[agent-tools]]
* [[agentic-frameworks-moc]]

