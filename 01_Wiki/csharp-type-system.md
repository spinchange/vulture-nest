---
title: C# Unified Type System
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [csharp-types, value-vs-reference]
---
# C# Unified Type System

The **C# Unified Type System** is a foundational architectural choice where every type, whether a primitive (like `int`) or a complex class, ultimately inherits from the `System.Object` root.

## Type Categories

### 1. Value Types
- **Storage:** Allocated on the stack.
- **Behavior:** Copied by value.
- **Examples:** `struct`, `enum`, `int`, `bool`, `double`.
- **Memory:** Efficient, but can lead to "boxing" when treated as an object.

### 2. Reference Types
- **Storage:** Allocated on the managed heap; the variable holds a reference (pointer) to the memory location.
- **Behavior:** Copied by reference.
- **Examples:** `class`, `interface`, `delegate`, `string`, `dynamic`.
- **Memory:** Managed by the **Garbage Collector (GC)**.

## Boxing and Unboxing
- **Boxing:** The process of converting a value type to a reference type (e.g., `int` to `object`). This incurs a performance penalty as it requires a heap allocation.
- **Unboxing:** The explicit conversion from a reference type back to a value type.

## Significance for Agents
When building high-performance tools for agents, understanding the type system is critical for:
- Optimizing memory usage in data-heavy loops.
- Ensuring type safety when passing data between the agent and the host system.
- Leveraging `records` for immutable, value-based comparison of agent states.

---
## References
- [[ms-learn-csharp-overview]] (Source)
- [[csharp-moc]]
- [[dotnet-clr-internals]]
