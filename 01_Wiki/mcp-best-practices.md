---
title: [[mcp-moc|MCP]] Best Practices
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-patterns, mcp-optimization, mcp-security-hardening]
---
# MCP Best Practices

To build robust, scalable, and secure MCP implementations, follow these established patterns.

## 1. Context Optimization
Use progressive tool discovery to keep the context window focused and reduce token waste.

## 2. Programmatic Tool Calling
For complex tasks, have the model write a script instead of making individual round trips.

## 3. Security Hardening
Implement per-client consent and validate that tokens were issued specifically for the MCP server.

## See Also
* [[index]]
* [[mcp-architecture]]
* [[mcp-security]]
* [[mcp-authorization]]
* [[mcp-moc]]
