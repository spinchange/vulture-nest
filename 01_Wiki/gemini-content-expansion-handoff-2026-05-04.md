---
title: Content Expansion Roadmap 2026-05-04
author: gemini-cli
date: 2026-05-04
status: active
type: handoff
aliases: [content-expansion-handoff-2026-05-04, expansion-roadmap]
---

# Content Expansion Roadmap 2026-05-04

## Objective
Deepen the wiki's technical coverage in four identified "thin" domains where raw documentation exists but permanent/literature notes are underdeveloped.

## Verified Facts (The "Thin Spots")
1.  **Telephony & Voice Agents**: `00_Raw/adk-documentation.md` contains `AgentPhone` specs; the wiki has 0 coverage.
2.  **Agent Observability**: `AgentOps` and OTel tracing mentions are high in raw docs, but the `agent-observability` note is a "thin node" (6 inbound links, low depth).
3.  **Schema-Driven Development**: Lack of integration notes between Pydantic models and autonomous tool-schema generation (FastAPI/MCP context).
4.  **Hardware-Aware Inference**: Local execution patterns for MLX, NPU, and CUDA are currently only fleeting sketches.

## Constraints
- All new notes must adhere to YANP (lowercase kebab-case, atomic, frontmatter).
- Maintain 100% MOC coverage (every new note must be linked in a relevant hub).

## Recommendations
1.  **Ingest AgentPhone**: Create `telephony-agents.md` literature note from `00_Raw/adk-documentation.md`.
2.  **Harden Observability**: Cross-reference `agent-observability` with OpenTelemetry GenAI semantic conventions.
3.  **Map Pydantic**: Add a section to `python-moc` for Pydantic-to-Tool-Schema mapping patterns.

## Evidence
Findings based on `02_System/find-thin-nodes.ps1`, `02_System/audit-moc-coverage.ps1`, and semantic analysis of `01_Wiki` vs `00_Raw`.

## Next Decision
Which domain—**Telephony** (new capability) or **Observability** (production hardening)—should be prioritized for the next ingestion run?

---
## References
- [[handoffs-moc]]
- [[agentic-frameworks-moc]]
- [[adk-moc]]
- [[agent-observability]]
- [[02_System/log]]
