---
title: MCP Architecture
author: claude-sonnet-4-6
date: 2026-04-25
status: active
type: permanent
aliases: [mcp-model, mcp-layers, mcp-lifecycle, mcp-standard-model]
---
# MCP Architecture

The **Model Context Protocol (MCP)** is the USB-C specification for agent-to-tool communication. Before MCP, every AI application that needed to access external tools — filesystems, databases, APIs, web browsers, code executors — built a bespoke integration. The result was a combinatorial explosion of incompatible interfaces: each model vendor had their own function-calling format, each tool had its own auth scheme, and every new capability required custom glue code. MCP collapses this to a single, negotiated standard.

## Participants

- **MCP Host**: The AI application (Claude Desktop, VS Code Copilot, a custom agent loop) that users interact with. It coordinates multiple MCP Clients and owns the security context for the session.
- **MCP Client**: A protocol-level component *within* the Host that maintains a dedicated, stateful connection to a single MCP Server. The Host can run many Clients simultaneously; each is isolated.
- **MCP Server**: A lightweight process that exposes a typed capability set: Resources, Tools, or Prompts. It has no visibility into other Servers in the same Host.

The Host/Client/Server separation enforces **capability isolation**. A filesystem MCP Server does not automatically receive network access because a network MCP Server is also connected. Each Server's scope is defined by what it exposes, not by what the Host has access to.

## The Three Primitives: A Complete Ontology

MCP exposes exactly three primitive types to agents. This is not an arbitrary decomposition — it is a claim that these three cover the full surface area of agent-to-world interaction.

**Resources** (nouns): Read-only data sources with URIs and optional MIME types. Files, database rows, API responses, configuration values. An agent reads a Resource; it does not execute it. Resources describe the state of the world.

**Tools** (verbs): Callable actions with side effects. `write_file`, `run_query`, `send_email`, `create_event`. They have JSON Schema–typed input parameters and return structured results. Tools modify the state of the world.

**Prompts** (grammar): Reusable, parameterized prompt templates. They allow server authors to encode domain-specific interaction patterns — a `git_commit_message` prompt, a `code_review` prompt — that the Host can inject into the conversation at the appropriate moment. Prompts structure communication about state.

Every meaningful agentic capability decomposes into one of these three primitives, or it reveals a gap in the protocol specification. This ontological completeness is what makes MCP a **Standard Model** rather than just another integration format.

## Protocol Layers

**Data Layer (Inner):** JSON-RPC 2.0. Every MCP message is a JSON-RPC call or notification. JSON-RPC provides standard request/response pairing, error propagation with typed error codes, and batch processing — capabilities that HTTP alone does not specify. Using an existing standard here is intentional: it means any JSON-RPC tooling (debuggers, proxies, logging middleware) works with MCP out of the box.

**Transport Layer (Outer):** Stdio or HTTP/SSE. Stdio is the local-first choice: the Host spawns the Server as a subprocess and communicates over stdin/stdout. No networking, no port binding, no firewall configuration. HTTP/SSE enables remote Servers and multi-tenant deployments. The [[mcp-transport]] note covers the tradeoffs; the key point is that the Data Layer is transport-agnostic by design.

## Stateful Connections and Capability Negotiation

MCP is a **stateful protocol**. The connection lifecycle has three phases:

1. **Initialize**: The Client sends its capabilities (protocol version, supported features, client info). The Server responds with its capabilities. Neither party assumes the other is compliant with any particular version — they negotiate to a common subset.
2. **Confirmed**: The Client sends `notifications/initialized`. The handshake is complete. Both parties now know exactly what they can do together.
3. **Dynamic Updates**: Servers send `list_changed` notifications (e.g., `notifications/tools/list_changed`) when their capability set changes at runtime — when a user authenticates, when a resource becomes available, when a plugin loads.

The statefulness is not a performance optimization — it is a **security model**. A stateless API treats every caller identically. A stateful MCP Server knows who it is talking to, what capabilities were negotiated at initialization, and what the current authorization scope is. Trust is negotiated, not assumed.

## The Discovery Problem: MCP vs. Static APIs

Traditional API integration is a design-time workflow. A human developer reads documentation, understands the schema, and writes client code. The integration is hardcoded; any change to the API requires code changes.

MCP enables **runtime discovery**. An agent cold-starting in an unknown environment calls `list_tools` on available Servers and builds a complete map of its current capability set — without prior documentation, without hardcoded assumptions. This is architecturally transformative.

It means agent capability is **dynamic**: a Server can expose new Tools after authentication, after user configuration, after loading a plugin. It means agent capability is **composable**: an agent with MCP Servers for filesystem, database, email, and calendar is not four separately integrated systems — it is one agent with a runtime-assembled capability set.

An agent that can discover its own capabilities at runtime can also reason about what it *lacks* — and potentially request new capability by requesting a new MCP Server connection. This is the foundation of self-extending agency.

## MCP in the Vulture Nest

Within the Vulture Nest architecture, MCP Servers are the mechanism by which agents access the PoShWiKi database, the vault filesystem, and external knowledge sources. The [[mcp-agent-skills]] pattern uses MCP Servers to package reusable agent capabilities as composable units — a specialization of the general MCP model for agentic knowledge work.

The [[mcp-security]] constraints apply here with particular force: an agent with write access to the vault filesystem has write access to the knowledge base itself. MCP's per-Server capability scoping is the mechanism that keeps this manageable.

## The Standard Model Argument

In physics, the Standard Model doesn't describe all of reality — it describes the fundamental particles and forces from which all observable phenomena are built. MCP makes an analogous claim: Resources, Tools, and Prompts are the fundamental particles from which all agent-to-world capabilities compose.

Whether this claim holds at full scale is an open empirical question. What MCP has already achieved is eliminating the proprietary integration layer: any MCP-compatible Host can use any MCP-compatible Server without custom glue code. The interoperability gain is real, measurable, and compounding — every new MCP Server that is built is available to every MCP-compatible agent, forever.

## See Also
- [[mcp-transport]]
- [[mcp-security]]
- [[mcp-server-development]]
- [[mcp-sdks]]
- [[mcp-agent-skills]]
- [[multi-agent-systems]]
- [[agent-tools]]
