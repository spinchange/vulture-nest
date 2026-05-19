---
title: Hermes vs ADK, OpenAI Agents, and LangGraph
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-framework-comparison
  - hermes-vs-agent-frameworks
  - hermes-comparative-positioning
type: permanent
---
# Hermes vs ADK, OpenAI Agents, and LangGraph

[[hermes-vs-adk-openai-agents-langgraph]] positions Hermes against three neighboring systems in this vault: [[agent-development-kit|ADK]], [[openai-agents-sdk]], and [[langgraph]]. The short version is that Hermes sits *closer to a user-facing agent environment*, while the others sit *closer to libraries or orchestration frameworks*.

## The core distinction

All four systems support agents, tools, and some form of orchestration. The difference is **which layer each one treats as primary**.

- [[hermes-agent]] prioritizes the *persistent operating environment* around the agent.
- [[agent-development-kit|ADK]] prioritizes the *code-first runtime and service architecture* for building agents.
- [[openai-agents-sdk]] prioritizes the *production agent loop, handoffs, and guardrails* inside an application.
- [[langgraph]] prioritizes the *explicit control-flow graph* and durable state transitions.

So Hermes should not be read as "better handoffs" or "another graph library." Its distinctive move is to package runtime surfaces, memory, skills, tools, sessions, and operator controls into one deployable shell.

## Comparison dimensions

### 1. Primary abstraction
- **Hermes** — persistent agent shell
- **ADK** — event-driven agent toolkit with services
- **OpenAI Agents SDK** — production multi-agent SDK with runner/handoffs/guardrails
- **LangGraph** — stateful graph orchestration framework

### 2. Human control surface
- **Hermes** exposes a full operator grammar through slash commands, gateway commands, profiles, cron, and background sessions.
- **ADK** expects the developer to provide the app surface around the runner and services.
- **OpenAI Agents SDK** exposes Python APIs, hooks, and tracing rather than a built-in operator shell.
- **LangGraph** expects graph authorship, not an end-user runtime control plane.

This is where [[hermes-command-control-plane]] becomes decisive.

### 3. Persistence model
- **Hermes** persists sessions, profile state, hot memory, skills, gateway bindings, and cron jobs as part of one user environment.
- **ADK** offers explicit services for session, artifacts, and long-term memory.
- **OpenAI Agents SDK** supports resumable runs and tracing, but the surrounding environment remains largely application-defined.
- **LangGraph** persists graph state/checkpoints to enable durable execution and time travel.

Hermes is strongest when the persistence target is *the whole agent persona and workspace*, not only one workflow run.

### 4. Orchestration style
- **Hermes** mixes free-form agent turns with operational subsystems such as delegation, cron, kanban, and gateway routing.
- **ADK** cleanly separates LLM agents from deterministic workflow agents and service-backed orchestration.
- **OpenAI Agents SDK** centers a runner loop where tools and handoffs are first-class.
- **LangGraph** makes control flow explicit in nodes, edges, interrupts, and shared state.

If you want the graph itself to be the main artifact, LangGraph leads. If you want the user-facing environment to be the main artifact, Hermes leads.

### 5. Tool integration philosophy
- **Hermes** unifies built-in tools, toolsets, MCP servers, and dynamic schemas into one registered surface visible to the model.
- **ADK** treats tools as capabilities inside a broader service/runtime architecture.
- **OpenAI Agents SDK** supports tool invocation and native MCP, but leaves much of the surrounding capability governance to the application.
- **LangGraph** can incorporate tools, but tools are subordinate to the graph topology.

### 6. Intended audience
- **Hermes** fits power users, operator-builders, and people who want to *live inside* an agent environment.
- **ADK** fits system builders who want clear architectural primitives and workflow controllers.
- **OpenAI Agents SDK** fits developers building production agent applications around OpenAI's runner abstractions.
- **LangGraph** fits engineers who want deterministic stateful orchestration with explicit execution graphs.

## Practical routing rule

Choose Hermes when the question sounds like:
- "How do I keep one agent alive across terminal, Telegram, and background jobs?"
- "How do memory, skills, slash commands, and tools fit into one long-lived agent?"
- "What does an agent operating environment look like rather than just an SDK?"

Choose ADK when the question sounds like:
- "How do I architect services around agents, workflows, and event streams?"

Choose OpenAI Agents SDK when the question sounds like:
- "How do I implement production handoffs, guardrails, and tracing inside a Python app?"

Choose LangGraph when the question sounds like:
- "How do I model the workflow itself as durable explicit state transitions?"

## Deeper claim

Hermes's strongest comparison advantage is not any single primitive. It is the fact that it **bundles multiple agent concerns into one coherent lived runtime**:
- prompt assembly
- provider switching
- tool governance
- command control
- memory and session search
- gateway transport
- background execution
- cross-profile collaboration

The other three systems are usually stronger if you want to embed agent behavior inside your own product architecture. Hermes is stronger if you want the *agent environment itself* to be the product.

## Architectural consequence

[[hermes-vs-adk-openai-agents-langgraph]] helps prevent a category error. Comparing Hermes to ADK, OpenAI Agents SDK, or LangGraph only at the level of "agent loop" misses what Hermes is doing. Hermes competes less as a loop abstraction and more as a **persistent user-facing agent substrate**.

## See Also
- [[hermes-agent]]
- [[hermes-command-control-plane]]
- [[hermes-moc]]
- [[agent-development-kit]]
- [[adk-moc]]
- [[openai-agents-sdk]]
- [[langgraph]]
- [[agentic-frameworks-moc]]
- [[orchestration-tradeoffs]]
- [[graph-orchestration]]

## References
- [[hermes-agent]]
- [[lit-hermes-architecture]]
- [[agent-development-kit]]
- [[adk-moc]]
- [[openai-agents-sdk]]
- [[lit-openai-agents-sdk]]
- [[langgraph]]
- [[lit-langgraph]]
