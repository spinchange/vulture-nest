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
- **Privacy**: No data leaves the local device.
- **Efficiency**: Automatic optimization for NPUs, GPUs (DirectML, CUDA, Metal), and CPUs.
- **Compatibility**: Drop-in OpenAI API replacement.
- **Resilience**: Full offline capability.

## Runtimes
1. **Standalone**: Embedded in applications.
2. **Shared Service**: Background process acting as a local OpenAI endpoint.

## Key Model Support
Focuses on **ONNX** optimized variants:
- **Phi-3.5**: Efficient small language model.
- **Qwen 2.5**: High-performance multi-lingual model.
- **Whisper**: Local speech-to-text.

---
## See Also
- [[foundry-local]] (Permanent Note)
- [[local-agent-environments]]
- [[mcp-local-connections]]
