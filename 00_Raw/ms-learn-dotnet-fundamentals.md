# Literature Note: .NET Platform Fundamentals
Source: https://learn.microsoft.com/en-us/dotnet/fundamentals/
Date: 2026-04-25

.NET is an open-source developer platform for building cross-platform applications.

## Core Architectural Concepts
- **Common Language Runtime (CLR):** The execution engine that handles exceptions, garbage collection, and JIT (Just-In-Time) compilation.
- **Intermediate Language (IL):** A CPU-independent instruction set that allows multiple languages (C#, F#, VB) to run on the same runtime.
- **Dependency Injection (DI):** A first-class citizen in the .NET ecosystem for managing object lifetimes and decoupling components.
- **Generic Host:** A standardized way to manage application startup, lifetime, and background services.

## Key Features
- **Base Class Library (BCL):** A comprehensive set of standard libraries for I/O, networking, serialization, and more.
- **Configuration & Logging:** Extensible systems for managing app settings and diagnostic telemetry.
- **NuGet Ecosystem:** A modular package management system for sharing and consuming code.

## Fundamental Paradigms
- **Cross-Platform:** "Write once, run anywhere" across Windows, Linux, and macOS.
- **Modular Design:** High performance through a "pay-for-what-you-use" library approach.
