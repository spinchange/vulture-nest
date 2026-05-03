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

## Core Opinion

Code agents trade narrow interface safety for expressive execution. They matter when the work naturally wants loops, temporary variables, helper functions, lightweight parsing, or multi-step tool composition that would be awkward to express as one JSON-shaped function call at a time.

In the Nest, this is not the default execution style for everything. It is the style to choose when tool calling would become an artificial bottleneck and when the runtime boundary is strong enough to tolerate generated code.

## Advantages over JSON Agents
*   **Expressiveness:** Code naturally handles complex logic, loops, and conditional branching.
*   **Modularity:** Agents can define and reuse functions within a single turn.
*   **Integration:** Direct access to libraries and APIs.

## When They Fit

Choose a code agent when the task sounds like:

- "Take these intermediate results and transform them a few times before returning anything."
- "Call several tools in sequence without paying a model round trip for each step."
- "Write a small piece of glue logic around existing libraries or scripts."
- "Inspect the local environment and compose a solution from available components."

If the task can be expressed as one narrow, well-described tool contract, ordinary [[agent-tools]] are usually safer and easier to observe.

## Typical Examples
- A data agent may generate a short `pandas` transform instead of requesting a long chain of table-filter actions.
- A research or ops agent may write a small script that calls an API, parses the response, and formats the result for a later step.

## Execution Contract

The important boundary is not "did the model write code?" but "who is allowed to run it, with what permissions, and under what review path?"

Useful execution contracts include:

- **Sandboxed autonomous execution:** The strongest form of code-agent autonomy, appropriate only when filesystem, network, and credential access are tightly constrained.
- **Brokered tool execution:** The generated code can call approved tools, but the host mediates those calls rather than granting arbitrary ambient authority.
- **Human-reviewed execution:** The model writes code, but a human decides whether it actually runs.

## Security Considerations
Automatic execution of agent-generated code changes the risk profile dramatically. Unsupervised execution should be sandboxed and tightly permissioned; human-reviewed code generation has a lower risk surface, but still needs scrutiny around side effects, credentials, and filesystem access.

Libraries such as [[smolagents]] are examples of code-agent tooling, not the definition of the category.

## Tradeoffs
- **Latency:** Generating code and then executing it can be slower than a narrow tool call.
- **Debugging:** Failure modes move from schema validation into runtime exceptions and environment-specific bugs.
- **Variability:** Two runs may produce different code shapes that are both valid but harder to compare or cache.

## Relationship to Other Patterns

- [[agent-actions]] and [[agent-tools]] cover the narrower tool-calling execution model that code agents often replace or wrap.
- [[graph-orchestration]] is complementary: a graph may route between phases while individual nodes use code-agent execution internally.
- [[smolagents]] is the clearest framework example in this vault of the code-first style.
- [[python]] is the default implementation language for most code-agent examples here because it has the strongest local tooling and SDK surface.

## Relationship to Wiki Architecture
In a [[wiki-as-codebase]] model, Code Agents can treat the wiki's system layer (`02_System/`) as a discoverable tool library. That makes the vault more programmable: an agent can inspect available scripts, choose one, compose it with generated glue code, and report the result back into the knowledge graph.

## Start Here

1. Read [[smolagents]] for the code-first framework model.
2. Read [[agent-tools]] if you need the contrast against schema-first tool calling.
3. Read [[graph-orchestration]] if the question is really about workflow topology rather than execution style.

## See Also
* [[index]]
* [[agent-actions]]
* [[agent-tools]]
* [[graph-orchestration]]
* [[programming-languages-moc]]
* [[python]]
* [[smolagents]]
