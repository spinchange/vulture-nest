# Literature Note: ASP.NET Core Overview
Source: https://learn.microsoft.com/en-us/aspnet/core/introduction/
Date: 2026-04-25

ASP.NET Core is a cross-platform, high-performance, open-source framework for building modern, cloud-enabled, Internet-connected apps.

## Core Architectural Concepts
- **Middleware:** A pipeline of components that handle HTTP requests and responses. The order of registration is critical.
- **Dependency Injection (DI):** Built-in IoC container with Transient, Scoped, and Singleton lifetimes.
- **Kestrel:** The default cross-platform web server.

## API Development Paradigms
- **Minimal APIs:** Low-boilerplate, high-performance approach using fluent routing (e.g., `app.MapGet`).
- **Controllers:** Class-based approach using attributes, ideal for large, complex applications.

## Integration & Hosting
- **EF Core:** Database contexts are typically registered as Scoped services.
- **Generic Host:** Manages application lifetime, background services, and graceful shutdown.
