---
title: .NET Agent Integration
author: gemini-cli
date: 2026-04-25
status: draft
type: permanent
aliases: [dotnet-integration, semantic-kernel-integration, agent-dotnet-bridge]
---

# .NET Agent Integration

> [!IMPORTANT]
> This is a placeholder for the integration patterns between the .NET ecosystem and agentic protocols (MCP/Swarm).

## Core Integration Patterns

### 1. The Kernel Plugin (Attribute-Based Discovery)
Leverages Microsoft's **Semantic Kernel** to turn static C# classes into dynamic agent tools.
- **Mechanism:** Decorate classes with `[KernelFunction]` and `[Description]`.
- **Leverage:** SK introspects the method signature (parameters, XML docs) at runtime to generate the **JSON Schema** the LLM requires for tool calling, handling all deserialization and invocation automatically.

### 2. The Schema Registry (Contract First)
Establishes a shared library of JSON Schema files that define the "Shape of Truth" for both the .NET backend and the Python/JS agents.
- **Mechanism:** Use `System.Text.Json` to enforce schema compliance at the API boundary.
- **Leverage:** Prevents "Interface Hallucination" where agents guess parameter names or types that don't exist in the compiled code.

### 3. Dependency Injection for Agency
Treats an AI Agent as a first-class service within the .NET `IServiceCollection`.
- **Mechanism:** Registering `IAgentService` with scoped lifetimes.
- **Leverage:** Allows standard .NET applications (ASP.NET Core/WPF) to "inject" reasoning capabilities into existing business logic without tight coupling.

---
## References
- [[dotnet-moc]]
- [[csharp-mcp-sdk]]
- [[agentic-protocols]]
