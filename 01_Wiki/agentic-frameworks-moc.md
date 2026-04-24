---
title: Agentic Frameworks MOC
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [agent-theory, autonomous-systems]
---
# Agentic Frameworks MOC

This map covers the mechanics of how autonomous agents reason, act, and interact with knowledge bases.

## The Thought-Action Loop
* [[agent-thought-cycle]]: The core Thought-Action-Observation cycle.
* [[react-pattern]]: Tactical interleaving of reasoning and acting.

## Mechanics of Agency
* [[agent-tools]]: How to define and provide capabilities to an LLM.
* [[agent-actions]]: The "Stop and Parse" loop and tool usage.
* [[code-agents]]: The shift from JSON schemas to executable logic.

## Communication & Formatting
* [[chat-templates]]: Managing System, User, and Assistant roles.
* [[yanp-for-agentic-workflows]]: Why strict metadata is required for agentic parsing.

## Frameworks & toolkits
* [[smolagents]]: Hugging Face's code-first agent library (Freedom).
* [[llamaindex]]: The data-augmented agent toolkit (Retrieval).
* [[langgraph]]: Stateful orchestration for production-ready agents (Control).

## Advanced operational patterns
* [[multi-agent-systems]]: Orchestrating specialized teams of agents.
* [[agentic-rag]]: Autonomous retrieval and self-correction.
* [[graph-orchestration]]: Modelling behavior as deterministic workflows.

## Training & Fine-Tuning
* [[function-calling]]: Moving from prompted to learned native agency.
* [[lora]]: Lightweight adaptation for agentic specialized tasks.

## Observability & Evaluation
* [[agent-observability]]: Tracking internal states via Traces and Spans.
* [[agent-evaluation]]: Offline benchmarking and online production monitoring.
* [[llm-as-a-judge]]: Automated grading using separate LLMs.
* [[gaia-benchmark]]: The industry standard for evaluating general AI assistants.

## Protocols & Infrastructure
* [[agentic-protocols]]: The emerging standards (MCP, A2A) for interoperability.
* [[mcp-architecture]]: The Host/Client/Server model of MCP.
* [[mcp-primitives]]: Tools, Resources, and Prompts.
* [[mcp-client-capabilities]]: Sampling, Elicitation, and Roots.
* [[mcp-transport]]: Stdio vs. HTTP/SSE communication.
* [[mcp-development]]: SDKs and best practices for building servers.
* [[local-agent-environments]]: Running models locally via Ollama and LiteLLM.

## Practical Use Cases
* [[gala-agent-use-case]]: Building a multi-tool gala assistant.
* [[agentic-rag]]: Implementation patterns for dynamic data retrieval.

## Specialized Domains
* [[agents-in-games]]: Autonomous NPCs and emergent storytelling.
* [[pokemon-battle-agent]]: case study in turn-based environment interaction.

## Development & Operations
* [[vault-audit-tool-spec]]: Formal schemas for local maintenance utilities.
* [[wiki-pattern-operations]]: Ingest, Query, and Lint cycles.
* [[wiki-as-codebase]]: Treating knowledge as a manageable software project.

---
## See Also
* [[core-patterns-moc]]
* [[programming-languages-moc]]
