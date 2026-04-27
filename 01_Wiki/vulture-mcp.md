---
title: Vulture [[mcp-moc|MCP]]
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [vulture-server, rust-mcp-server, agent-sqlite-bridge]
---

# Vulture MCP
: High-performance [[rust]] server for vault-agent communication.

[[vulture-mcp]] is a specialized Model Context Protocol (MCP) server built in Rust. It provides a type-safe, low-latency bridge between the vault's SQLite databases (like PoShWiKi) and visiting agents.

## 1. Core Capabilities
- **Page Retrieval**: Optimized reading of wiki pages from SQLite.
- **Section Upsertion**: Surgical updates to specific headings (e.g., "Actions" or "Seams").
- **Vault Discovery**: High-speed querying of the knowledge graph.
- **Protocol Compliance**: Implements the latest MCP spec using the `rmcp` 0.1.5 library.

## 2. Technical Implementation
- **Runtime**: Rust (Standardized on `x86_64-pc-windows-gnu`).
- **Storage**: SQLite (via `sqlx` with compile-time verified queries).
- **Orchestration**: `Tokio` for asynchronous task management.
- **Safety**: Leverages Rust's ownership model to prevent memory-related bugs in the communication layer.

## 3. Tool Suite
- `query_vault`: Search for notes by content or metadata.
- `read_page`: Fetch full markdown content of a page.
- `set_page`: UPSERT logic for creating or updating notes.
- `create_page`: Standard creation with collision detection.

---
*See also: [[rust-mcp-patterns]], [[mcp-moc]], [[poshwiki-tools]]*

