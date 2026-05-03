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

Parenthetical tags such as `Freedom`, `Control`, `Handoffs`, and `Retrieval` are local organizing mnemonics for navigation inside this vault. They are not protocol-standard or vendor-endorsed classifications.

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
* [[anthropic-messages-api]]: Direct Claude API request/response semantics and token counting.
* [[anthropic-tool-use]]: Anthropic-specific client/server tool loop behavior.
* [[anthropic-streaming-patterns]]: SSE event flow, streamed tool arguments, and thinking block streaming.
* [[anthropic-adaptive-thinking]]: Model-driven reasoning allocation via `effort`; interleaved thinking for agentic workflows.
* [[anthropic-tool-runner-sdk]]: SDK tool loop automation with compaction for long-running agents.
* [[anthropic-mcp-connector]]: Messages API as MCP client — remote servers without local MCP client.
* [[anthropic-managed-agents-model]]: Hosted agent runtime; Agent/Environment/Session state machine.

## Communication & Formatting
* [[chat-templates]]: Managing System, User, and Assistant roles.
* [[yanp-for-agentic-workflows]]: Why strict metadata is required for agentic parsing.

## Frameworks & toolkits
* [[smolagents]]: Hugging Face's code-first agent library (Freedom).
* [[openai-swarm]]: Experimental multi-agent orchestration pattern centered on handoffs.
* [[openai-agents-sdk]]: Production-oriented OpenAI agent SDK for scalable orchestration.
* [[agent-development-kit]]: Google's code-first toolkit for complex agent systems ([[agent-development-kit|ADK]]).
* [[llamaindex]]: Data-oriented agent toolkit with strong retrieval and workflow support (Retrieval).
* [[langgraph]]: Stateful orchestration framework with explicit control-flow graphs (Control).
* [[pydantic-fastapi-agents]]: Using Pydantic for robust tool schema definition.
* [[alternative-agent-frameworks]]: Exploring CrewAI and Microsoft AutoGen.

## Advanced operational patterns
* [[multi-agent-systems]]: Orchestrating specialized teams of agents.
* [[orchestration-tradeoffs]]: Comparing Swarm (Freedom) vs. ADK (Control).
* [[agentic-rag]]: Autonomous retrieval and self-correction.
* [[graph-orchestration]]: Modelling behavior as deterministic workflows.
* [[chromadb]]: Open-source embedding database for semantic memory.

* [[community-report-generator]]: Automated synthesis of emergent communities via embedding-link hybrid weighting.
## Training & Fine-Tuning
* [[function-calling]]: Moving from prompted to learned native agency.
* [[anthropic-prompt-caching]]: Provider-specific context reuse for repeated prompt prefixes.
* [[lora]]: Lightweight adaptation for agentic specialized tasks.

## Observability & Evaluation
* [[agent-observability]]: Tracking internal states via Traces and Spans.
* [[agent-evaluation]]: Offline benchmarking and online production monitoring.
* [[llm-as-a-judge]]: Automated grading using separate LLMs.
* [[gaia-benchmark]]: Prominent benchmark for evaluating general AI assistants.

## Protocols & Infrastructure
* [[agentic-protocols]]: The emerging standards ([[mcp-moc|MCP]], A2A) for interoperability.
* [[spec-agentic-source-orchestrator]]: The "Knowledge Compiler" for automated vault ingestion.
* [[spec-firecrawl-pgvector-pipeline]]: Infrastructure for high-fidelity web scraping.
* [[firecrawl-api-v2-reference]]: Technical specs for the Firecrawl integration.

* [[synthesis-intelligence-layer]]: Local vault conventions for epistemic risk tiers (T0-T5) and arbitration protocols for autonomous synthesis.
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

## Knowledge Vault Operations
* [[vault-audit-tool-spec]]: Formal schemas for local maintenance utilities.
* [[wiki-pattern-operations]]: Ingest, Query, and Lint cycles.
* [[wiki-as-codebase]]: Treating knowledge as a manageable software project.

* [[lit-llm-wiki]]: Foundational literature for the Compounding Artifact and Wiki-as-Codebase patterns.
* [[lit-foundry-local]]: Documentation for the Azure AI Foundry Local SDK.
* [[lit-language-summaries]]: Core patterns for Python and Racket development.
## See Also
* [[core-patterns-moc]]
* [[programming-languages-moc]]
- [[python-moc]]
- [[agent-skills-index]]
* [[code-agents]] - LLM-centric Development & Security
* [[graph-orchestration]] - Multi-agent Workflow Topologies
