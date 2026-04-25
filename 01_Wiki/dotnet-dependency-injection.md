---
title: .NET Dependency Injection
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [dotnet-di, service-provider, generic-host]
---
# .NET Dependency Injection

**Dependency Injection (DI)** is a first-class citizen in the .NET ecosystem, particularly since the introduction of the **Generic Host**. It is a design pattern used to achieve **Inversion of Control (IoC)** between classes and their dependencies.

## Core Concepts

### 1. Service Collection
The container where services are registered during application startup.
```csharp
var builder = Host.CreateApplicationBuilder(args);
builder.Services.AddSingleton<IMyService, MyService>();
```

### 2. Service Provider
The object that resolves and provides instances of registered services.

### 3. Service Lifetimes
- **Transient:** A new instance is created every time it is requested.
- **Scoped:** A new instance is created once per client request (within a scope).
- **Singleton:** A single instance is created the first time it is requested and used by all subsequent requests.

## The Generic Host
Modern .NET applications (Console, Web, Worker) use the **Generic Host** to manage application lifetime, configuration, logging, and DI.
- **Background Services:** Classes that inherit from `BackgroundService` can be registered to run long-running tasks.

## Why it Matters for Agents
DI is essential for building modular agentic frameworks:
- **Mocking:** Easily swap a live `ILLMService` with a mock during testing.
- **Configuration:** Inject agent settings (API keys, model names) into the classes that need them.
- **Extensibility:** Allow users to register custom "Skills" or "Tools" that the agent can then resolve via DI.

---
## References
- [[ms-learn-dotnet-fundamentals]] (Source)
- [[dotnet-moc]]
- [[agent-development-kit]]
