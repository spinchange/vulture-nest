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

## The Knowledge Maps
* [[hf-agents-course-moc]]: Theoretical backbone from the Hugging Face course.
* [[mcp-moc]]: Comprehensive guide to the **Model Context Protocol**.

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
* [[openai-swarm]]: Experimental multi-agent orchestration pattern (Handoffs).
* [[openai-agents-sdk]]: Production-ready evolution of Swarm for scalable agent systems.
* [[agent-development-kit]]: Google's code-first toolkit for complex agent systems ([[agent-development-kit|ADK]]).
* [[llamaindex]]: The data-augmented agent toolkit (Retrieval).
* [[langgraph]]: Stateful orchestration for production-ready agents (Control).
* [[pydantic-fastapi-agents]]: Using Pydantic for robust tool schema definition.
* [[alternative-agent-frameworks]]: Exploring CrewAI and Microsoft AutoGen.

## Advanced operational patterns
* [[multi-agent-systems]]: Orchestrating specialized teams of agents.
* [[orchestration-tradeoffs]]: Comparing Swarm (Freedom) vs. ADK (Control).
* [[agentic-rag]]: Autonomous retrieval and self-correction.
* [[graph-orchestration]]: Modelling behavior as deterministic workflows.
* [[chromadb]]: Open-source embedding database for semantic memory.

## Training & Fine-Tuning
* [[function-calling]]: Moving from prompted to learned native agency.
* [[lora]]: Lightweight adaptation for agentic specialized tasks.

## Observability & Evaluation
* [[agent-observability]]: Tracking internal states via Traces and Spans.
* [[agent-evaluation]]: Offline benchmarking and online production monitoring.
* [[llm-as-a-judge]]: Automated grading using separate LLMs.
* [[gaia-benchmark]]: The industry standard for evaluating general AI assistants.

## Protocols & Infrastructure
* [[agentic-protocols]]: The emerging standards ([[mcp-moc|MCP]], A2A) for interoperability.
* [[mcp-moc]]: Comprehensive guide to the **Model Context Protocol**.
* [[spec-agentic-source-orchestrator]]: The "Knowledge Compiler" for automated vault ingestion.
* [[spec-firecrawl-pgvector-pipeline]]: Infrastructure for high-fidelity web scraping.
* [[firecrawl-api-v2-reference]]: Technical specs for the Firecrawl integration.

## Platform & Runtime SDKs
* [[dotnet-agent-integration]]: **Bridge note** — architectural patterns for .NET in the agent loop.
* [[dotnet-moc]]: The .NET ecosystem for high-performance agentic backends.
* [[csharp-moc]]: Building Tier-1 agents with the C# language.
* [[foundry-local]]: Microsoft's hardware-optimized local inference SDK.
* [[local-agent-environments]]: Running models locally via Ollama and LiteLLM.
* [[docker-sandbox]]: Secure environment isolation for agents.
* [[hardware-aware-inference]]: Optimizing for CUDA, MLX, and NPUs.

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
- [[python-moc]]
- [[agent-skills-index]]
* [[code-agents]] - LLM-centric Development & Security
* [[graph-orchestration]] - Multi-agent Workflow Topologies
