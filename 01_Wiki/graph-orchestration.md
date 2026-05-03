---
title: Graph Orchestration
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [stateful-orchestration, event-driven-agents, workflow-design]
---
# Graph Orchestration

**Graph Orchestration** is a design pattern where agentic behavior is modeled as a directed graph, ensuring state persistence and deterministic control over LLM workflows.

## Core Opinion

Graph orchestration is what you use when an agentic system should behave like a managed process instead of a free-form conversation. The key move is to make transitions explicit: the system does not merely "decide what to do next" in an unstructured loop, it advances through named steps with known routing rules and durable state.

In the Nest, this pattern matters whenever reproducibility, resumability, or human approval boundaries matter more than raw conversational freedom.

## Structural Components

* **State:** The "living document" that moves between steps. This is the load-bearing part of the design: prompts, tool outputs, checkpoints, and control flags all accumulate here.
* **Nodes:** The computational steps, usually expressed as [[python]] logic or framework runnables. Nodes may call models, tools, or deterministic code.
* **Edges:** The routing paths. Some are direct, while others are conditional and inspect the current state to decide the next transition.
* **Entry/Exit Signals:** Real graph runtimes usually model an explicit start and end boundary rather than assuming an endless loop.

## Why Use It

Choose graph orchestration when the problem sounds like one of these:

- "This workflow has named phases and cannot just improvise forever."
- "We need to pause, resume, or recover from interruption without losing state."
- "A human approval gate or external event should control whether the system advances."
- "We want a visible topology for debugging, tracing, or replay."

If the task is simple and mostly linear, [[workflow-agents]] may be enough. If the task is primarily open-ended reasoning with lightweight tool calls, a looser [[agent-thought-cycle]] or framework-native agent loop may be cheaper.

## Control Model

Graph orchestration sits between two extremes:

- **Looser conversational agents:** The model reasons step by step and the host reacts, but control flow is mostly implicit.
- **Rigid scripted workflows:** Every branch is hard-coded with little adaptive behavior.

The graph pattern keeps the execution surface explicit while still allowing adaptive work *inside* nodes. That is why it pairs well with tool use, retrieval, or human-in-the-loop review.

## Framework Instantiations

* **[[langgraph]]:** The clearest example of explicit stateful graph control. Its emphasis is durable execution, checkpoints, interrupts, and reruns. See [[lit-langgraph]].
* **[[llamaindex]]:** Approaches the same space through async workflows and typed events. This is closer to event-driven orchestration than purely edge-driven graph routing, but the practical role is similar.
* **[[workflow-agents]]:** ADK's deterministic orchestration layer. These are not general graph engines, but they occupy the same design family: explicit orchestration over sub-agents instead of unconstrained autonomy.

## Relationship to Other Agent Patterns

- [[multi-agent-systems]] uses graph orchestration when the manager needs stable routing among workers rather than ad hoc delegation.
- [[pattern-progressive-handoff]] models ownership transfer between agents; graph orchestration models the workflow topology around such transfers.
- [[code-agents]] can run *inside* graph nodes, but code generation is an execution style, not an orchestration model.
- [[agentic-rag]] often benefits from graph control when retrieval, verification, and synthesis should be separate stages instead of one blended loop.

## Start Here

1. Read [[langgraph]] if you need the most explicit control-flow implementation.
2. Read [[workflow-agents]] if your use case is structured orchestration inside ADK rather than a general graph runtime.
3. Read [[llamaindex]] if your mental model is event-driven workflows tied closely to retrieval and data agents.
4. Return to [[agentic-frameworks-moc]] once you know whether your question is about orchestration, execution style, or protocol boundaries.

## See Also
* [[index]]
* [[langgraph]]
* [[llamaindex]]
* [[workflow-agents]]
* [[multi-agent-systems]]
* [[code-agents]]
* [[agentic-frameworks-moc]]
