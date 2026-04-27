---
title: Workflow Agents ([[agent-development-kit|ADK]])
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - deterministic-agents
  - sequential-agent
  - parallel-agent
  - loop-agent
type: permanent
---

# Workflow Agents (ADK)

**Workflow Agents** are specialized, deterministic controllers in the [[agent-development-kit|ADK]] that manage the execution flow of other agents. Unlike `LlmAgent`s, which use LLMs to decide their next action, Workflow Agents follow predefined patterns for orchestration.

## Core Characteristics
*   **Deterministic:** Execution paths are fixed and predictable.
*   **No LLM Logic:** They do not use language models to determine flow (though their sub-agents might).
*   **Orchestrators:** Their primary role is to manage one or more `sub_agents`.

## Types of Workflow Agents

### 1. Sequential Agent (`SequentialAgent`)
Executes a list of `sub_agents` in a strict, linear order.
*   **Use Case:** Multi-step pipelines where Step B depends on the completion/output of Step A (e.g., Generate -> Review -> Publish).

### 2. Parallel Agent (`ParallelAgent`)
Executes multiple `sub_agents` concurrently.
*   **Use Case:** Independent tasks that can be performed simultaneously to reduce latency (e.g., searching three different data sources at once).
*   **Note:** Events from sub-agents may be interleaved in the session history.

### 3. Loop Agent (`LoopAgent`)
Repeatedly executes its `sub_agents` until a specific exit condition is met.
*   **Use Case:** Iterative processes such as self-correction, data polling, or recursive decomposition.

## Comparison: Workflow Agents vs. LLM Agents

| Feature | Workflow Agent | LLM Agent (`LlmAgent`) |
| :--- | :--- | :--- |
| **Flow Control** | Deterministic (Sequence, Parallel, Loop) | Dynamic (LLM-driven) |
| **Logic Source** | Predefined Code/Structure | Instructions & Model Reasoning |
| **Predictability** | High | Variable |
| **Best For** | Structured, rigid processes | Adaptive, complex reasoning |

## Related Patterns
*   [[multi-agent-systems]]: Workflow agents often sit at the top of a tree, managing specialized sub-agents.
*   [[pattern-dynamic-delegation]]: While workflow agents use structural delegation, `LlmAgent`s use dynamic delegation via tools or transfer.

---
*Source: [[lit-adk-documentation]]*

