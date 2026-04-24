---
title: Code Agents
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [executable-actions, smolagents, programmable-agents]
---
# Code Agents

**Code Agents** are a sophisticated class of agents that interact with their environment by generating and executing high-level code (typically Python) rather than simple JSON schemas.

## Advantages over JSON Agents
*   **Expressiveness:** Code naturally handles complex logic, loops, and conditional branching that are cumbersome in JSON.
*   **Modularity:** Agents can define and reuse functions within a single turn.
*   **Integration:** Direct access to libraries and APIs.

## Security Considerations
Executing agent-generated code requires strict sandboxing to prevent prompt injection from escalating into system-level compromise. Tools like `smolagents` or secure execution environments are mandatory.

## Relationship to Wiki Architecture
In a [[wiki-as-codebase]] model, Code Agents are particularly effective because they can treat the wiki's system layer (`02_System/`) as a library of available tools.

## See Also
* [[agent-actions]]
* [[programming-languages-moc]]
* [[python]]
