---
title: Orchestration Tradeoffs: Swarm vs. ADK
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [swarm-vs-adk, agent-orchestration-comparison]
---
# Orchestration Tradeoffs: Swarm vs. ADK

This comparison explores the philosophical and technical differences between **OpenAI Swarm/Agents SDK** and **Google Agent Development Kit (ADK)**, specifically in the context of **Vault Maintenance**.

## Philosophy: Freedom vs. Control

| Feature | OpenAI Swarm / Agents SDK | Google ADK |
| :--- | :--- | :--- |
| **Core Pattern** | **Handoffs**: Dynamic routing where agents return the next agent. | **Workflows**: Deterministic control via Sequential, Parallel, and Loop agents. |
| **Orchestration** | Decentralized: The active agent decides who is next. | Centralized: A "Runner" or "Workflow Agent" governs the execution flow. |
| **State** | Lightweight/Stateless: The client/host manages conversation history. | Managed: Built-in support for Sessions, State, and long-term Memory. |
| **Primary Goal** | **Flexibility**: Enabling agents to "swarm" around a problem. | **Reliability**: Ensuring complex tasks follow a predictable path. |

## Applicability to Vault Maintenance

### 1. Ingestion (Predictable Pipeline)
*   **Winner: Google ADK**
*   **Reasoning**: Ingestion follows a strict sequence: `Read Raw` -> `Synthesize Note` -> `Update MOC` -> `Update Log`. ADK's `SequentialAgent` ensures these steps never occur out of order, providing high reliability for protocol-heavy tasks like YANP compliance.

### 2. Semantic Link Discovery (Exploratory Research)
*   **Winner: OpenAI Swarm**
*   **Reasoning**: Discovery is non-linear. An agent might "handoff" to a specialized `ChromaDiscoveryAgent`, which might then decide to hand off to a `SubjectMatterExpertAgent` based on the content found. Swarm's dynamic routing allows for more creative "travel" through the knowledge graph.

### 3. Full Vault Audit (Resource Intensive)
*   **Winner: Google ADK**
*   **Reasoning**: Auditing 100+ notes requires efficient resource management. ADK's `ParallelAgent` can trigger multiple audit checks (YANP, Orphans, Broken Links) concurrently, while its `Artifact` management handles the resulting data reports more robustly.

## Synthesis: The "Hybrid" Maintenance Strategy
For a YANP-compliant vault, the ideal architecture leverages both philosophies:
1.  **ADK for "The Factory"**: Use deterministic workflows for daily maintenance, indexing, and automated linting.
2.  **Swarm for "The Lab"**: Use flexible handoffs for creative synthesis, research tasks, and building "Knowledge Bridges" across disparate topics.

---
## References
* [[openai-swarm]]
* [[openai-agents-sdk]]
* [[agent-development-kit]]
* [[agentic-frameworks-moc]]
* [[wiki-as-codebase]]
