---
title: Programming Languages MOC
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [languages-hub, dev-environments]
---
# Programming Languages MOC

This map organizes the programming environments used across the vault by architectural role, not just by language family. The high-value question here is usually not "which language exists?" but "which layer of the Nest am I working in?"

Use this map as a routing surface:

- If you are working near the trust boundary, start in [[rust]] and [[rust-moc]].
- If you are wiring SDKs, MCP servers, or ingestion logic, start in [[python]] and [[python-moc]].
- If you are operating the vault itself, start in [[powershell]] and [[powershell-moc]].
- If you need browser, Node, or SDK-adjacent integration work, start in [[typescript]] and [[javascript-moc]].

## Object-Oriented & Enterprise
This lane covers languages and runtimes used for large application structure, typed service design, and desktop or enterprise-facing integration.

* [[dotnet-moc]]: The Microsoft ecosystem and cross-platform runtimes.
* [[csharp-moc]]: High-performance, type-safe development.
* [[python-moc]]: The [[python]] foundation for agent runtimes, typing, and standard-library workflows.

## Web & Desktop Runtimes
This lane is for environments where package-ecosystem reach, browser compatibility, or desktop-web hybrids matter more than strict trust-boundary guarantees.

* [[javascript-moc]]: JS/TS ecosystems, Bun, Deno, and Tauri.
* [[typescript-moc]]: Type-safe development in the JavaScript ecosystem.
* [[wpf-moc]]: Windows-native desktop UI patterns when the Nest needs a .NET front end.

## Functional & Meta-Programming
This lane holds languages that matter more as conceptual or design influences than as day-to-day implementation defaults.

* [[racket]]: Language-oriented programming and the Lisp heritage.

## Systems & Safety
This is the strongest route when the concern is memory safety, protocol invariants, concurrency, or type-level enforcement.

* [[rust]]: Performance, safety, and modern systems programming.
* [[rust-ownership]]: The core memory management model.
* [[rust-mcp-patterns]]: Applied Rust for MCP server design.

## Automation & Shell
This lane is for operational glue: vault maintenance, scriptable workflows, and terminal-native execution.

* [[powershell-moc]]: Automation, objects, and vault maintenance.
* [[ps-automation-spec]]: The standard for agent-runnable system scripts.

## Comparative PKM
This lane is for knowledge-work environments that matter as reference points for how the vault is designed.

* [[org-mode]]: Plain-text logic and Emacs Lisp.

## Debates & Paradigms
These notes are for choosing tradeoffs rather than learning one language in isolation.

* [[type-safety-spectrum-debate]]: The trade-offs between static and dynamic typing.

## Where To Start

If you are arriving cold:

1. Start with [[rust]], [[python]], [[powershell]], and [[typescript]] for the vault-local role of each language.
2. Then drop into the relevant MOC for cluster navigation.
3. Use [[wiki-as-codebase]] if the question is architectural rather than language-specific.

---
## See Also
* [[wiki-as-codebase]]
* [[javascript-on-desktop]]
* [[python]]

