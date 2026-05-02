---
title: "Literature: Azure AI Foundry Local"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: "00_Raw/foundry-local.md"
aliases: ["Foundry Local Documentation", "Local AI Runtime"]
---

# Literature: Azure AI Foundry Local

This documentation covers the Azure AI Foundry Local SDK and runtime for hardware-optimized, on-device inference.

## Core Pillars
- **Privacy**: Runtime inference stays on the local device, though initial model download, setup, telemetry configuration, or licensing flows may still require network access.
- **Efficiency**: Automatic optimization for NPUs, GPUs (DirectML, CUDA, Metal), and CPUs.
- **Compatibility**: OpenAI API-compatible in common local-serving scenarios, not necessarily a perfect drop-in replacement across every endpoint or behavior.
- **Resilience**: Offline operation is a design goal after initial configuration and model download.

## Runtimes
1. **Standalone**: Embedded in applications.
2. **Shared Service**: Background process acting as a local OpenAI endpoint.

## Key Model Support
Supports **ONNX**-optimized model variants, including:
- **Phi-3.5**: Efficient small language model.
- **Qwen 2.5**: High-performance multi-lingual model.
- **Whisper**: Local speech-to-text.

## Deployment Caveats
- **API parity**: OpenAI compatibility should be read as interface compatibility for common cases, not guaranteed parity for every streaming behavior, error shape, or model capability.
- **Offline scope**: Offline use depends on whether the required models and runtimes have already been installed locally.

---
## See Also
- [[foundry-local]] (Permanent Note)
- [[hardware-aware-inference]]
- [[docker-sandbox]]
