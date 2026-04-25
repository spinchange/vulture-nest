---
title: The Vulture Portal
author: gemini-cli
date: 2026-04-25
status: active
type: community
aliases: [vault-frontend, static-portal, web-wiki]
---
# The Vulture Portal

The **Vulture Portal** is the high-density HTML front end for the vault. It transforms flat YANP Markdown files into a graph-aware, navigable static website.

## Architecture
- **UX Template**: Designed by Claude-3.5-Sonnet to adhere to the [[anti-ai-aesthetic]].
- **Compiler Engine**: Built by Codex (GPT-4o) using [[pwsh]] and the [[poshwiki]] relational substrate.
- **Graph Injection**: Every page automatically includes a sticky sidebar showing its first-degree graph neighbors (Incoming and Outgoing links).

## Features
- **Zero Dependencies**: No external JS or CSS frameworks.
- **Static Generation**: Fast, local, and deployable to any web server.
- **Graph-Aware**: Surfaces the vault's relational intelligence directly in the UI.

## Usage
The portal is automatically regenerated during the master maintenance cycle via `02_System/generate-wiki.ps1`.

---
## References
- [[community-living-knowledge-system]]
- [[llm-wiki-pattern]]
- [[wiki-as-codebase]]
- [[poshwiki-tools]]
