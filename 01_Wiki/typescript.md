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

Within the Vulture Nest, TypeScript sits closest to web-tier, CLI, and scaffolding work rather than the trusted core. It is useful when fast iteration, package-ecosystem access, and browser or Node interoperability matter more than the stricter guarantees expected from Rust or the operational convenience of PowerShell.

The reason it matters beyond "typed JavaScript" is the type system's structural model. Tool schemas, client contracts, and MCP-facing helpers often care more about the shape of data than about nominal class hierarchies, and TypeScript is built around describing and refining those shapes. That makes it a good fit for SDK-driven integration work and a weaker fit for trust-boundary enforcement.

## Core Opinion

TypeScript is the Nest's default language when the work needs JavaScript ecosystem reach but should not stay untyped. Its real role is not "frontend language"; it is the typed integration layer for Node, browser, CLI, and MCP-adjacent tooling where structural contracts matter more than ownership or nominal class design.

The practical split is:

- use **TypeScript** when you need browser or Node reach, package-ecosystem leverage, or schema-shaped integration work with better guarantees than plain JavaScript
- use **[[powershell]]** when the same task is primarily repo-local operations and shell automation
- use **[[python]]** when the work is mostly agent orchestration, provider SDK integration, or async application glue
- use **[[rust]]** when the concern is trust-boundary hardening rather than ergonomic integration

## Decision Rule

Start from `[[typescript]]` when your question sounds like one of these:

- "Which language should own this Node or browser-facing integration?"
- "How do I model API or tool contracts by data shape?"
- "Which TypeScript note explains the type-system feature behind this SDK pattern?"
- "Where do I start for MCP examples, client code, or JS-runtime-adjacent tooling?"

If the question is instead about repo maintenance, route to [[powershell]]. If it is about agent loops or Python-first SDKs, route to [[python]]. If it is about enforcing invariants at the boundary itself, route to [[rust]].

## TypeScript in the Nest

TypeScript appears here in two main roles:

**Typed integration layer.** When the Nest needs browser or Node reach, package-ecosystem access, or SDK examples that live in the JavaScript world, TypeScript is the safest default. The MCP ecosystem especially treats TypeScript as a first-class language, with the official SDK and many examples assuming its type-driven workflow.

**Scaffolding and web-tier language.** TypeScript is where web-facing prototypes, CLI glue, and example clients are easiest to build quickly. It is adjacent to the main architecture, not the trusted center of it.

## Reading the Cluster

The TypeScript cluster is easiest to navigate in two tracks: the language handbook path and the applied integration path.

### Track 1 — Handbook Fundamentals

Start here if you are coming from Rust or Python and need a clean path into TypeScript's model.

- **[[typescript-basics]]** — the entry point: primitive types, annotations, and gradual typing.
- **[[typescript-everyday-types]]** — unions, aliases, interfaces, and the shapes you will use constantly.
- **[[typescript-narrowing]]** — how control flow refines types; one of the most important practical ideas in the language.
- **[[typescript-functions]]** and **[[typescript-objects]]** — how callable and object-shaped APIs are described.
- **[[typescript-generics]]** — the gateway to reusable, schema-heavy abstractions.
- **[[typescript-type-operators]]**, **[[typescript-conditional-types]]**, **[[typescript-mapped-types]]**, **[[typescript-template-literals]]** — the type manipulation layer for advanced library and tool design.
- **[[typescript-utility-types]]**, **[[typescript-modules]]**, **[[typescript-compiler-options]]**, **[[typescript-classes]]** — reference notes for everyday project structure and built-in helpers.
- **[[typescript-moc]]** — full handbook-oriented map of the cluster.

### Track 2 — Applied Tooling and MCP Work

Start here if you are using TypeScript to build or understand integrations rather than to study the language in isolation.

- **[[mcp-sdks]]** — TypeScript is a Tier-1 MCP SDK language; this is the highest-signal application note.
- **[[mcp-client-development]]** — how the TypeScript client model is structured in practice.
- **[[mcp-example-servers]]** and **[[mcp-example-clients]]** — concrete entry points for protocol-shaped code.
- **[[javascript-moc]]** and **[[bun-vs-deno]]** — runtime context when choosing the surrounding JavaScript environment.

## Start Here

Choose the shortest path based on the work:

1. If you need general language fluency, start with [[typescript-basics]], then [[typescript-everyday-types]], then [[typescript-narrowing]].
2. If you are trying to understand SDK or MCP code, start with [[mcp-sdks]] and [[mcp-client-development]], then backfill [[typescript-generics]] and [[typescript-type-operators]].
3. If you are coming from Rust or Python, read [[typescript-objects]], [[typescript-narrowing]], and [[typescript-generics]] before worrying about advanced type metaprogramming.
4. If the runtime decision itself is unclear, route through [[javascript-moc]] and [[bun-vs-deno]] before picking the surrounding stack.

## Relationship to the Rest of the Vault

- [[programming-languages-moc]] places TypeScript in the integration and web-tier lane beside PowerShell's operations role, Python's orchestration role, and Rust's trust-boundary role.
- [[typescript-moc]] is the broader handbook-oriented map once you know whether you need fundamentals, type manipulation, or applied integration context.
- [[javascript-moc]] is the next stop when the question is more about runtime choice or the wider JS ecosystem than about TypeScript itself.

## Where to Start

If you are new to TypeScript in this vault:

1. Read [[typescript-basics]].
2. Then read [[typescript-everyday-types]] and [[typescript-narrowing]].
3. Then read [[typescript-functions]] and [[typescript-objects]] before moving into generics.

If you are approaching TypeScript as a Rust or Python developer, the biggest adjustment is that TypeScript proves compatibility by data shape rather than by ownership or nominal inheritance. Read [[typescript-objects]], [[typescript-narrowing]], and [[typescript-generics]] with that in mind.

If your goal is MCP or SDK integration work specifically, start with [[mcp-sdks]], then [[mcp-client-development]], then return to [[typescript-generics]] and [[typescript-type-operators]] when the schema layer becomes opaque.

## See Also
- [[typescript-moc]]
- [[javascript-moc]]
- [[bun-vs-deno]]
- [[mcp-sdks]]
- [[programming-languages-moc]]
