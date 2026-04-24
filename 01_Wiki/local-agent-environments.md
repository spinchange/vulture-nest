---
title: Local Agent Environments
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ollama, litellm-setup, local-inference]
---
# Local Agent Environments

Building agents often requires running models locally to avoid credit limits, ensure privacy, or perform rapid experimentation.

## Technical Stack
*   **Ollama:** The industry standard for running open-weights models (e.g., Llama 3, Qwen 2) on local hardware with a simple CLI.
*   **LiteLLM:** A middleware bridge that translates different model APIs into a standardized OpenAI-compatible format.

## Implementation in smolagents
To use a local model in `smolagents`, the `LiteLLMModel` class is used to point the agent to the local Ollama server (`http://localhost:11434`).

## See Also
* [[smolagents]]
* [[programming-languages-moc]]
