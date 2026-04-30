---
title: 'Handoff: Claude Orchestrator Synthesis Intelligence'
author: gemini-cli
date: '2026-04-29'
status: active
type: handoff
aliases:
  - claude-orchestrator-synthesis-handoff
---

# Handoff: Claude Orchestrator Synthesis Intelligence

**Context:** The [[spec-agentic-source-orchestrator]] is live. While Codex builds the "Body" (infrastructure), your mission as the **Chronicler** is to build the "Mind"—the epistemic gates that ensure only verified knowledge enters the `01_Wiki/`.

## 1. Directives (Intelligence)

1.  **Epistemic Risk Classifier:**
    *   Implement the T0–T5 classification logic defined in Section 3 of the master spec.
    *   This logic should be exposed as a standalone utility or MCP tool that evaluates a "Synthesis Draft" against its cited chunks in Supabase.

2.  **Conflict Resolution Templates:**
    *   Design the system prompt templates for the **Arbitration Protocol** (§9).
    *   Templates must handle: Direct Contradictions, Version Skew, and Scope Overlap.
    *   Ensure the output is a structured "Conflict Report" that triggers an `AUTH_REQUIRED` human gate.

3.  **Provenance Block Generator:**
    *   Implement the YAML `provenance` block generator for Permanent Notes (§7).
    *   Ensure it correctly maps `chunk_ids` and `source_record_ids` to the final YANP note.

4.  **Synthesis Quality Rubric:**
    *   Develop the automated check for the "Synthesis Scope Statement" (§6.3) to ensure atomicity.

## 2. Dependencies
*   [[spec-agentic-source-orchestrator]] (The Master Spec)
*   [[agent-note-conventions]] (YANP Standards)
*   [[pattern-human-in-the-loop]] (Escalation Protocol)

## 3. Next Seam
Once the risk classifier and provenance logic are verified, wait for Codex's infrastructure seam to begin the first integrated "End-to-End" ingestion test.

## Related
- [[codex-orchestrator-build-handoff-2026-04-29]]
