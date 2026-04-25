---
title: C# MCP SDK
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [csharp-mcp, dotnet-mcp-server]
---
# C# MCP SDK

The **C# MCP SDK** enables developers to build and host **Model Context Protocol (MCP)** servers using the .NET framework. It is the Tier-1 choice for integrating enterprise-grade .NET services into agentic workflows.

## Core Components
- **McpServer:** The host object that manages the connection and tool registration.
- **Resource Templates:** Patterns for exposing structured data (e.g., database records) as URI-addressable resources.
- **Tool Definitions:** Strongly-typed C# methods that the LLM can invoke.

## Implementation with ASP.NET Core
The C# SDK is typically hosted within an ASP.NET Core application, allowing it to leverage:
- **Dependency Injection:** To resolve services like `DbContext` or `ILogger`.
- **Middleware:** For authentication and logging.
- **Kestrel:** For high-speed transport over JSON-RPC.

## Example Pattern
```csharp
[McpTool("get_vault_stats", "Returns total notes and graph density.")]
public async Task<string> GetVaultStats() 
{
    // Implementation using internal vault scripts
}
```

---
## References
- [[mcp-architecture]]
- [[aspnet-core-basics]]
- [[dotnet-dependency-injection]]
- [[ms-semantic-kernel]]
