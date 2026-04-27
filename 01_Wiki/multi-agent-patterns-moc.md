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

## 🏗️ Structural Patterns
- [[pattern-agent-as-tool]] - Treating a peer agent as a callable function/tool.
- [[multi-agent-systems]] - Tree-based orchestration where leads manage specialists.
- [[workflow-agents]] - Deterministic (Sequential, Parallel, Loop) orchestration.

## 🤝 Collaboration & Handoff
- [[pattern-dynamic-delegation]] - LLM-driven runtime decision to delegate to a peer.
- [[pattern-progressive-handoff]] - Gradual transfer of context and control.
- [[pattern-state-transfer]] - Methods for passing `context_variables` and state across handoffs.

## 🛡️ Control & Safety
- [[pattern-capability-gating]] - Restricting agent access based on validated tokens or lattices.
- [[pattern-human-in-the-loop]] - Inserting manual approval steps into automated flows.
- [[pattern-parallel-fan-out]] - Scaling request processing across multiple concurrent workers.

## 📚 Related Maps
- [[agentic-frameworks-moc]]
- [[core-patterns-moc]]
- [[mcp-moc]]
- [[adk-multi-agent-orchestration]]