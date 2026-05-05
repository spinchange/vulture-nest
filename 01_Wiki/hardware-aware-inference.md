---
title: Hardware-Aware Inference
author: claude-sonnet-4-6
date: 2026-05-04
status: active
type: permanent
aliases:
  - cuda
  - mlx
  - directml
  - onnx
---
# Hardware-Aware Inference

Hardware-aware inference is the practice of matching model execution to the available hardware accelerators — and selecting the runtime and model format that exposes those accelerators to a running process.

## When to Start Here

Start here when the question is about **where and how a model physically runs**, not about which model to use or how to write the agent loop around it. Typical entry questions:

- "Which acceleration stack should I use for my hardware?"
- "What runtime do I need to run local models on Windows / Mac?"
- "How does ONNX differ from GGUF, and why does it matter for my setup?"
- "My application runs in Python or .NET — how do I get local inference without a cloud endpoint?"

## The Two Dimensions

Picking a local inference setup requires two separate decisions that interact:

**Hardware target** — which silicon does the work: NVIDIA GPU (CUDA), Apple Silicon (MLX / Metal), any DX12 GPU (DirectML), NPU, or CPU fallback.

**Runtime + model format** — the software layer between your code and the hardware. The format determines which runtimes are available:

| Format | Runtime options | Hardware surfaces |
|---|---|---|
| **GGUF** | llama.cpp, Ollama, LM-Kit.NET | CUDA, Metal, DirectML, CPU |
| **ONNX** | ONNX Runtime, Foundry Local | CUDA EP, CoreML EP, DirectML EP, NPU EP |

Choosing a format first narrows the runtime options. Choosing hardware first narrows the formats that perform well on that silicon.

The tables and routing guidance below combine two layers:

- directly sourced facts from [[foundry-local]] and [[lit-foundry-local]] about the Microsoft / ONNX / NPU stack
- vault-local synthesis about adjacent runtimes such as Ollama and llama.cpp, based on how related notes in this vault divide the local inference ecosystem

Read the runtime-selection matrix as operational guidance, not as a claim that every row comes from one upstream source.

## Acceleration Backends

**CUDA (NVIDIA)** — industry standard for NVIDIA GPUs. Mature library ecosystem (cuDNN, TensorRT). Best absolute throughput for large models on Linux or Windows. Requires the CUDA toolkit installed on the host.

**MLX (Apple)** — Apple's open-source framework optimized for Apple Silicon's Unified Memory Architecture (M1–M4). CPU and GPU share the same physical memory pool, so large models can exceed GPU VRAM limits without discrete-GPU copy overhead. The preferred acceleration surface for Mac-native Python workflows.

**DirectML (Microsoft)** — hardware-agnostic ML library for Windows and WSL that targets any DX12-capable GPU: NVIDIA, AMD, or Intel Arc, including integrated graphics. The practical choice for Windows development when CUDA hardware is unavailable or when cross-vendor GPU coverage is needed.

**ONNX Runtime Execution Providers** — ONNX Runtime selects the best available accelerator at runtime via pluggable "execution providers": CUDA EP, DirectML EP, CoreML EP, NPU EP. It is the inference substrate under Foundry Local and is also available as a standalone library for cross-platform deployment.

**NPU targets** — dedicated neural processing units on modern consumer hardware (Intel NPU on Meteor Lake, Apple Neural Engine via CoreML EP, Qualcomm Hexagon on Snapdragon). Foundry Local explicitly routes int4 ONNX models to NPUs on supported hardware, delivering lower power draw than GPU inference at modest model sizes.

## Selection Strategy

| Scenario | Stack | Concrete runtime |
|---|---|---|
| Mac development, large models | MLX + Metal | Ollama on Mac, or MLX Python library directly |
| Windows, any GPU vendor | DirectML | Foundry Local (ONNX), or llama.cpp DirectML backend |
| NVIDIA GPU, Linux or Windows | CUDA | Ollama (llama.cpp), ORT CUDA EP, or Foundry Local |
| .NET application, embedded model | CUDA / Metal / DirectML | [[lm-kit-dotnet]] (wraps llama.cpp) |
| Cross-platform or NPU-targeted | ONNX Runtime | Foundry Local (managed) or ORT standalone |
| CPU fallback, small models | x64 / ARM64 | Ollama, llama.cpp, or ORT CPU EP |

**Quantization** affects which hardware tier is required. In this note, the GGUF Q4 / Q8 guidance is a vault-local rule of thumb for reasoning about memory pressure and deployment fit, not a property documented by the Foundry Local source itself. By contrast, the ONNX / int4 edge-device story is directly aligned with the Foundry Local model-catalog positioning.

## Where to Go Next

- **Microsoft stack on Windows, ONNX models**: [[foundry-local]] and [[lit-foundry-local]]
- **Local Ollama endpoint for Python agents**: [[local-agent-environments]]
- **Embedded .NET inference with llama.cpp (GGUF models)**: [[lm-kit-dotnet]]
- **Security and isolation for local model execution**: [[docker-sandbox]]
- **Broader language runtime context**: [[programming-languages-moc]]

---
## References
- Sources: `00_Raw/foundry-local.md`
- [[foundry-local]]
- [[lit-foundry-local]]
- [[local-agent-environments]]
- [[lm-kit-dotnet]]
- [[docker-sandbox]]
- [[programming-languages-moc]]
