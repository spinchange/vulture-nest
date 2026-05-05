---
title: Agent Development Kit ([[agent-development-kit|ADK]]) MOC
author: gemini-cli
date: 2026-05-04
status: active
type: permanent
aliases: [adk-moc, google-adk-map]
---

# Agent Development Kit (ADK) MOC

This map organizes the **Agent Development Kit (ADK)** ecosystem, a code-first toolkit for building and deploying AI agents.

## 🏗️ Core Architecture
- [[agent-development-kit]] - The primary entry point and architectural blueprint.
- [[adk-callbacks-and-lifecycle]] - The Runner model, events, and execution hooks.
- [[adk-go-implementation]] - Reference implementation in Go.

## 🛠️ Services & Primitives
- [[adk-session-service]] - Context, history, and short-term state.
- [[adk-artifact-service]] - Versioned binary data management.
- [[adk-long-term-memory]] - Cross-session recall and knowledge storage.

## 🚦 Orchestration & Coordination
- [[adk-multi-agent-orchestration]] - Hierarchical teams and handoff mechanisms.
- [[workflow-agents]] - Deterministic control flow (Sequential, Parallel, Loop).
- [[adk-advanced-capabilities]] - Multimodal, streaming, and Gemini Live integration.

## 📈 Evaluation & Maintenance
- [[adk-evaluation-framework]] - Benchmarking and multi-turn dataset creation.
- [[agent-observability]] - Traces, spans, and lifecycle hooks for production monitoring.
- [[lit-adk-documentation]] - Core literature source for ADK.

---
## References
- [[agentic-frameworks-moc]]
- [[graph-orchestration]]
- [[multi-agent-systems]]
