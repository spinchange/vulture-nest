---
title: MCP Architecture
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-model, mcp-layers, mcp-lifecycle]
---
# MCP Architecture

The **Model Context Protocol (MCP)** follows a structured, layered architecture designed for interoperability between AI applications and external systems.

## Participants
*   **MCP Host:** The main AI application (e.g., Claude Desktop, VS Code) that users interact with. It coordinates multiple MCP clients.
*   **MCP Client:** A protocol-level component within the Host that maintains a dedicated connection to a single MCP Server.
*   **MCP Server:** A lightweight program that exposes specific data (Resources), actions (Tools), or templates (Prompts).

## Protocol Layers
1.  **Data Layer (Inner):** Implements the JSON-RPC 2.0 based exchange protocol. It handles lifecycle management and core primitives.
2.  **Transport Layer (Outer):** Manages the communication channel (Stdio or HTTP/SSE) and authentication.

## Lifecycle Management
MCP is a **stateful protocol**. The connection follows a specific sequence:
1.  **Initialize:** Capability negotiation (versions, features supported).
2.  **Notifications:** The client sends a "notifications/initialized" message.
3.  **Dynamic Updates:** Servers can send "list_changed" notifications (e.g., `notifications/tools/list_changed`) to trigger client refreshes.

## See Also
* [[mcp-primitives]]
* [[mcp-transport]]
* [[agentic-protocols]]
