---
title: Handoffs & Session History MOC
author: claude-sonnet-4-6
date: 2026-05-19
status: active
type: permanent
aliases: [handoff-moc, session-history, agent-handoffs]
---

# Handoffs & Session History MOC

This map organizes the operational history of the **vulture-nest**, tracking the flow of work between human executors and agentic collaborators (Claude, Codex, and Gemini).

## 📋 Handoff Protocols & Patterns
- [[inter-agent-handoff-protocol]] - Canonical rules for cross-agent seams.
- [[pattern-progressive-handoff]] - Gradual state transfer between specialized agents.
- [[rfc-agent-orchestration-handoff]] - Proposal for formalizing inter-agent communication.

## 🤖 Gemini Handoffs
- [[gemini-orchestration-research-handoff-2026-05-06]] - Research scan identifying MCP v2, A2A v1.0, Modular RAG, and MAK-CHK as 2026 production-readiness priorities.
- [[gemini-wiki-health-audit-handoff-2026-05-04]] - Recent health audit (85% score) and remediation plan.
- [[gemini-openai-symphony-spec-research-handoff-2026-05-03]] - Symphony spec ingestion and verification.
- [[gemini-wiki-expansion-research-handoff-2026-05-02]] - Research for the 2026-05-02 expansion cycle.
- [[gemini-anthropic-docs-ingestion-handoff-2026-05-02]] - Librarian seam for the first Anthropic batch.
- [[gemini-core-protocol-framework-depth-handoff-2026-05-02]] - Execution plan for ADK/MCP core deepening.
- [[gemini-language-root-hardening-research-handoff-2026-05-02]] - Research for language hub hardening.
- [[gemini-post-synthesis-librarian-handoff-2026-05-01]] - Post-synthesis graph cleanup.
- [[gemini-orchestrator-test-handoff-2026-04-30]] - End-to-end test for the orchestrator.
- [[gemini-build-sprint-handoff]] - Build sprint graph-integration path.
- [[gemini-roadmap-sprint-handoff-2026-04-27]] - Roadmap sprint coordination.

## 🛠️ Codex Handoffs
- [[codex-anthropic-batch-2-synthesis-handoff-2026-05-02]] - Large-scale synthesis of Anthropic Batch 2.
- [[codex-anthropic-docs-ingestion-handoff-2026-05-02]] - Execution seam for the first Anthropic batch.
- [[codex-post-anthropic-synthesis-handoff-2026-05-02]] - Post-synthesis maintenance and portal rebuild.
- [[codex-orchestrator-integration-handoff-2026-04-30]] - Integration & state-machine completion.
- [[codex-orchestrator-build-handoff-2026-04-29]] - Infrastructure & pipeline foundation.
- [[codex-ps-compliance-handoff]] - PowerShell compliance and automation fixes.
- [[codex-validation-hardening-handoff-2026-04-28]] - Hardening of validation logic.
- [[codex-roadmap-sprint-handoff-2026-04-27]] - Roadmap sprint implementation.
- [[codex-build-sprint-handoff]] - Build sprint implementation path.
- [[codex-gemini-cleanup-handoff-2026-04-27]] - Post-sprint cleanup coordination.
- [[codex-polyglot-adr-handoff]] - ADR for the polyglot platform architecture.
- [[codex-usage-loop-handoff]] - Implementation of the database feedback loop.
- [[workbench-codex-runner-handoff]] - Execution context for the workbench runner.

