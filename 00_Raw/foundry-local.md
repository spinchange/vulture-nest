---
tags:
  - ai
  - edge
  - local-inference
  - sdk
  - microsoft
source: https://www.foundrylocal.ai/
machine: VEGA
date: 2026-04-24
status: draft
---
# Foundry Local (Microsoft Azure AI Foundry Local)

Foundry Local is a lightweight SDK and runtime for building and shipping AI-powered applications with hardware-optimized, on-device inference.

## 1. Overview
- **Privacy First:** All data stays on the user's device.
- **Hardware Optimized:** Automatically utilizes NPU, GPU (DirectML/CUDA/Metal), or CPU.
- **OpenAI Compatible:** Offers a drop-in API replacement for existing OpenAI client libraries.
- **Offline Ready:** Zero network latency and no cloud dependencies.

## 2. Installation (CLI)

### Windows
`powershell
winget install Microsoft.FoundryLocal
`

### macOS
`ash
brew install microsoft/foundrylocal/foundrylocal
`

## 3. CLI Commands
- oundry model ls - List available models in the catalog.
- oundry model run <model-id> - Download and run a model (e.g., phi-3.5-mini, qwen2.5-0.5b).
- oundry status - Check the status of the local runtime.

## 4. SDK Usage

### C# Initialization
`csharp
using Microsoft.AI.Foundry.Local;

var config = new Configuration { 
    AppName = "my-ai-app", 
    LogLevel = LogLevel.Information 
};

// Initialize the manager and load a model
var manager = await FoundryLocalManager.CreateAsync(config);
var model = manager.GetCatalog().GetModel("phi-3.5-mini");
await model.LoadAsync();
`

### Python with OpenAI Client
Foundry Local can run as a service, providing an endpoint for standard OpenAI SDKs.

`python
from foundry_local_sdk import FoundryLocalManager
from openai import OpenAI

# Initialize manager
manager = FoundryLocalManager()
manager.start_service()

# Use standard OpenAI client pointing to local service
client = OpenAI(
    base_url=manager.get_service_uri(),
    api_key="not-needed"
)

response = client.chat.completions.create(
    model="phi-3.5-mini",
    messages=[{"role": "user", "content": "Hello local AI!"}]
)
`

## 5. Model Catalog
Foundry Local supports curated and optimized ONNX models:
- **Language:** Phi-3.5, Qwen 2.5, Mistral.
- **Audio:** Whisper (for local transcription).
- **Vision:** Select vision-capable models.

## 6. Deployment Patterns
- **Standalone:** Ship your app with the Foundry Local SDK embedded; the app manages its own model lifecycle.
- **Shared Service:** Run Foundry Local as a background service accessible by multiple applications via the OpenAI-compatible REST API.
