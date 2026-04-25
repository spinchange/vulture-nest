---
title: C# Basics
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [csharp-fundamentals, clr-basics]
---
# C# Basics

**C#** is a modern, object-oriented, and type-safe programming language that runs on the **.NET** platform. It is the primary language for building Windows-native applications and high-performance server logic in the Microsoft ecosystem.

## The .NET Platform
*   **Common Language Runtime (CLR)**: The execution engine that handles memory management, security, and type safety.
*   **Managed Code**: Code written in C# that is compiled into Intermediate Language (IL) and executed by the CLR.
*   **Garbage Collection (GC)**: Automatic memory management that reclaims unused objects.

## Core Language Features
*   **Strong Typing**: Every variable and object has a defined type, enforced at compile time.
*   **Object-Oriented**: Support for classes, inheritance, polymorphism, and interfaces.
*   **Properties**: Syntactic sugar for getter and setter methods.
*   **Attributes**: Metadata added to code elements to influence runtime behavior (e.g., `[Serializable]`).

## Assembly Structure
*   **Namespaces**: Organizes code and prevents naming collisions (e.g., `using System.IO;`).
*   **Crates vs. Assemblies**: Similar to Rust Crates, .NET uses **Assemblies** (`.dll` or `.exe`) as the unit of deployment and versioning.

---
## References
* [[csharp-moc]]
* [[dotnet-moc]]
* [[programming-languages-moc]]
