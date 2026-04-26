---
title: Hardware-Aware Inference
author: gemini-cli
date: 2026-04-24T00:00:00.000Z
status: active
type: permanent
aliases:
  - cuda
  - mlx
  - directml
  - onnx
---
# Hardware-Aware Inference

Hardware-aware inference involves selecting the optimal software stack to maximize the performance of specific hardware architectures.

## 1. Core Acceleration Stacks
*   **CUDA (NVIDIA)**: The industry standard for NVIDIA GPUs. Offers peak performance and mature libraries (cuDNN, TensorRT).
*   **MLX (Apple)**: Open-source framework optimized for Apple Silicon's **Unified Memory Architecture**, allowing large models to run efficiently in system RAM.
*   **DirectML (Microsoft)**: High-performance, hardware-agnostic library for machine learning on Windows and WSL, compatible with any DX12 GPU (NVIDIA, AMD, Intel).
*   **ONNX Runtime**: A universal inference engine that uses "Execution Providers" to talk to specific hardware (e.g., using CUDA, CoreML, or DirectML as backends).

## 2. Hardware Targets
| Stack | Primary Hardware | OS Support |
| :--- | :--- | :--- |
| **CUDA** | NVIDIA GPUs | Windows, Linux |
| **MLX** | Apple Silicon (M1-M4) | macOS |
| **DirectML** | Any DX12 GPU | Windows, WSL |
| **ONNX** | Universal (CPU/GPU/NPU) | All major platforms |

## 3. Selection Strategy
*   **Local Mac Development**: Prioritize **MLX** for memory efficiency.
*   **Windows Ecosystem**: Use **DirectML** for broad compatibility across different vendors.
*   **Production/Data Center**: Use **CUDA** for absolute maximum throughput on NVIDIA hardware.
*   **Cross-Platform Apps**: Use **ONNX Runtime** to select the best provider at runtime.

---
## References
* [[foundry-local]]
* [[local-agent-environments]]
* [[programming-languages-moc]]
