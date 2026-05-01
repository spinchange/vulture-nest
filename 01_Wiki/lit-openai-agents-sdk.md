---
title: 'Literature: OpenAI Agents SDK'
author: gemini-cli
date: '2026-05-01'
status: active
aliases:
  - lit-openai-agents
type: literature
source: 'https://openai.github.io/openai-agents-python/'
---

# Literature: OpenAI Agents SDK

## Overview
The official documentation for the **OpenAI Agents SDK** provides a comprehensive guide to building production-ready agentic applications. It supersedes the experimental [[openai-swarm]] with a focus on durability, safety, and multi-agent orchestration.

## Key Concepts

### Agents and Handoffs
- **Agents** are LLMs equipped with instructions, tools, and handoffs.
- **Handoffs** are a specific type of tool that transfers control from one agent to another.
- Control is managed by a "manager" agent or handled via direct handoffs where the specialist becomes the active agent.

### Orchestration Patterns
- **Orchestrating via LLM**: Agents autonomously plan and delegate using tools and handoffs.
- **Orchestrating via Code**: Developers determine the flow of agents through imperative Python logic.
- Mixed patterns allow for flexible yet controlled workflows.

### Model Context Protocol (MCP)
- The SDK provides native support for **[[mcp-architecture|MCP]]**.
- **`MCPServer`** base class for building custom servers.
- Integration allows agents to use any MCP-compliant tool or resource.

### Advanced Features
- **Guardrails**: Input and output validation to ensure safety and correctness.
- **Tracing**: Built-in visualization and debugging of agentic flows.
- **Sandbox Agents**: Execution in isolated workspaces with persistent files and sessions.
- **Human-in-the-Loop**: Integrated patterns for manual approval of agent actions.

## Ingestion Details
- **Date Ingested**: 2026-05-01
- **Tool**: Firecrawl Pipeline (Scrape/Crawl)
- **Pages Processed**: 15
- **Status**: Indexed in Supabase (pgvector)

## Connections
- [[openai-agents-sdk]] (Permanent Note)
- [[mcp-moc]]
- [[agent-thought-cycle]]
- [[pattern-human-in-the-loop]]
