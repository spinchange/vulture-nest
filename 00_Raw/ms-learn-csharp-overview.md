# Literature Note: C# Language Architecture & Paradigms
Source: https://learn.microsoft.com/en-us/dotnet/csharp/
Date: 2026-04-25

C# is a modern, object-oriented, and type-safe programming language that runs on the .NET runtime.

## Core Architectural Concepts
- **Unified Type System:** All types, including primitives, inherit from a single `object` root.
- **Memory Management:** Automatic garbage collection and the distinction between value types (stack) and reference types (heap).
- **Compiler Platform (Roslyn):** An open-source API-driven compiler that enables rich code analysis and refactoring tools.

## Key Features
- **LINQ (Language Integrated Query):** First-class query capabilities for various data sources (collections, SQL, XML).
- **Asynchronous Programming:** The `async` and `await` pattern for non-blocking operations.
- **Pattern Matching:** Advanced syntax for testing expressions and extracting data.
- **Records:** Concise syntax for immutable data-centric types.

## Fundamental Paradigms
- **Multi-paradigm:** Supports imperative, declarative, functional, and object-oriented programming.
- **Strong Typing:** Compile-time type checking to ensure code safety.
