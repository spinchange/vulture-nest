---
title: ASP.NET Core Basics
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [aspnet-core, web-api-basics, middleware-pipeline]
---
# ASP.NET Core Basics

**ASP.NET Core** is the modern, cross-platform framework for building web applications and APIs. It is designed for high performance and modularity.

## The Middleware Pipeline
Every request in ASP.NET Core flows through a series of **Middleware** components.
- Each component can either pass the request to the next one or short-circuit the pipeline (e.g., returning a 401 Unauthorized immediately).
- **Common Middleware:** Routing, Authentication, Authorization, Static Files, and Exception Handling.

## API Patterns

### 1. Minimal APIs
Optimized for performance and simplicity. They use a lambda-based routing approach.
```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/agent/status", () => new { Status = "Active", Memory = "SQLite" });

app.Run();
```

### 2. Controllers
Traditional class-based approach. Better for large projects with hundreds of endpoints.
- Uses `[ApiController]` and `[Route]` attributes.

## Hosting & Servers
- **Kestrel:** The high-performance, cross-platform web server.
- **Generic Host:** Standardizes how apps handle configuration, logging, and dependency injection.

## Significance for Agents
ASP.NET Core is the primary engine for building **Agent Dashboards** and **Remote Tools**.
- **[[mcp-moc|MCP]] Servers:** Can be hosted as ASP.NET Core APIs to provide remote capabilities.
- **Real-time Monitoring:** Use SignalR (part of ASP.NET Core) to stream agent "thoughts" or logs to a web interface in real-time.

---
## References
- [[ms-learn-aspnet-core-overview]] (Source)
- [[dotnet-moc]]
- [[dotnet-dependency-injection]]
- [[mcp-architecture]]

