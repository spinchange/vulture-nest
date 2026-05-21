---
title: Wiki Index
author: gemini-cli
date: 2026-04-25
status: active
type: community
---
# Wiki Index

Master navigation hub for the vault's MOCs, specs, handoffs, literature, and system references.

## Maps of Content
* [[core-patterns-moc]] - Philosophy & YANP
* [[pkm-history-moc]] - Lineage & Vision
* [[pkm-methods-moc]] - Systems & Workflow
* [[experiments-moc]] - Lab notes, build logs, and workflow trials; now covers the 04_Experiments/ pipeline
* [[agentic-frameworks-moc]] - Agency & Mechanics
* [[cognitive-architectures]] - Chain of Thought Blueprint
* [[agentic-tdd-patterns]] - Executable Intent & EDD
* [[orchestration-tradeoffs]] - Swarm vs. [[agent-development-kit|ADK]] Comparison
* [[hf-agents-course-moc]] - Hugging Face Agents Course Reference
* [[mcp-moc]] - Model Context Protocol Reference
* [[rust-mcp-patterns]] - High-Performance Server Design
* [[rust-macros]] - Metaprogramming Patterns
* [[programming-languages-moc]] - Dev Environments
* [[dotnet-moc]] - .NET Ecosystem Reference
* [[csharp-moc]] - C# Language Reference
* [[wpf-moc]] - Windows Desktop UI Hub
* [[powershell-moc]] - Automation, Objects, & Standards
* [[ps-automation-spec]] - Executable Knowledge Standard
* [[executable-note-standard]] - Embedded Logic Standard
* [[javascript-moc]] - Runtimes & Desktop Apps
* [[hybrid-retrieval-spec]] - Deterministic + Semantic Strategy (Design)

## Blueprint Specs (How to Build It)
Status legend: implemented references describe working artifacts; handoff references describe in-progress or historical design/build phases.
* [[spec-memory-mcp]] - Memory MCP Server: SQLite backend, session + vault scopes, commit/search/prune tools
* [[spec-chatgpt-web-mcp-wrapper]] - Remote MCP wrapper for ChatGPT web access to Vulture Nest
* [[rust-tier-0-patterns]] - Rust Safe Core: serde-validated capability gate + Tier-0→Tier-1 state transfer
* [[spec-knowledge-gardening]] - Vault Gardening Protocol: thin nodes, orphans, drift, merge/split/wire cadence
* [[spec-visual-vault-language]] - Mermaid.js Standards: flowcharts, state machines, lattice diagrams, sequences
* [[spec-firecrawl-pgvector-pipeline]] - External Source Ingestion: Firecrawl → Postgres/Supabase + pgvector RAG
* [[spec-agentic-source-orchestrator]] - Master Orchestration Layer: Unified roles, lifecycle, policy, and epistemic gates
* [[synthesis-intelligence-layer]] - Epistemic gates: T0–T5 classifier, conflict templates, provenance generator, synthesis rubric
* [[codex-orchestrator-build-handoff-2026-04-29]] - Orchestrator Infrastructure Build (Codex)
* [[claude-orchestrator-synthesis-handoff-2026-04-29]] - Orchestrator Synthesis Intelligence (Claude)

## Agent Development Kit (ADK)
* [[agent-development-kit]] - Core Overview
* [[adk-session-service]] - Session Management, State Prefix Scoping & ToolContext Patterns *(depth-expanded 2026-05-19)*
* [[adk-artifact-service]] - Binary & File Data Lifecycle
* [[adk-callbacks-and-lifecycle]] - Hooking into Agent Execution
* [[adk-long-term-memory]] - In-Memory / Database / VertexAI Memory Services & Cross-Session Recall *(depth-expanded 2026-05-19)*
* [[adk-multi-agent-orchestration]] - Hierarchical & Parallel Patterns
* [[adk-evaluation-framework]] - Trajectory-Based Assessment
* [[adk-advanced-capabilities]] - Planning, Thinking, & Code Execution
* [[adk-go-implementation]] - Native Performance Reference
* [[code-agents]] - When agents execute generated code instead of narrow tool schemas

