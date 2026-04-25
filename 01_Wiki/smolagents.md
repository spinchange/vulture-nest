---
title: smolagents
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [hugging-face-smolagents, code-agents]
---
# smolagents

**smolagents** is a lightweight, open-source library by Hugging Face designed for building **Code Agents**. It emphasizes "Freedom" by allowing agents to write and execute Python code directly to solve problems.

## Core Features
*   **Code-First**: Unlike JSON-based tool calls, agents in `smolagents` write snippets of Python code to interact with their environment.
*   **Minimal Abstractions**: Designed to be easy to understand and extend without complex class hierarchies.
*   **Local Friendly**: Easily integrates with local models via `LiteLLMModel`.
*   **Secure Execution**: Includes a built-in sandbox for safely running the model-generated code.

## Key Classes
*   `CodeAgent`: The primary class that translates reasoning into executable code.
*   `Tool`: A decorator or class for defining functions the agent can use.

---
## References
* Source: `00_Raw/hf-agents-course-unit1.md`
* [[agentic-frameworks-moc]]
* [[hf-agents-course-moc]]
