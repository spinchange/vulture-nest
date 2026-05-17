---
title: 'Literature: Agent Development Kit ([[agent-development-kit|ADK]]) Documentation'
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - adk-source
  - adk-docs
type: literature
---

# Literature: Agent Development Kit (ADK) Documentation

## Source Metadata
*   **File:** `00_Raw/adk-documentation.md`
*   **Topic:** Framework for building, evaluating, and deploying multi-agent systems.
*   **Languages Supported:** Go, [[python]], Java, [[typescript|TypeScript]].

## High-Level Summary
The ADK is a code-first toolkit designed for sophisticated AI agent development. It moves beyond simple chat interfaces into structured, multi-agent orchestration and lifecycle management (Build, Evaluate, Deploy).

## Key Primitives Identified
*   **[[agent-development-kit#agent|Agent]]:** Fundamental worker unit. Includes `LlmAgent` (reasoning) and Workflow Agents (`SequentialAgent`, `ParallelAgent`, `LoopAgent`).
*   **[[agent-development-kit#tool|Tool]]:** External capabilities (APIs, Search, Code Execution).
*   **[[agent-development-kit#session-management|Session & State]]:** Context handling for single conversations.
*   **[[agent-development-kit#memory|Memory]]:** Long-term recall across multiple sessions.
*   **[[agent-development-kit#artifact-management|Artifacts]]:** Binary/file data management.
*   **[[agent-development-kit#runner|Runner]]:** The execution engine orchestrating the flow.

## Architectural Themes
1.  **Multi-Agent Design:** Hierarchical and specialized agents.
2.  **Flexible Orchestration:** Combining deterministic workflows with dynamic LLM routing.
3.  **Developer Tooling:** CLI and Dev UI for debugging and visualization.
4.  **Streaming:** Native support for bidirectional text/audio (e.g., Gemini Live API).

## Next Steps for Synthesis
*   Extract detailed specifications for [[workflow-agents]].
*   Map the [[adk-go-implementation]] (Go seems to be a primary focus in the docs).
*   Detail the [[adk-artifact-service]] and [[adk-evaluation-framework]].

