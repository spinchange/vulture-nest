---
title: 'Literature: MCP Architecture Overview'
author: gemini-cli
date: 2026-05-01
status: active
type: literature
aliases:
  - mcp-architecture-source
  - mcp-arch-docs
provenance:
  source_record_ids:
    - "6187a48f-c4b1-43ed-95de-205f4c359987"
  chunk_ids:
    - "272dfbb7-47a1-4aac-909f-46e555080ace"
    - "decf817d-c3f2-494c-b8c0-5fdc76fcbd48"
    - "cae8914e-7c20-406d-ab24-01229fbc8ac8"
    - "44eef166-4f2d-4db5-9b27-8e35d2db43c3"
    - "31dc78eb-1747-4274-ad52-386440c159ff"
    - "a9703018-8513-4e1f-9f4d-a364605f4ff4"
    - "e5b5ecfc-42e3-4d25-a825-b109416b4292"
    - "07afb6eb-2302-4815-95f1-5088b7695764"
    - "1b7351a3-8266-4b5d-a51e-b40c4e17a5c9"
    - "cae65482-ac51-4cf6-9f1c-9034f4fd9472"
  retrieved_at: "2026-05-01T08:56:24Z"
  acting_agent: "gemini-cli"
---

# Literature: MCP Architecture Overview

## Source Metadata
* **File:** `https://modelcontextprotocol.io/docs/concepts/architecture`
* **Origin:** Anthropic Model Context Protocol Documentation
* **Relevance:** Canonical definition of the MCP layers, participants, and lifecycle.

## High-Level Summary
The Model Context Protocol (MCP) is a standard for connecting AI applications to data and tools. It defines a clear separation between the **Data Layer** (JSON-RPC 2.0 primitives) and the **Transport Layer** (how messages are moved).

## Core Concepts

### Participants
* **MCP Host:** The AI application (like Claude Desktop or an IDE) that initiates connections.
* **MCP Client:** Maintains a 1:1 connection with a server, typically embedded within the Host.
* **MCP Server:** Provides tools, resources, and prompts to the client.

### Layers
* **Data Layer:** Defines the semantics of the protocol. It uses JSON-RPC 2.0 to handle tools, resources, prompts, and notifications.
* **Transport Layer:** Handles the underlying communication. Supported transports include **Stdio** (local) and **HTTP with SSE** (remote).

## Lifecycle Management

### The Initialization Exchange
A mandatory handshake occurs when a connection is established:
1. **Initialize Request:** The client sends its protocol version and capabilities.
2. **Initialize Response:** The server responds with its version and capabilities (e.g., whether it supports notifications).
3. **Initialized Notification:** The client confirms it is ready to proceed.

## Primitives and Operations

### Tool Discovery and Execution
* **Discovery:** Clients can list available tools using `tools/list`.
* **Execution:** Clients invoke tools via `tools/call`. The server executes the logic and returns a result.
* **Pseudo-code Flow:** Application finds the right session → calls tool → returns result to conversation.

### Real-time Updates (Notifications)
MCP supports proactive server-to-client notifications.
* **`notifications/tools/list_changed`**: Sent by the server when its tool roster changes.
* **refresh cycle**: Upon receiving a notification, the client typically re-fetches the tool list via `tools/list`.
* **Benefits**: Enables dynamic environments where tools may appear or disappear based on permissions or state.

## Strategic Importance
* **Dynamic Discovery:** Prevents hardcoding tool definitions; the AI application learns capabilities at runtime.
* **Transport Independence:** The same Data Layer logic works over local pipes or web APIs.
* **Standardized Context:** Provides a unified way for LLMs to interact with external systems without custom integrations for every tool.

## References
- [[mcp-moc]]
- [[lit-mcp-architecture]] (prior version)
- [[agentic-protocols]]
