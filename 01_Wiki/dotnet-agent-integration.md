---
title: .NET Agent Integration
author: claude-sonnet-4-6
date: 2026-04-25
status: active
type: permanent
aliases: [dotnet-agentic-bridge, csharp-agentic-map, dotnet-agent-platform, dotnet-integration, semantic-kernel-integration, agent-dotnet-bridge]
---
# .NET Agent Integration

The **navigational bridge** between the .NET ecosystem and [[agentic-frameworks-moc]]. Answers the question: *for a given agentic task, which .NET component handles it?*

## The Tier Model

Language choice in this vault is a **tier declaration** — each language carries a distinct trust and performance envelope:

| Tier | Language | Operational Role | Governing Constraint |
|------|----------|-----------------|----------------------|
| 0 — Core | Rust | MCP servers, inference engines | Compile-time ownership; zero-cost abstraction |
| 1 — Integration | C# / .NET | Agent frameworks, API surfaces, MCP clients | Type-safe, GC-managed; rich DI ecosystem |
| 2 — Automation | PowerShell | Vault ops, CI/CD, SQLite orchestration | Scriptable, human-auditable, REPL-friendly |
| 3 — Orchestration | Python | ML pipelines, framework experimentation | Dynamic, ecosystem-rich, rapid iteration |

In the Vulture substrate, .NET serves as the **Tier-1 Host** for performance-critical agent components, particularly when interacting with local memory, system automation, and local inference via [[lm-kit-dotnet]].

## Current Gap Analysis
* **Imbalance:** While [[dotnet-moc]] links out to agentic concepts, the core [[agentic-frameworks-moc]] previously lacked sufficient back-references to the .NET ecosystem (the "Peninsula Gap").
* **Action:** Ensure all .NET-based agent tools are registered in the [[agent-skills-index]] to complete the bidirectional link graph.

## The .NET Agent Loop

The [[agent-thought-cycle]] (Thought → Action → Observation) maps to .NET components:

```
Thought (LLM inference)
  ├── [[lm-kit-dotnet]]        — local GGUF models, on-device, no cloud
  ├── [[foundry-local]]        — ONNX models via OpenAI-compatible REST
  └── [[ms-semantic-kernel]]   — Kernel + plugins for cloud or local

Action (tool execution)
  ├── [[csharp-mcp-sdk]]                 — MCP tool definitions ([McpTool] attribute)
  ├── ms-semantic-kernel [KernelFunction] — SK plugin, JSON schema auto-generated
  └── [[dotnet-dependency-injection]]    — resolves services for action handlers

Observation (state read / memory write)
  ├── [[microsoft-data-sqlite-agent-patterns]] — local SQLite, zero-ORM, idempotent
  ├── [[ef-core-basics]]                       — relational ORM for richer schemas
  └── ms-semantic-kernel Kernel Memory         — vector store + RAG pipeline
```

## Core Integration Patterns

### 1. Kernel Plugin (Attribute-Based Discovery)
[[ms-semantic-kernel]] turns static C# classes into dynamic agent tools via reflection:

```csharp
public sealed class VaultPlugin
{
    [KernelFunction, Description("Returns total notes and graph density.")]
    public async Task<string> GetVaultStats() { ... }
}

var kernel = Kernel.CreateBuilder()
    .AddAzureOpenAIChatCompletion(...)
    .Build();
kernel.Plugins.AddFromType<VaultPlugin>();
```

SK introspects the method signature at runtime to generate the JSON Schema the LLM requires for tool calling — no manual schema registration needed.

### 2. MCP Tool Definition (Strongly Typed)
[[csharp-mcp-sdk]] exposes tools via the Model Context Protocol, enabling any MCP-compatible client to call them:

```csharp
[McpTool("get_vault_stats", "Returns total notes and graph density.")]
public async Task<string> GetVaultStats(GetStatsArgs args) { ... }
```

Use MCP when the consumer is another agent or a multi-client runtime. Use SK Kernel Plugins when the consumer is always a Semantic Kernel orchestrator.

### 3. Schema Registry (Contract First)
Use `System.Text.Json` + `JsonSerializerOptions` with strict mode to enforce the "Shape of Truth" at API boundaries. This prevents **interface hallucination** — where a model guesses parameter names that don't match compiled code.

```csharp
public record GetPageArgs([property: JsonPropertyName("title")] string Title);
```

Records are the idiomatic C# tool-argument type: serializable, null-safe, and schema-visible.

### 4. DI for Agency (Agent as First-Class Service)
Register the agent loop as an `IHostedService` within the .NET Generic Host, so standard ASP.NET Core or WPF apps gain reasoning capability without tight coupling:

```csharp
builder.Services.AddSingleton<IKernel>(sp => Kernel.CreateBuilder()
    .AddAzureOpenAIChatCompletion(...)
    .Build());
builder.Services.AddHostedService<AgentLoop>();
```

[[dotnet-dependency-injection]] handles lifecycle, logging, and configuration injection.

## Decision Protocol

### Inference
| Requirement | Component |
|---|---|
| Local, privacy-first, no cloud | [[lm-kit-dotnet]] |
| ONNX model, OpenAI-compatible API | [[foundry-local]] |
| Cloud LLM + plugin orchestration | [[ms-semantic-kernel]] |

### Memory / State
| Requirement | Component |
|---|---|
| Tiny local memory, CRUD, no ORM | [[microsoft-data-sqlite-agent-patterns]] |
| Large domain model with migrations | [[ef-core-basics]] |
| Semantic / vector retrieval (RAG) | ms-semantic-kernel Kernel Memory |
| Session state, transient agent logs | [[poshwiki]] |

### Tool Exposure
| Requirement | Component |
|---|---|
| MCP server in .NET | [[csharp-mcp-sdk]] + [[dotnet-mcp-server-patterns]] |
| SK orchestrator plugin | ms-semantic-kernel KernelFunction |
| Service lifetime management | [[dotnet-dependency-injection]] |

## Integration Map (Traversal Paths from Agentic Cluster)

- **MCP protocol work** → [[csharp-mcp-sdk]] → [[dotnet-mcp-server-patterns]]
- **Local inference** → [[lm-kit-dotnet]] → [[foundry-local]] → [[hardware-aware-inference]]
- **Enterprise orchestration** → [[ms-semantic-kernel]] → [[dotnet-dependency-injection]]
- **Memory substrate** → [[microsoft-data-sqlite-agent-patterns]] → [[csharp-for-agentic-workflows]]
- **Language reference** → [[csharp-moc]] → [[dotnet-moc]]

## The ADR

The formal ADR is now active at [[polyglot-platform-adr]]. The superseded draft and handoff remain available as [[polyglot-adr-rfc]] and [[codex-polyglot-adr-handoff]].

---
## References
- [[agentic-frameworks-moc]]
- [[dotnet-moc]]
- [[csharp-moc]]
- [[community-polyglot-agent-platform]]
- [[agent-thought-cycle]]
- [[csharp-mcp-sdk]]
- [[dotnet-mcp-server-patterns]]
- [[lm-kit-dotnet]]
- [[foundry-local]]
- [[ms-semantic-kernel]]
- [[microsoft-data-sqlite-agent-patterns]]
- [[csharp-for-agentic-workflows]]
- [[dotnet-dependency-injection]]
- [[hardware-aware-inference]]
- [[polyglot-platform-adr]]
- [[polyglot-adr-rfc]]
- [[codex-polyglot-adr-handoff]]
- [[community-protocol-trust-substrate]]