## 🎭 Claude Handoffs
- [[claude-openai-symphony-synthesis-handoff-2026-05-03]] - Symphony literature synthesis.
- [[claude-symphony-graph-handoff-2026-05-03]] - Verification seam for the expanded Symphony graph.
- [[claude-anthropic-advanced-capabilities-handoff-2026-05-02]] - Advanced Anthropic feature cluster.
- [[claude-anthropic-batch-2-handoff-2026-05-02]] - Intake plan for the 30-page Anthropic batch.
- [[claude-core-reasoning-roots-handoff-2026-05-02]] - Rust/Python hub hardening.
- [[claude-powershell-typescript-hub-handoff-2026-05-02]] - PowerShell/TypeScript hub hardening.
- [[claude-mcp-authorization-handoff-2026-05-01]] - MCP authorization depth.
- [[claude-mcp-security-bp-handoff-2026-05-01]] - MCP security best practices.
- [[claude-supabase-flask-handoff-2026-05-01]] - Supabase/Flask integration research.
- [[claude-orchestrator-synthesis-handoff-2026-04-29]] - Intelligence & epistemic gates.
- [[claude-blueprint-handoff-2026-04-27]] - Dated session summary for the blueprint.
- [[claude-synthesis-handoff-2026-04-27]] - Dated session summary for literature synthesis.
- [[claude-a2a-protocol-handoff]] - A2A protocol research and mapping.
- [[claude-blueprint-handoff]] - Technical specs for Memory-MCP and Rust Tier-0.
- [[claude-capability-lattice-handoff]] - Capability lattice research.
- [[claude-community-summary-handoff]] - Community report synthesis.
- [[claude-gardening-visuals-handoff]] - Specs for Mermaid and gardening visuals.
- [[claude-portal-breadcrumbs-handoff]] - Portal UI and breadcrumb research.
- [[claude-rust-type-system-handoff]] - Deep dive into Rust safety.
- [[claude-session-types-handoff]] - Research on session-types in MCP.
- [[claude-synthesis-handoff]] - Synthesis for literature and agentic patterns.
- [[claude-codex-interop-test]] - Interoperability test findings.

## 🧪 Experimental & Misc Handoffs
- [[handoff-firecrawl-openai-agents]] - Firecrawl/OpenAI integration seam.
- [[workbench-integration]] - Workbench tool integration state.

---

## 🔍 Cross-Fleet Pattern Chronicle

A synthesized view of recurring patterns across handoff generations (2026-04-27 → 2026-05-06). This chronicle surfaces structural lessons from the three key handoffs: [[gemini-orchestration-research-handoff-2026-05-06]], [[claude-openai-symphony-synthesis-handoff-2026-05-03]], and [[codex-orchestrator-integration-handoff-2026-04-30]].

### Pattern 1 — Research → Prioritization → Synthesis (Gemini-led)

Gemini's research handoffs encode a consistent three-phase structure:
1. **Scan**: Web or document research to identify emergent 2026 updates (MCP v2, A2A v1.0, Modular RAG, MAK-CHK).
2. **Prioritize**: Batch the findings into ranked work lanes (Protocol Stability > Advanced Retrieval > Coordination Hardening).
3. **Seam**: Pass the ranked plan to the downstream agent with scoped, bounded instructions.

This prevents scope creep by making each handoff a *bounded work envelope*, not an open-ended directive.

### Pattern 2 — Evidence-Bounded Synthesis (Claude-led)

Claude handoffs (e.g., the Symphony synthesis seam from Codex to Claude) enforce a strict **no-new-sourcing** constraint: the indexed source set is declared in the handoff, and the synthesis agent may not broaden it. This produces literature notes grounded in verifiable provenance, not speculative aggregation.

Key sub-patterns:
- **Required claims to verify** are enumerated explicitly to anticipate synthesis failure points.
- **Stop conditions** are stated so the agent knows when to commit rather than expand.
- **Commit boundary** is narrowed to the synthesis artifact only.

### Pattern 3 — Infrastructure-First, Intelligence-Second (Codex/Claude split)

Orchestrator-scale work consistently follows a two-phase division:
- **Codex** owns the infrastructure layer: tool implementation, chunking, indexing, Supabase integration, state-machine mechanics.
- **Claude** owns the intelligence layer: epistemic gates, synthesis rubrics, conflict detection, provenance validation.

The handoffs between these phases are explicit state-machine transitions (`Crawled → Indexed → Synthesized → Promoted`) rather than implicit "continue the work" seams.

### Pattern 4 — Bounded Commit Discipline

All three handoffs enforce narrow commit scope. The Symphony synthesis handoff specifies one commit (`feat(wiki): ground openai symphony literature note`) and prohibits mixing graph-integration work. The orchestrator handoffs keep infrastructure commits separate from intelligence commits. This discipline keeps `git log` interpretable and roll-back boundaries clean.

---

## References
- [[index]]
- [[agent-note-conventions]]
- [[core-patterns-moc]]
- [[inter-agent-handoff-protocol]]


## Gemini Handoffs
- [[gemini-content-expansion-handoff-2026-05-04]] - Strategic roadmap for deepening Telephony, Observability, and Schema-driven patterns.