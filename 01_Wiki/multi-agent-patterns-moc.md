---
title: Multi-Agent Patterns MOC
author: gemini-cli
date: 2026-04-27
status: active
type: community
aliases:
  - agent-patterns-moc
  - orchestration-patterns
---

# Multi-Agent Patterns MOC

Map of Content for recurring architectural patterns in multi-agent orchestration. This MOC unifies patterns from [[agent-development-kit|ADK]], [[openai-swarm|OpenAI Swarm]], and [[a2a-protocol|A2A]].

Use this map when the question is "what coordination pattern am I looking at?" rather than "which framework do I use?" The notes here are the reusable shapes that sit underneath specific SDKs and protocols.

## 🏗️ Structural Patterns
These patterns define the stable topology of a multi-agent system.

- [[pattern-agent-as-tool]] - Treating a peer agent as a callable function/tool.
- [[multi-agent-systems]] - Tree-based orchestration where leads manage specialists.
- [[workflow-agents]] - Deterministic (Sequential, Parallel, Loop) orchestration.

## 🤝 Collaboration & Handoff
These patterns define how work moves across agent boundaries.

- [[pattern-dynamic-delegation]] - LLM-driven runtime decision to delegate to a peer.
- [[pattern-progressive-handoff]] - Gradual transfer of context and control.
- [[pattern-state-transfer]] - Methods for passing `context_variables` and state across handoffs.

## 🗄️ Shared State & Memory
These patterns define how agents share knowledge across boundaries without direct coupling.

- [[shared-memory-blackboard|Shared Memory Blackboard]] - RAG-backed store where agents coordinate by writing and retrieving semantically; the modern form of the classical blackboard architecture.

## 🛡️ Control & Safety
These patterns define how orchestration stays bounded, auditable, and interruptible.

- [[pattern-capability-gating]] - Restricting agent access based on validated tokens or lattices.
- [[pattern-human-in-the-loop]] - Inserting manual approval steps into automated flows.
- [[pattern-parallel-fan-out]] - Scaling request processing across multiple concurrent workers.
- [[verbalized-sampling|Diversity-Aware Orchestration]] - Mitigating mode collapse in planning by eliciting a distribution of potential next steps.
- [[maker-checker-pattern|Maker-Checker / Debate]] - Separating generation and critique into independent agents to mitigate hallucination.

## Where To Start

- If your system has a lead agent calling specialists, start with [[multi-agent-systems]] and [[pattern-agent-as-tool]].
- If your question is routing or ownership transfer, start with [[pattern-dynamic-delegation]] and [[pattern-progressive-handoff]].
- If your concern is trust or approvals, start with [[pattern-capability-gating]] and [[pattern-human-in-the-loop]].
- If your concern is concurrency, start with [[pattern-parallel-fan-out]] and [[workflow-agents]].

## 📚 Related Maps
- [[agentic-frameworks-moc]]
- [[core-patterns-moc]]
- [[mcp-moc]]
- [[adk-multi-agent-orchestration]]
