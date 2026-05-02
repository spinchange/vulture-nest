---
title: [[mcp-moc|MCP]] MOC
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-index, model-context-protocol-map]
---
# MCP MOC

This map provides a comprehensive traversal of the Model Context Protocol (MCP) ecosystem, optimized for agentic tool integration and developer reference.

## Fundamentals
* [[mcp-architecture]]: Host, Client, and Server relationship.
* [[mcp-primitives]]: Resources, Prompts, and Tools.
* [[mcp-transport]]: Stdio and HTTP with SSE.
* [[mcp-versioning]]: Protocol evolution and compatibility.

## Building MCP Components
* [[mcp-server-development]]: Creating servers to expose data and tools.
* [[mcp-client-development]]: Integrating MCP support into applications.
* [[mcp-sdks]]: Official libraries for [[python]], [[typescript|TypeScript]], and more.
* [[rust-mcp-patterns]]: Implementation blueprint for [[rust]]-based servers.
* [[mcp-server-features]]: Detailed guide on server capabilities.
* [[mcp-client-features]]: Detailed guide on client-side logic.
* [[lit-mcp-advanced-patterns]] - Progressive discovery, programmatic tool calling, and agent skill patterns.

## Deployment & Security
* [[mcp-local-connections]]: Connecting to local servers via stdio.
* [[mcp-remote-connections]]: Connecting to remote servers via HTTP.
* [[mcp-security]]: Production hardening and trust models.
* [[mcp-authorization]]: Managing permissions and user consent (OAuth 2.1).
* [[lit-chatgpt-web-mcp-guidance]] - Verified ChatGPT web MCP constraints and deployment guidance.
* [[spec-chatgpt-web-mcp-wrapper]] - Remote wrapper design for ChatGPT web access to the vault.
* [[lit-mcp-authorization]] - Literature: MCP Authorization Specification (OAuth 2.1, RFC 9728, audience binding, step-up flow)
* [[lit-mcp-security-best-practices]] - Literature: MCP Security Best Practices (confused deputy, token passthrough, SSRF, session hijacking, scope minimization)

## Operations & Tooling
* [[mcp-debugging]]: Tools and strategies for protocol troubleshooting.
* [[lit-mcp-connections-and-debugging]] - Literature grounding for connection modes and debugging workflow.
* [[mcp-inspector]]: The interactive testing tool for MCP servers.
* [[mcp-best-practices]]: Optimization and security implementation guidelines.

## Examples & Use Cases
* [[mcp-example-servers]]: Reference implementations of MCP servers.
* [[mcp-example-clients]]: Reference implementations of MCP hosts.
* [[lit-mcp-ecosystem-examples]] - Literature grounding for reference clients, servers, and ecosystem implementations.
* [[mcp-agent-skills]]: Using MCP to power autonomous agent behaviors.

---
## See Also
* [[agentic-frameworks-moc]]
* [[hybrid-retrieval-spec]]
- [[community-protocol-trust-substrate]]
* [[agentic-protocols]] - Unified Communication Protocols
* [[mcp-best-practices]] - Context Optimization & Tool Hardening
* [[mcp-authorization]] - Security & Permission Models
* [[lit-mcp-advanced-patterns]] - Host scaling patterns and agent skill scaffolding
* [[lit-mcp-connections-and-debugging]] - Connection lifecycle and debugging reference
* [[lit-mcp-ecosystem-examples]] - Reference clients and servers
* [[lit-mcp-authorization]] - Specification-level grounding for OAuth 2.1 authorization
* [[lit-mcp-security-best-practices]] - Threat model and mitigations (attack-vector level)