## Hermes Agent
* [[hermes-moc]] - Dedicated navigation map for the Hermes cluster, including conceptual notes, source-grounded literature, and runtime specs
* [[hermes-agent]] - Provider-agnostic agent environment spanning CLI, gateway, skills, memory, and durable background systems
* [[hermes-bounded-memory]] - Small prompt-resident memory paired with session search and optional external providers
* [[hermes-gateway]] - Messaging-platform daemon layer that exposes the same agent across Telegram, Discord, Slack, and more
* [[hermes-provider-abstraction]] - Declarative provider profiles, api-mode transport contracts, auxiliary routing, and live model switching across a stable agent shell
* [[hermes-prompt-assembly]] - System-prompt construction layer covering environment grounding, skill-index caching, and prioritized context-file injection
* [[hermes-context-compression]] - Compression as a lineage-preserving session boundary with memory hooks, summary fallbacks, and explicit rollover semantics
* [[hermes-command-control-plane]] - Operator-facing slash-command layer that manages sessions, models, tools, gateway state, and background runtime behavior across CLI and messaging
* [[hermes-profiles]] - Separate Hermes home directories that isolate config, memory, sessions, skills, gateway state, and cron jobs into distinct long-lived agents
* [[hermes-skills-system]] - On-demand procedural knowledge layer built around `SKILL.md`, progressive disclosure, and agent-managed skills
* [[hermes-cron]] - Gateway-backed scheduler for fresh-session autonomous runs, delivery routing, script-only jobs, and chained pipelines
* [[hermes-subagent-delegation]] - In-turn isolated child-agent branching via `delegate_task`, with explicit context passing and parallel fan-out
* [[hermes-kanban]] - Durable SQLite-backed coordination board for named Hermes profiles, resumable task handoffs, and multi-agent workflows
* [[hermes-tool-registry]] - Central registry, toolset policy layer, dynamic schemas, and MCP-discovered tools unified into one callable surface
* [[hermes-vs-adk-openai-agents-langgraph]] - Comparative note positioning Hermes as a persistent agent environment relative to ADK, OpenAI Agents SDK, and LangGraph
* [[lit-hermes-architecture]] - Literature: official Hermes docs on architecture, agent loop, slash-command surfaces, and built-in tools
* [[spec-hermes-agent-loop]] - Descriptive spec: shared turn loop, message alternation, tool dispatch, and persistence invariants across Hermes surfaces

## OpenAI Orchestration
* [[openai-swarm]] - Experimental handoff-oriented multi-agent framework centered on conversational routing.
* [[openai-agents-sdk]] - Production Python SDK for runner loops, guardrails, tracing, and multi-agent handoffs.
* [[openai-symphony]] - Tracker-native service specification for background coding-agent orchestration.
* [[openai-symphony-orchestration-state-machine]] - Internal claim states, retries, reconciliation, and bounded worker attempts.
* [[openai-symphony-workflow-contract]] - `WORKFLOW.md` as repository-owned control artifact for config, hooks, and prompt policy.
* [[openai-symphony-trust-boundary]] - Trusted-environment framing, implementation-defined safety posture, and harness hardening guidance.
* [[lit-openai-symphony-spec]] - Literature: announcement + SPEC grounding for the Symphony service model.
* [[hermes-vs-openai-symphony]] - Contrast between issue-native orchestration and Hermes's persistent agent environment.

## Multi-Agent Pattern Language
* [[pattern-supabase-flask-integration]] - Flask + Supabase: module-level singleton, RLS as auth layer, method-chain query API
* [[pattern-dynamic-delegation]] - Agent A calls Agent B, waits for result (delegation primitive)
* [[pattern-state-transfer]] - Flat key-value working memory across agent boundaries
* [[pattern-capability-gating]] - Lattice enforcement before every delegation edge
* [[pattern-parallel-fan-out]] - Concurrent dispatch to N agents + barrier sync
* [[pattern-agent-as-tool]] - Expose complete agent as opaque callable in tool roster
* [[pattern-progressive-handoff]] - Three-phase atomic transfer of task ownership
* [[pattern-human-in-the-loop]] - Mid-task pause/resume for human input or authorization
* [[graph-orchestration]] - Deterministic state-machine workflows for multi-step agent systems

## System / Protocol
* [[experiment-capture-protocol]] - Lightweight YANP variant for 04_Experiments/; covers runs and adversarial debates

## Session Types
* [[session-types]] - Linear/affine types, duality, MPST — the protocol-sequence complement to capability sets
* [[session-types-in-rust]] - Phantom type encoding; `session-types` and `dialectic` crates; affine limitation and workaround
* [[session-types-mcp-mapping]] - MCP lifecycle expressed as a binary session type; phantom-typed SDK sketch (draft)

