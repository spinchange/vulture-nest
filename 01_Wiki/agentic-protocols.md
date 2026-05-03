---
title: Agentic Protocols
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [agent-interoperability]
---
# Agentic Protocols

This note tracks two important interoperability protocols in the current agent ecosystem: **[[mcp-moc|MCP]]** for agent-to-tool integration and **A2A** for agent-to-agent delegation. Both are active reference points, but they are not equally mature in adoption or tooling support.

## Maturity and Scope
- **MCP** has broad mindshare and a growing implementation ecosystem across model hosts, IDEs, and tool adapters.
- **A2A** is a newer protocol proposal focused on inter-agent collaboration; its conventions are useful to track, but deployment patterns and governance are still settling.
- This note focuses on MCP and A2A because they cover two distinct boundaries in multi-agent systems. It does not claim they are the only interoperability patterns in use.

## Model Context Protocol ([[mcp-moc|MCP]])
Developed by Anthropic and adopted across a growing set of tools, **MCP** is an open protocol for connecting model hosts to external data sources and executable capabilities.

*   **Host/Client/Server Model:** Decouples the AI application (Host) from the capability provider (Server).
*   **Layered Design:** Separates the message semantics (**Data Layer**) from the communication channel (**Transport Layer**).
*   **Primitives:** Standardizes how **[[mcp-primitives|Tools, Resources, and Prompts]]** are discovered and used.
*   **Client Capabilities:** Enables servers to leverage the host's LLM (**[[mcp-client-features|Sampling]]**) or interact with the user (**Elicitation**).

For a deep dive, see **[[mcp-architecture]]**.

## Agent-to-Agent (A2A)
**A2A** is an agent-to-agent protocol effort associated with Google and broader community work on inter-agent communication. In this vault, it is treated as a peer-to-peer complement to MCP: where MCP handles agent-to-tool communication, A2A models delegation and multi-turn collaboration between agents with their own internal state and control logic.

*   **Agent Card / Skill Model:** An agent may publish an **Agent Card** describing identity, endpoints, authentication requirements, and advertised **Skills**. In current materials, the common discovery path is `/.well-known/agent-card.json`.
*   **Stateful Task Model:** Interaction is framed around a **Task** object with a lifecycle such as `SUBMITTED → WORKING → COMPLETED`, plus states for failure or additional input.
*   **Transport Flexibility:** Current A2A materials describe request/response, streaming, and async notification patterns for longer-running work.

For the full technical model, see **[[a2a-protocol]]**. For the complementarity relationship with MCP, see **[[a2a-mcp-contrast]]**.

## Limitations and Context
- These protocols address different boundaries in a system, but real deployments may still rely on vendor APIs, framework-specific adapters, or custom orchestration layers.
- MCP is farther along in practical tooling today. A2A is more useful as a design and interoperability reference than as a universally deployed default.
- If a workflow only needs tool use inside a single host, MCP may be sufficient; A2A matters when distinct agents must advertise capabilities, exchange task state, or hand work across trust boundaries.

## References
- [[mcp-architecture]] for the host/client/server and transport model
- [[a2a-protocol]] for the task lifecycle, agent card shape, and handoff model
- [[a2a-mcp-contrast]] for the boundary between agent-to-tool and agent-to-agent protocols

## See Also
* [[index]]
* [[a2a-protocol]]
* [[a2a-mcp-contrast]]
* [[multi-agent-systems]]
* [[agent-tools]]
* [[agentic-frameworks-moc]]
