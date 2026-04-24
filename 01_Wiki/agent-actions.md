---
title: Agent Actions
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [agent-tool-use, stop-and-parse, action-parsing]
---
# Agent Actions

**Actions** are the discrete operations executed by an AI agent to interact with its environment. In the context of an [[llm-wiki-pattern]], actions are the mechanism by which the agent modifies the vault or queries external data.

## The Stop and Parse Approach
For an agent to function reliably, it must follow a strict lifecycle:
1. **Generation:** The agent outputs a structured command (JSON or Code).
2. **Halting:** The LLM stops token generation immediately after the command.
3. **Parsing:** An external system (the "Env") parses the command, executes the tool, and returns the **Observation**.

## Classification of Actions
*   **Information Gathering:** Web searches, database queries.
*   **Tool Usage:** API calls, calculations.
*   **Environment Interaction:** File system operations (e.g., `write_file` in this wiki).
*   **Communication:** Inter-agent or user-facing chat.

## See Also
* [[code-agents]]
* [[wiki-pattern-operations]]
* [[yanp-for-agentic-workflows]]
