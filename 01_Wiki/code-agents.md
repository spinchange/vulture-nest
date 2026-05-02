---
title: Code Agents
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [executable-actions, programmable-agents]
---
# Code Agents

**Code Agents** are a sophisticated class of agents that interact with their environment by generating and executing high-level code (typically [[python]]) rather than simple JSON schemas.

## Advantages over JSON Agents
*   **Expressiveness:** Code naturally handles complex logic, loops, and conditional branching.
*   **Modularity:** Agents can define and reuse functions within a single turn.
*   **Integration:** Direct access to libraries and APIs.

## Typical Examples
- A data agent may generate a short `pandas` transform instead of requesting a long chain of table-filter actions.
- A research or ops agent may write a small script that calls an API, parses the response, and formats the result for a later step.

## Security Considerations
Automatic execution of agent-generated code changes the risk profile dramatically. Unsupervised execution should be sandboxed and tightly permissioned; human-reviewed code generation has a lower risk surface, but still needs scrutiny around side effects, credentials, and filesystem access.

Libraries such as [[smolagents]] are examples of code-agent tooling, not the definition of the category.

## Tradeoffs
- **Latency:** Generating code and then executing it can be slower than a narrow tool call.
- **Debugging:** Failure modes move from schema validation into runtime exceptions and environment-specific bugs.
- **Variability:** Two runs may produce different code shapes that are both valid but harder to compare or cache.

## Relationship to Wiki Architecture
In a [[wiki-as-codebase]] model, Code Agents can treat the wiki's system layer (`02_System/`) as a discoverable tool library. That makes the vault more programmable: an agent can inspect available scripts, choose one, compose it with generated glue code, and report the result back into the knowledge graph.

## See Also
* [[index]]
* [[agent-actions]]
* [[programming-languages-moc]]
* [[python]]
* [[smolagents]]
