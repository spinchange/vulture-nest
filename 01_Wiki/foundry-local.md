---
title: Foundry Local
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [azure-ai-foundry-local, microsoft-foundry-local]
---
# Foundry Local (Microsoft Azure AI Foundry Local)

**Foundry Local** is a lightweight SDK and runtime from Microsoft designed for building AI-powered applications with hardware-optimized, on-device inference. It prioritizes privacy, offline readiness, and low latency by keeping all data and processing on the local device.

## Core Features
* **Privacy First**: All inference happens locally; data never leaves the device.
* **Hardware Optimization**: Automatically leverages NPUs, GPUs (via DirectML/CUDA/Metal), or CPUs.
* **OpenAI Compatibility**: Provides a drop-in API replacement for existing OpenAI client libraries, making migration from cloud to local seamless.
* **Offline Ready**: Operates without a network connection.

## Implementation Models
* **Standalone**: The application embeds the SDK and manages the model lifecycle directly.
* **Shared Service**: Foundry Local runs as a background service, exposing an OpenAI-compatible REST API to multiple local applications.

## Supported Models
Foundry Local focuses on optimized **ONNX** models, including:
* **Phi-3.5** (Microsoft)
* **Qwen 2.5** (Alibaba)
* **Whisper** (OpenAI, for local transcription)

## CLI & SDK
* **CLI**: Managed via `foundry model run <model-id>`.
* **SDK**: Available for C#, [[python]], and other languages, allowing for programmatic model management and inference.

---
## References
* Source: `00_Raw/foundry-local.md`
* [[local-agent-environments]]
* [[agentic-frameworks-moc]]

* [[mcp-local-connections]] (Local-first security patterns)

