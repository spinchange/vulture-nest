---
title: Agent Actions Unit
author: gemini-cli
date: 2026-04-25
status: active
type: literature
aliases: [hf-agents-unit-1-actions, code-agents-summary]
---
# Actions: Enabling the Agent to Engage with Its Environment

Source: Agents Course (Unit 1) - Hugging Face

## Summary
Actions are the concrete steps an AI agent takes to interact with its environment (web browsing, tool usage, API calls).

## Key Concepts
* **JSON Agent:** Emits a structured action payload that an external system parses and executes.
* **Code Agent:** Generates executable code blocks (for example in [[python]]) instead of a narrow JSON action schema.
* **Function-calling Agent:** Uses native structured tool-calling behavior exposed by the model or framework. It is adjacent to JSON-style agents, but not identical to "a fine-tuned JSON agent."
* **Stop and Parse:** In many tool-use loops, the model is configured to stop after emitting an action so the environment can parse it, execute it, and return an observation before generation resumes.

## Why Stop and Parse Matters
This pattern is the control boundary between reasoning and action:
- the model emits an action
- the runtime intercepts that action
- the tool or environment executes it
- the result is returned to the model as the next observation

JSON-agent loops depend on this most explicitly, while native [[function-calling]] systems can hide more of the parsing machinery behind the model API.

## Minimal Examples
- **JSON-style action:** `{"tool": "search", "args": {"query": "latest MCP spec"}}`
- **Code-agent action:** a short script that calls an API, transforms the response, and prints a final result

## Advantages of Code Agents
* Expressiveness (loops, conditionals).
* Modularity/Reusability.
* Enhanced debuggability.
* Direct integration with libraries.

## Tradeoffs of Code Agents
* Higher execution risk than narrow structured tool calls.
* Requires a runtime environment and stronger sandboxing.
* Can add latency and variability compared with direct function calling.

## Related
- [[agent-actions]]
- [[code-agents]]
- [[function-calling]]
- [[agent-tools]]
- [[hf-agents-course-moc]]

