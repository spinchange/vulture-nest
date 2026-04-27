---
title: 'Literature: TypeScript Handbook'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: literature
aliases:
  - typescript-handbook-source
  - typescript-docs
---

# Literature: TypeScript Handbook

## Source Metadata
*   **File:** `00_Raw/typescript-handbook.md`
*   **Origin:** [typescriptlang.org/docs/handbook](https://www.typescriptlang.org/docs/handbook/intro.html), crawled 2026-04-24
*   **Domain:** programming / type systems
*   **Relevance:** TypeScript is the primary language for MCP SDKs, ADK TypeScript client, and agent tool schemas across the vault.

## High-Level Summary
The TypeScript Handbook is the canonical reference for TypeScript's progressive type system layered over JavaScript. It covers the full spectrum from basic type annotations through advanced structural and algebraic type manipulation. The key insight is that TypeScript's type system is *structural* (not nominal), making it highly composable for describing complex protocol shapes like MCP schemas and A2A Agent Cards.

## Key Concepts Identified

### Everyday Types
*   Primitive types (`string`, `number`, `boolean`), arrays, tuples, `any`, `unknown`, `never`.
*   Union (`A | B`) and intersection (`A & B`) types — the algebraic foundation for discriminated unions (e.g., A2A's `Part` type).
*   Literal types and type narrowing via `typeof`, `instanceof`, and discriminant fields.

### Type Manipulation
*   **Generics:** Parameterized types for reusable containers (`Tool<TInput, TOutput>`).
*   **Conditional Types:** `T extends U ? X : Y` — enables compile-time type routing.
*   **Mapped Types:** Transform all keys of an object type (`Partial<T>`, `Readonly<T>`).
*   **Template Literal Types:** String pattern matching at the type level.
*   **`keyof` / `typeof`:** Reflection operators that bridge values and types.
*   **Indexed Access Types:** `T[K]` — extract the type of a property by key.

### Classes and Modules
*   Classes with access modifiers (`private`, `protected`, `readonly`).
*   ES module system (`import`/`export`) with declaration merging for ambient types.

### Reference Features
*   **Decorators:** Metadata annotations (relevant to NestJS/MCP server patterns).
*   **Utility Types:** `Partial`, `Required`, `Pick`, `Omit`, `Record`, `ReturnType`, `Parameters`.
*   **Declaration Merging:** Allows extending third-party types without forking.

## Architectural Themes
1.  **Structural Typing Over Nominal:** Any object matching a shape satisfies the interface — enables loose coupling across agent boundaries.
2.  **Discriminated Unions as Protocol Primitives:** The `kind` field pattern (e.g., `{ kind: "text", text: string } | { kind: "file", url: string }`) directly models MCP content blocks and A2A Parts.
3.  **Type Inference:** TypeScript infers return types, reducing annotation burden while maintaining safety.

## Connections to Vault
*   [[javascript-moc]] — runtime context for TypeScript
*   [[csharp-mcp-sdk]] — C# analog for type-safe protocol modeling
*   [[a2a-protocol]] — Part discriminated union directly mirrors TS union patterns
*   [[mcp-moc]] — MCP TypeScript SDK uses these patterns throughout

## Next Steps for Synthesis
*   Create a permanent note on **Discriminated Unions as Agent Protocol Primitives**.
*   Map TypeScript utility types to C# record pattern equivalents (see [[csharp-records]]).
*   Explore how Template Literal Types can encode MCP method names at the type level.

## Related
- [[typescript-everyday-types]]
