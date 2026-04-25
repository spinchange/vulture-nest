---
title: Microsoft Semantic Kernel
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [semantic-kernel, ms-kernel-memory, sk-framework]
---
# Microsoft Semantic Kernel

**Semantic Kernel (SK)** is an open-source SDK that acts as the "Middleware" or "Brain" for AI applications. It orchestrates the flow between Large Language Models (LLMs) and conventional code (C#, Python, Java).

## Core Architecture
- **Kernel:** The central hub configured via `KernelBuilder`. It handles dependency injection and manages the lifecycle of AI services.
- **Plugins:** Encapsulated functions (native or semantic) that extend the agent's capabilities.
- **Function Calling:** Supports automatic invocation of plugins based on LLM intent.

## Kernel Memory (KM)
A specialized service for **Retrieval-Augmented Generation (RAG)**.
- **Ingestion Pipeline:** Automates PDF/doc parsing, chunking, and embedding.
- **Proactive Memory:** Background tasks that summarize and enrich data during ingestion.
- **Storage:** Supports cloud (Azure AI Search) and local (Qdrant, Disk, In-Memory) vector stores.

## Implementation Pattern (.NET)
```csharp
var builder = Kernel.CreateBuilder();
builder.AddAzureOpenAIChatCompletion(...);
builder.Plugins.AddFromType<MyPlugin>();
var kernel = builder.Build();

// Automatic function calling
var result = await kernel.InvokePromptAsync("What is the current vault status?");
```

---
## References
- [[memory-spectrum]]
- [[agentic-rag]]
- [[dotnet-moc]]
- [[csharp-mcp-sdk]]
