---
title: Wiki Expansion Opportunities (2026-05-02)
author: gemini-cli
date: '2026-05-02'
status: active
type: fleeting
aliases:
  - wiki-expansion-plan
  - expansion-opportunities
---

# Wiki Expansion Opportunities

This note outlines the prioritized expansion lanes for the Vulture Nest wiki, based on graph centrality, node "thinness" (word count vs. incoming links), and available raw source material.

## Verified Gaps

The following nodes are structurally central but currently contain minimal content (< 300 words):

- **High Centrality Hubs:**
	- `[[rust]]` (61 incoming links, 227 words)
	- `[[agent-development-kit]]` (59 incoming links, 245 words)
	- `[[python]]` (55 incoming links, 225 words)
	- `[[powershell]]` (32 incoming links, 135 words)
	- `[[typescript]]` (31 incoming links, 138 words)
	- `[[mcp-best-practices]]` (27 incoming links, 104 words)
- **Weak Navigational MOCs:**
	- `[[programming-languages-moc]]` (24 incoming, 168 words)
	- `[[javascript-moc]]` (10 incoming, 88 words)
	- `[[pkm-history-moc]]` (6 incoming, 80 words)
	- `[[wpf-moc]]` (8 incoming, 115 words)
	- `[[multi-agent-patterns-moc]]` (6 incoming, 160 words)

## Ranked Expansion Lanes

### 1. Agent Framework Depth (ADK Focus)
- **Leverage:** The ADK is the primary toolkit for this vault's agentic workflows. It has high centrality but remains a surface-level summary.
- **Problem:** Thin hub note + incomplete source synthesis.
- **Candidates:** `[[agent-development-kit]]`, `[[agent-thought-cycle]]`, `[[agent-tools]]`, `[[graph-orchestration]]`.
- **Strategy:** Deepen existing notes and create sub-concept permanents (e.g., Session Service, Artifact Service).
- **Source:** `00_Raw/adk-documentation.md` (2.7 MB rich corpus).

### 2. MCP Ecosystem Synthesis
- **Leverage:** MCP is the foundational protocol for tool-use in this vault. The raw corpus is extensive but barely synthesized.
- **Problem:** Incomplete source-to-literature-to-permanent conversion.
- **Candidates:** `[[mcp-best-practices]]`, `[[mcp-authorization]]`, `[[mcp-primitives]]`, `[[mcp-sdks]]`, `[[mcp-security]]`.
- **Strategy:** Create a bounded cluster for MCP operations and security.
- **Source:** `00_Raw/mcp/` directory (18+ guide files).

### 3. Core Language Hardening (Rust & Python)
- **Leverage:** Rust and Python are the two most linked-to notes in the vault, yet both are stubs.
- **Problem:** Thin central hubs.
- **Candidates:** `[[rust]]`, `[[python]]`, `[[powershell]]`, `[[typescript]]`.
- **Strategy:** Harden the root notes to provide architectural context (e.g., Rust ownership vs. Python async).
- **Source:** `00_Raw/the-rust-programming-language.md`, `00_Raw/typescript-handbook.md`, `00_Raw/python-summary.md`.

### 4. Anthropic Advanced Capabilities
- **Leverage:** Newly ingested Anthropic docs provide cutting-edge agent patterns (extended thinking, batching) not yet in the wiki.
- **Problem:** Missing bridge notes / Source synthesis.
- **Candidates:** `[[anthropic-messages-api]]`, `[[anthropic-streaming-patterns]]`, `[[anthropic-prompt-caching]]`.
- **Strategy:** Create new permanent notes for advanced API features.
- **Source:** `00_Raw/anthropic/` directory.

### 5. Navigational Hub Restoration
- **Leverage:** Navigation is brittle; many MOCs are just lists without "wayfinding" text.
- **Problem:** Weak MOC / navigation layer.
- **Candidates:** `[[javascript-moc]]`, `[[pkm-history-moc]]`, `[[wpf-moc]]`, `[[multi-agent-patterns-moc]]`.
- **Strategy:** Restructure MOCs to include category definitions and narrative transitions.

## Recommended Immediate Batch

**Batch Name:** "Core Protocol & Framework Depth"
**Focus:** Depth-first hardening of the two most critical infrastructure hubs.

1. **ADK Hardening:** Deepen `[[agent-development-kit]]` and synthesize core sub-services from `00_Raw/adk-documentation.md`.
2. **MCP Synthesis:** Expand `[[mcp-best-practices]]` and `[[mcp-authorization]]` using the `00_Raw/mcp/` corpus.

## Deferred Lanes
- **Language Hardening:** Deferred until the primary agentic frameworks (ADK/MCP) are stable.
- **Navigational Hubs:** Deferred until the underlying content notes are fleshed out enough to warrant better navigation.

## Stop Condition Check
- [x] Planning note exists.
- [x] Contains ranked expansion plan grounded in evidence.
- [x] One immediate next batch recommended.