## Protocol Bridges
* [[agentic-protocols]] - [[mcp-moc|MCP]]↔Agent Spec
* [[mcp-best-practices]] - Operational scaling patterns for large MCP tool surfaces
* [[mcp-authorization]] - OAuth 2.1 and consent flow for remote MCP servers
* [[csharp-mcp-sdk]] - High-Performance .NET Tooling
* [[dotnet-agent-integration]] - Bridging Ecosystems
* [[csharp-records]] - Immutable Data Models
* [[csharp-pattern-matching]] - Advanced Control Flow
* [[inter-agent-handoff-protocol]] - Shared Resume, Seam, and Reply-Slot Process

## Roadmaps / Active Work
* [[productivity-roadmap-2026-04-27]] - April 2026 fleet roadmap: seam tightening, experiment capture, debate logging, git attribution

## Multi-Agent Handoffs (Session Seams)
Session seams are bounded resume points that capture current state, immediate next moves, and ownership transitions between agents.
* [[gemini-post-synthesis-librarian-handoff-2026-05-01]] - Gemini: promote Supabase Flask source, register chatgpt_web_mcp_wrapper, sync graph (Active)
* [[codex-validation-hardening-handoff-2026-04-28]] - Hardening: broken links, frontmatter, & YANP compliance (Complete)
* [[codex-roadmap-sprint-handoff-2026-04-27]] - Codex: implement seams, debate log, experiment scaffold, git attribution (Complete)
* [[gemini-roadmap-sprint-handoff-2026-04-27]] - Gemini: 04_Experiments/ structure, visitor-directives, index (Complete)
* [[codex-gemini-cleanup-handoff-2026-04-27]] - Gemini cleanup boundary (Complete)
* [[claude-community-summary-handoff]] - Phase 2: Community Summarization (Pending follow-on phase; verify freshness before resuming)
* [[gemini-build-sprint-handoff]] - Ingestion & Clustering Path (Complete)
* [[claude-blueprint-handoff-2026-04-27]] - Technical Specifications Path (Complete)

## Emergent Communities
* [[community-living-knowledge-system]] - The Vault as a Compiler
* [[community-protocol-trust-substrate]] - Type-Safe Agent Governance
* [[community-polyglot-agent-platform]] - Tiered Language Architectures
* [[the-vulture-portal]] - High-Density Web Interface
* [[the-compounding-artifact]] - The Core Thesis (from LLM Wiki)
* [[community-report-generator]] - Algorithm: k-means → LLM → Community Report notes

