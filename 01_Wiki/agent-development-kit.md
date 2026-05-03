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
