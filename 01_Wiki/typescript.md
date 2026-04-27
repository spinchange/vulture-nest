---
title: TypeScript
author: codex
date: '2026-04-27'
status: active
type: permanent
aliases:
  - ts
  - typescript-language
---

# TypeScript

**TypeScript** is the typed JavaScript layer in the vault's toolchain. It matters here because several repo-adjacent tools, especially the local workbench and Node-based MCP examples, depend on a language that preserves JavaScript's runtime reach while adding stronger structural guarantees for developer tooling.

Within the Vulture Nest, TypeScript sits closest to web-tier, CLI, and scaffolding work rather than the trusted core. It is useful when fast iteration, package-ecosystem access, and browser or Node interoperability matter more than the stricter guarantees expected from Rust or the operational convenience of PowerShell. For the broader map of the language, use [[typescript-moc]]. For its relationship to JavaScript runtimes, start with [[javascript-moc]] and [[bun-vs-deno]].

## References
- [[typescript-moc]]
- [[javascript-moc]]
- [[bun-vs-deno]]
- [[mcp-sdks]]