## Community Reports (Synthesis)
* [[agentic-protocols-community-report|Agentic Protocols]] - Communication & Thought Cycles
* [[dotnet-csharp|Dotnet & C#]] - Ecosystem & SDK Patterns
* [[frameworks-eval|Frameworks & Evaluation]] - ADK vs. Swarm Comparison
* [[lattice-interop|Lattice & Interop]] - Capability Lattice Theory
* [[mcp-ecosystem|MCP Ecosystem]] - Server & Client Architecture
* [[pkm-history|PKM History]] - Genealogy of Personal Knowledge
* [[rust-type-systems|Rust Type Systems]] - Memory Safety & Session Types
* [[vault-systems|Vault Systems]] - Gardening & Maintenance Standards

## Verbalized Sampling
* [[verbalized-sampling]] - Core concept: typicality bias, mode collapse, diversity as retrieval problem
* [[verbalized-sample-skill]] - Operational protocol for distribution-aware reasoning
* [[mode-anchored-departure]] - Approach B mechanism: modal anchor, P≈ stat, departure enumeration, ParseWarning taxonomy
* [[verbalized-sampling-ps-scripts]] - Approach A/B/C comparison; script design rationale
* [[verbalized-sampling-experiment]] - Audio series processing workflow and findings
* [[lit-verbalized-sampling-paper]] - Paper summary: 2510.01171v3 (P% constraint, empirical gains)

## Anthropic API
* [[anthropic-broad-intake-packet-2026-05-02]] - Intake packet that defined the broader Anthropic documentation expansion lane
* [[codex-anthropic-docs-ingestion-handoff-2026-05-02]] - Execution seam for the first bounded Anthropic ingestion batch
* [[gemini-anthropic-docs-ingestion-handoff-2026-05-02]] - Librarian/ingester seam for the same first Anthropic batch
* [[lit-anthropic-prompt-engineering]] - Literature: official prompt-engineering guidance, including XML tags as structural delimiters and tagged few-shot examples
* [[lit-anthropic-messages-api]] - Literature: direct Claude API fundamentals, streaming, tool use, and context caching
* [[lit-anthropic-advanced-capabilities]] - Literature: adaptive thinking, batch execution, files API, tool extensions, managed agents
* [[lit-anthropic-sdk-service-2026]] - Literature: Batch 2 sub-batch E — SDKs, model lineup, service tiers, versioning, beta headers, context editing
* [[lit-anthropic-tool-use-depth]] - Literature: Batch 2 sub-batch A — tool-use full depth, server tools, Tool Runner SDK, MCP connector, tool search
* [[lit-anthropic-thinking-capabilities]] - Literature: Batch 2 sub-batch B — extended thinking, adaptive thinking, effort parameter
* [[lit-anthropic-async-data-apis]] - Literature: Batch 2 sub-batch C — batch processing, Files API, token counting, Models API
* [[lit-anthropic-managed-agents]] - Literature: Batch 2 sub-batch D — Managed Agents quickstart, agent setup, sessions, environments, tools, events
* [[anthropic-messages-api]] - Direct Messages API request/response model and token counting
* [[anthropic-xml-prompt-structuring]] - XML-style prompt markup as boundary markers for instructions, context, examples, and inputs inside Claude text prompts
* [[anthropic-xml-tags-cheat-sheet]] - Compact reference with canonical tag skeletons, few-shot wrappers, and multi-document layouts for Claude prompts
* [[anthropic-tool-use]] - Client/server tool execution loop
* [[anthropic-streaming-patterns]] - SSE event flow, streamed tool arguments, and thinking block streaming
* [[anthropic-error-handling]] - Errors, request-size limits, and rate-limit behavior
* [[anthropic-prompt-caching]] - Prompt-prefix reuse, 1-hour TTL, thinking and batch interactions
* [[anthropic-adaptive-thinking]] - Adaptive thinking mode, effort parameter, interleaved thinking, thinking display
* [[anthropic-message-batches]] - Async batch execution, 50% discount, extended output beta
* [[anthropic-files-api]] - Upload-once file storage for reuse across API calls
* [[anthropic-mcp-connector]] - Server-side MCP client via Messages API, allowlist/denylist toolset config
* [[anthropic-tool-runner-sdk]] - SDK tool loop automation with compaction support
* [[anthropic-managed-agents-model]] - Hosted agent runtime: Agent + Environment + Session model
* [[anthropic-agentic-loop]] - Tool-use contract, client loop (tool_use→tool_result), server-side loop, pause_turn
* [[anthropic-server-tools]] - Server-executed tools, server_tool_use block, pause_turn continuation, ZDR, domain filtering
* [[anthropic-claude-4-model-family]] - Model lineup (Opus 4.7, Sonnet 4.6, Haiku 4.5), capabilities matrix, retirement dates, Models API

## Literature Notes (Grounded Sources)
* [[lit-supabase-flask-quickstart]] - Literature: Supabase Flask Quickstart (Python client, RLS, module-level singleton, method-chain query API)
* [[lit-chatgpt-web-mcp-guidance]] - Literature: ChatGPT Web MCP Guidance (remote only, write confirmations, plan gating)
* [[lit-mcp-authorization]] - Literature: MCP Authorization Specification (OAuth 2.1, RFC 9728, audience binding, step-up)
* [[claude-mcp-authorization-handoff-2026-05-01]] - Graph-integration seam for the MCP authorization literature note
* [[lit-mcp-security-best-practices]] - Literature: MCP Security Best Practices (confused deputy, token passthrough, SSRF, session hijacking, local compromise, scope minimization)
* [[lit-llm-wiki]] - Literature: LLM Wiki (Foundational Pattern)

* [[lit-typescript-handbook]] - TypeScript Handbook (structural types, discriminated unions)
* [[lit-rust-programming-language]] - The Rust Book (ownership, fearless concurrency)
* [[lit-mcp-architecture]] - MCP Architecture Overview (primitives, lifecycle, transports)
* [[lit-python-standard-library]] - Python stdlib (asyncio, typing, concurrency)
* [[lit-skills-agent-behavior]] - Skills vs. Vault Knowledge (active/passive split)
* [[lit-adk-documentation]] - ADK Documentation (multi-agent toolkit)
* [[lit-openai-swarm]] - OpenAI Swarm (handoffs, context_variables)
* [[claude-symphony-graph-handoff-2026-05-03]] - Archived verification seam for the Symphony literature-note expansion

## Sources (Raw Data)
* [00_Raw/LLM Wiki.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/LLM%20Wiki.md)
* [00_Raw/llm-wiki-pattern.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/llm-wiki-pattern.md)
* [00_Raw/memex-summary.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/memex-summary.md)
* [00_Raw/zettelkasten-summary.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/zettelkasten-summary.md)
* [00_Raw/python-summary.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/python-summary.md)
* [00_Raw/python-standard-library.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/python-standard-library.md)
* [00_Raw/racket-summary.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/racket-summary.md)
* [00_Raw/the-rust-programming-language.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/the-rust-programming-language.md)
* [00_Raw/typescript-handbook.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/typescript-handbook.md)
* [00_Raw/ms-learn-csharp-overview.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/ms-learn-csharp-overview.md)
* [00_Raw/ms-learn-dotnet-fundamentals.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/ms-learn-dotnet-fundamentals.md)
* [00_Raw/ms-learn-wpf-overview.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/ms-learn-wpf-overview.md)
* [00_Raw/ms-learn-ef-core-overview.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/ms-learn-ef-core-overview.md)
* [00_Raw/ms-learn-aspnet-core-overview.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/ms-learn-aspnet-core-overview.md)
* [00_Raw/ms-repo-poshwiki.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/ms-repo-poshwiki.md)
* [00_Raw/PoShWiKi/](https://github.com/spinchange/vulture-nest/tree/main/00_Raw/PoShWiKi) - Minimal [[powershell|PowerShell]] 7 Wiki for Agents
* [00_Raw/agent-actions-unit.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/agent-actions-unit.md)
* [00_Raw/openai-agents-and-swarm.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/openai-agents-and-swarm.md)
* [00_Raw/agent-note-conventions.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/agent-note-conventions.md)
* [00_Raw/agent-knowledge-vault.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/agent-knowledge-vault.md)
* [00_Raw/agent-skills-index.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/agent-skills-index.md)
* [00_Raw/agent-configuration-sync-strategy.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/agent-configuration-sync-strategy.md)
* [00_Raw/adk-documentation.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/adk-documentation.md)
* [00_Raw/foundry-local.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/foundry-local.md)
* [00_Raw/hf-agents-course-unit1.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/hf-agents-course-unit1.md)
* [00_Raw/hf-agents-course-unit2.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/hf-agents-course-unit2.md)
* [00_Raw/hf-agents-bonus1.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/hf-agents-bonus1.md)
* [00_Raw/hf-agents-bonus2.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/hf-agents-bonus2.md)
* [00_Raw/hf-agents-unit3.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/hf-agents-unit3.md)
* [00_Raw/hf-agents-bonus3.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/hf-agents-bonus3.md)
* [00_Raw/hf-agents-final-units.md](https://github.com/spinchange/vulture-nest/blob/main/00_Raw/hf-agents-final-units.md)
* [00_Raw/mcp/](https://github.com/spinchange/vulture-nest/tree/main/00_Raw/mcp) - Anthropic Model Context Protocol Documentation
* [00_Raw/anthropic/](https://github.com/spinchange/vulture-nest/tree/main/00_Raw/anthropic) - Anthropic direct Claude API source captures
* [[docker-sandbox]] - Agent Security & Isolation
* [[pydantic-fastapi-agents]] - Tool Schema Design
* [[hitl-ui-patterns]] - Human Approval Workflows
* [[hardware-aware-inference]] - Hardware Acceleration Reference
* [[alternative-agent-frameworks]] - CrewAI & AutoGen Comparison

## System Layer
* [Vault Pulse Dashboard](dashboard.html) - Real-time Health & Metrics
* [[log|System Log]]
* [[visitor-directives|Visitor Directives (Multi-Agent Protocol)]]
* [[github-deployment|GitHub Deployment (Cloud Daemon)]]
* [[poshwiki-tools|PoShWiKi Tools API]]
* [[tool-registry|Tool Registry (Machine-Readable)]]


## Structure & Meta-Knowledge
- [[foundational-vault-docs-summary-2026-05-04]] - High-level synthesis of the Nest's core documentation and conventions.
### Project Meta-Knowledge
- [[vulture-nest]] - The primary knowledge base for localhost:lyra.
- [[vulture-mcp]] - Implementation details for the Nest's custom MCP server.
- [[the-vulture-portal]] - The static dashboard and graph visualization layer.
- [[community-living-knowledge-system]] - The long-term vision for the Nest.
- [[wiki-expansion-opportunities-2026-05-02]] - Strategic roadmap for vault content growth.
