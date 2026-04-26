---
title: LM-Kit.NET
author: claude-sonnet-4-6
date: 2026-04-25
status: active
type: permanent
aliases: [lm-kit, dotnet-llm-sdk, lmkit-dotnet, lm-kit-inference]
---
# LM-Kit.NET

**LM-Kit.NET** is a commercial SDK that wraps `llama.cpp` and exposes a .NET-native inference API for local GGUF model execution. It is the primary way to run LLMs entirely on-device within a C#/.NET application.

## Position in the Tier Model

In the [[community-polyglot-agent-platform]] tier hierarchy, LM-Kit.NET is the **Tier-0→Tier-1 bridge**: it brings Tier-0 inference (systems-level, hardware-accelerated model execution) into a Tier-1 C# API surface, without requiring a Python subprocess or a cloud endpoint.

This means the full [[agent-thought-cycle]] (Thought → Action → Observation) can run entirely within .NET:
- **Thought** — LM-Kit.NET provides the inference
- **Action** — [[csharp-mcp-sdk]] or [[ms-semantic-kernel]] KernelFunction handles tool dispatch
- **Observation** — [[microsoft-data-sqlite-agent-patterns]] provides the memory read/write

## Hardware Acceleration

LM-Kit.NET delegates to the underlying `llama.cpp` back-end, so it inherits its hardware support:

| Backend | Hardware | Notes |
|---|---|---|
| CUDA | NVIDIA GPU | Highest throughput; requires CUDA toolkit |
| Metal | Apple Silicon | Unified memory advantage on M-series |
| DirectML | Any DX12 GPU | Windows-native; covers AMD, Intel, NVIDIA |
| CPU | x64 / ARM64 | Fallback; adequate for small models |

See [[hardware-aware-inference]] for the selection strategy.

## Core API Patterns

### Text Completion

```csharp
using LMKit.TextGeneration;

var model = new LLM("phi-3.5-mini.gguf");
var completer = new SingleTurnCompletion(model);

string result = await completer.SubmitAsync("Summarize this note in one sentence:");
Console.WriteLine(result);
```

### Chat Completion (Multi-Turn)

The multi-turn API maintains conversation state internally, making it idiomatic for the [[react-pattern]] loop where each Observation feeds back as a new user message:

```csharp
var chat = new MultiTurnConversation(model, systemPrompt: "You are a vault assistant.");
string reply = await chat.SubmitAsync("What is the current vault health score?");
```

### Embedding Generation

```csharp
var embedder = new TextEmbedding(model);
float[] vector = await embedder.EmbedAsync("agent memory substrate");
```

Embeddings feed into vector stores for semantic retrieval — the inference layer of the [[memory-spectrum]].

## Integration with Semantic Kernel

LM-Kit.NET can register as an `IChatCompletionService` in [[ms-semantic-kernel]], giving SK access to local inference through the same plugin API used with cloud models:

```csharp
var kernel = Kernel.CreateBuilder()
    .AddLMKitChatCompletion(modelPath: "phi-3.5-mini.gguf")
    .Build();

kernel.Plugins.AddFromType<VaultPlugin>();
var result = await kernel.InvokePromptAsync("List orphaned notes.");
```

This keeps the orchestration layer (SK) decoupled from the inference provider — swapping LM-Kit.NET for a cloud LLM requires only the builder line.

## Relationship to Foundry Local

Both LM-Kit.NET and [[foundry-local]] serve local .NET inference, but at different abstraction levels:

| | LM-Kit.NET | Foundry Local |
|---|---|---|
| **Model format** | GGUF (llama.cpp) | ONNX (optimized for NPU/DirectML) |
| **API style** | .NET SDK, typed objects | OpenAI-compatible REST (drop-in) |
| **Best for** | Embedding LLM directly in a .NET service | Local service shared across apps |
| **Hardware bias** | GPU/CPU via llama.cpp | NPU/DirectML (Microsoft stack) |

Use LM-Kit.NET when the model is embedded inside a single .NET process. Use Foundry Local when you want an OpenAI-compatible local endpoint shared across multiple tools.

## Agent Design Guidance

- **Privacy requirement** — LM-Kit.NET runs fully on-device; no tokens leave the machine.
- **Latency budget** — For tools needing sub-second inference, choose a 3B–7B GGUF model quantized to Q4; larger models trade latency for quality.
- **Concurrency** — `llama.cpp` is single-session by default. For multi-turn concurrent agents, run one `LLM` instance per session or serialize requests.
- **Context window** — GGUF models have fixed context; use [[agentic-rag]] or sliding window strategies for long sessions.

---
## References
- [[dotnet-agent-integration]]
- [[foundry-local]]
- [[hardware-aware-inference]]
- [[ms-semantic-kernel]]
- [[community-polyglot-agent-platform]]
- [[agent-thought-cycle]]
- [[memory-spectrum]]
- [[dotnet-moc]]
- [[agentic-frameworks-moc]]
