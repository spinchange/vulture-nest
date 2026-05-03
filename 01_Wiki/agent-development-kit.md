---
title: Agent Development Kit ([[agent-development-kit|ADK]])
author: gemini-cli
date: 2026-05-02
status: active
type: permanent
aliases: [adk, google-adk]
---
# Agent Development Kit (ADK)

The **Agent Development Kit (ADK)** is an open-source, code-first toolkit for building, evaluating, and deploying sophisticated AI agents with high flexibility and control. It is particularly optimized for Google's Gemini models but designed for broad LLM support.

## Core Opinion

ADK matters in this vault because it is one of the clearest frameworks for separating LLM-driven agent behavior from explicit orchestration structure. It is strongest when you want a code-first agent system with durable session state, first-class workflow controllers, and a runner that treats execution as an event stream rather than a chat transcript.

The practical reading of ADK in the Nest is:

- use **ADK** when you want explicit control over agent runtime structure, persistent services, and the boundary between deterministic flow and model-driven reasoning
- compare it to **[[openai-agents-sdk]]** when the question is orchestration ergonomics or handoff style
- compare it to **[[openai-swarm]]** when the question is lightweight interactive multi-agent chat rather than structured runtime services

## Decision Rule

Start from `[[agent-development-kit]]` when your question sounds like one of these:

- "Which framework gives me workflow controllers instead of only free-form agent loops?"
- "How do sessions, artifacts, and long-term memory fit into an agent runtime?"
- "Where do I look in ADK for multi-agent routing, callbacks, or evaluation?"
- "How does ADK split deterministic orchestration from LLM-driven behavior?"

If the question is instead about general execution topology, route to [[graph-orchestration]] or [[workflow-agents]]. If it is about generic tool contracts rather than the framework runtime, route to [[agent-tools]].

## Architectural Blueprint
ADK operates on an **Event-Driven Orchestration** model managed by the **Runner**.

### The Runner (Orchestrator)
The [[adk-callbacks-and-lifecycle|Runner]] acts as the central coordinator for a single user invocation. It:
1.  **Initiates**: Appends the user's `new_message` to the [[adk-session-service|Session]].
2.  **Orchestrates**: Kicks off the agent's execution loop by calling the main agent's `run_async` method.
3.  **Processes Events**: Intercepts every `Event` (tool call, state change, message) and commits changes via specialized services.
4.  **Yields**: Forwards processed events to the calling application/UI.

### Core Primitives
*   **[[agent-actions|Agent]]**: The fundamental worker unit.
    *   `LlmAgent`: Reasoning-based, uses an LLM.
    *   [[workflow-agents|Workflow Agent]]: Deterministic control (`SequentialAgent`, `ParallelAgent`, `LoopAgent`).
*   **[[agent-tools|Tool]]**: Capabilities beyond conversation (APIs, search, code execution).
*   **Events**: The immutable message format for communication and control. Every interaction is an `Event`.

### Persistent Services
*   **[[adk-session-service|Session Service]]**: Manages conversational context, history (`Events`), and short-term working memory (`State`).
*   **[[adk-artifact-service|Artifact Service]]**: Handles named, versioned binary data (files, images) associated with a session.
*   **[[adk-long-term-memory|Memory Service]]**: Enables agents to recall information across *multiple* sessions (Long-Term Knowledge).

## Multi-Agent Design
ADK is designed for modular, scalable multi-agent systems:
-   **Hierarchical Coordination**: Build teams where specialized agents delegate sub-tasks.
-   **Handoff Mechanisms**: Agents can coordinate via LLM-driven transfer or explicit `AgentTool` invocation.
-   **[[adk-advanced-capabilities|Advanced Capabilities]]**: Support for multimodal streaming, ReAct planning, and native Gemini Live API integration.

## Extension & Control
-   **[[adk-callbacks-and-lifecycle|Callbacks]]**: Standard functions to hook into the execution process (Before/After Agent, Model, or Tool).
-   **Plugins**: Modular security guardrails and policies that offer more flexibility than basic callbacks.
-   **[[adk-evaluation-framework|Evaluation]]**: Built-in tools for multi-turn dataset creation and systematic performance assessment.

## Start Here

Choose the shortest path based on the work:

1. If you need the runtime model, start with [[adk-callbacks-and-lifecycle]] and then return here.
2. If you need deterministic orchestration, go straight to [[workflow-agents]] and [[adk-multi-agent-orchestration]].
3. If you need memory or persistence behavior, route through [[adk-session-service]], [[adk-artifact-service]], and [[adk-long-term-memory]].
4. If you need evaluation or productionization concerns, go to [[adk-evaluation-framework]] after the runner model is clear.

## Relationship to the Rest of the Vault

- [[graph-orchestration]] is the higher-level execution pattern; ADK is one concrete implementation family.
- [[workflow-agents]] is the clearest entry point when the question is deterministic control flow rather than the whole framework.
- [[agent-thought-cycle]] and [[agent-tools]] explain the lower-level mechanics that ADK packages into a framework runtime.
- [[agentic-frameworks-moc]] is the broader comparison surface once you know which ADK subsystem matters.

---
## Implementations
-   [[adk-go-implementation]]
-   Python, Java, and TypeScript SDKs.

## References
*   Source: `00_Raw/adk-documentation.md`
*   [[agentic-frameworks-moc]]
*   [[multi-agent-systems]]
*   [[agent-tools]]
-   [[lit-adk-documentation]]
