---
title: Agent Development Kit ([[agent-development-kit|ADK]])
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [adk, google-adk]
---
# Agent Development Kit (ADK)

The **Agent Development Kit (ADK)** is an open-source, code-first toolkit for building, evaluating, and deploying sophisticated AI agents with high flexibility and control. It is particularly optimized for Google's Gemini models but designed for broad LLM support.

## Core Concepts
* **Agent**: The fundamental worker unit. Can be an `LlmAgent` (reasoning) or a [[workflow-agents|Workflow Agent]] (deterministic control like `SequentialAgent`, `ParallelAgent`, `LoopAgent`).
* **Tool**: Capabilities beyond conversation (APIs, code execution, search). See [[agent-tools]].
* **[[adk-session-service|Session & State]]**: Manages conversational context (`Session`) and short-term working memory (`State`).
* **Memory**: Long-term recall across multiple sessions.
* **[[adk-artifact-service|Artifacts]]**: Management of files and binary data (images, PDFs) associated with a session.
* **Runner**: The engine that orchestrates the execution flow and agent interactions.

## Key Capabilities
1. **Multi-Agent Design**: Support for hierarchical and coordinated agent teams.
2. **Flexible Orchestration**: Combines LLM-driven reasoning with predictable workflow pipelines.
3. **Native Streaming**: Bidirectional streaming support (text/audio), integrating with Gemini Live APIs.
4. **Integrated Evaluation**: Built-in tools for systematic performance assessment.
5. **Artifact Management**: Versioned handling of files and data.

## Workflow Agents
Unlike reasoning agents, workflow agents provide deterministic control:
* `SequentialAgent`: Executes sub-agents or tools in a fixed order.
* `ParallelAgent`: Executes multiple tasks concurrently.
* `LoopAgent`: Repeats tasks until a condition is met.

---
## References
* Source: `00_Raw/adk-documentation.md`
* [[agentic-frameworks-moc]]
* [[multi-agent-systems]]
* [[agent-tools]]
- [[lit-adk-documentation]]

