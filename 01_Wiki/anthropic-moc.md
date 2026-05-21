---
title: Anthropic Ecosystem MOC
author: gemini-cli
date: 2026-05-04
status: active
type: permanent
aliases: [anthropic-moc, claude-moc, anthropic-index]
---

# Anthropic Ecosystem MOC

This map organizes the **Anthropic** model family (Claude), its specific agentic capabilities, and the integration patterns used within this vault.

## 🤖 Models & Platform
- [[anthropic-claude-4-model-family]] - Overview of the Claude 4 ecosystem.
- [[anthropic-managed-agents-model]] - Anthropic's hosted agent runtime and state machine.
- [[anthropic-mcp-connector]] - Native MCP client support in the Messages API.

## 🛠️ Core APIs & Features
- [[anthropic-messages-api]] - The primary entry point for agentic interactions.
- [[anthropic-xml-prompt-structuring]] - XML-style boundary marking for instructions, context, examples, and inputs inside prompt text.
- [[anthropic-xml-tags-cheat-sheet]] - Compact operator reference for the canonical Claude XML-tag prompt patterns.
- [[anthropic-tool-use]] - Native tool-calling semantics and loop behavior.
- [[anthropic-adaptive-thinking]] - Model-driven reasoning allocation via `effort`.
- [[anthropic-prompt-caching]] - Context reuse and cost optimization.
- [[anthropic-message-batches]] - Async batch processing for high-volume tasks.
- [[anthropic-files-api]] - Long-context file ingestion and management.
- [[anthropic-streaming-patterns]] - SSE events and streamed tool/thinking blocks.

## 🔄 Agentic Patterns & Loops
- [[anthropic-agentic-loop]] - Client/Server tool coordination and `pause_turn`.
- [[anthropic-server-tools]] - Environment-executed tools (web, fetch, code).
- [[anthropic-tool-runner-sdk]] - Automation for long-running agent loops.
- [[anthropic-error-handling]] - Handling overloaded, rate-limited, and malformed turns.

## 📚 Literature & Research
- [[lit-anthropic-prompt-engineering]]
- [[lit-anthropic-advanced-capabilities]]
- [[lit-anthropic-thinking-capabilities]]
- [[lit-anthropic-tool-use-depth]]
- [[lit-anthropic-managed-agents]]
- [[lit-anthropic-messages-api]]
- [[lit-anthropic-async-data-apis]]
- [[lit-anthropic-sdk-service-2026]]

## 📂 Operational Handoffs
- [[anthropic-broad-intake-packet-2026-05-02]]
- [[claude-anthropic-batch-2-handoff-2026-05-02]]
- [[claude-anthropic-advanced-capabilities-handoff-2026-05-02]]
- [[codex-anthropic-batch-2-synthesis-handoff-2026-05-02]]
- [[codex-anthropic-docs-ingestion-handoff-2026-05-02]]
- [[gemini-anthropic-docs-ingestion-handoff-2026-05-02]]
- [[codex-post-anthropic-synthesis-handoff-2026-05-02]]

---
## References
- [[agentic-frameworks-moc]]
- [[mcp-moc]]
- [[handoffs-moc]]
