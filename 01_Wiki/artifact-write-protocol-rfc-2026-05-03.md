---
title: RFC — Artifact Write Protocol
author: codex
date: 2026-05-03
status: active
type: fleeting
aliases:
  - write-protocol-rfc
  - documentation-surface-rfc
  - seam-handoff-log-rfc
---

# RFC — Artifact Write Protocol

This RFC is a first pass at specifying what the Nest tells agents to write, where each artifact belongs, and how those artifact types relate to each other.

The immediate goal is not to finalize the protocol. It is to expose the current state clearly enough that we can resolve contradictions instead of continuing to operate on overlapping norms.

## Objective

Define a vault-wide write protocol for:

- durable wiki notes
- fleeting notes
- handoff notes
- seams
- PoShWiKi session pages
- session logs
- file-local evidence and generated artifacts

The core question is:

> when an agent learns something, decides something, delegates something, or pauses work, what exact artifact should it write, and where?

## Why This RFC Exists

The current Nest has strong building blocks but inconsistent guidance.

The ambiguity is not about whether the vault works. It does. The ambiguity is about whether the write behavior is:

- fully specified
- internally consistent
- predictable across agents
- distinguishable by artifact type and lifecycle

At the moment, the answer is "not yet."

## Current Canonical Surfaces

Based on the current directives and actual practice, the Nest uses these write surfaces:

### 1. `01_Wiki/`

Used for:

- permanent notes
- literature notes
- specs
- MOCs and bridge notes
- dedicated handoff notes
- some fleeting planning / execution notes

### 2. PoShWiKi Session Page

Used for:

- `Session Goal`
- `Actions`
- `Current Seam`
- `Next Steps`

This is the main session-state surface described by [[inter-agent-handoff-protocol]] and implemented by `New-WikiSeam`, `Invoke-WikiLog`, and `Invoke-WikiNote`.

### 3. Structured SQLite Tables via PoShWiKi

Used for:

- `Seams`
- `Debates`

This is a machine-readable sidecar for specific procedural artifacts.

### 4. `02_System/log.md`

Used as the durable public ledger of:

- notable sessions
- multi-step work summaries
- maintenance passes
- synthesis outcomes
- architectural changes

### 5. File-Local Artifacts

Used for:

- experiment outputs
- review reports
- raw evidence
- generated portal files
- workbench outputs

These usually live under:

- `04_Experiments/`
- `02_System/`
- `00_Raw/`
- `03_Web/public/`

## Documented Rules vs. Emergent Practice

### A. Session Tracking Location Is Underspecified

[[visitor-directives]] says:

- durable knowledge belongs in `01_Wiki/`
- active work/logs should use PoShWiKi
- if a seam is longer than one line, create a dedicated handoff note

That is directionally good, but it leaves open:

- when a dedicated handoff note is preferable to only a seam
- whether a fleeting planning note is different from a handoff note
- when a session summary belongs in `log.md` versus the session page versus both

### B. Note Type Semantics Are Not Fully Aligned

Current sources disagree:

- [[visitor-directives]] describes note frontmatter minimally and does not mention the full live type vocabulary
- [[yanp-for-agentic-workflows]] describes a lifecycle and intent model
- [[wiki-as-codebase]] describes `moc` as a type, but the actual validator does not use `moc` as a live allowed type
- `audit-yanp.ps1` allows `community`, `community-report`, `experiment`, `fleeting`, `handoff`, `literature`, `permanent`, and `spec`

So the conceptual model and the enforced model have drifted.

### C. Status Semantics Are Not Fully Aligned

Current sources disagree on status values:

- [[visitor-directives]] mentions `draft | active`
- [[agent-note-conventions]] mentions `draft`, `active`, `archived` plus workflow signals
- [[yanp-for-agentic-workflows]] describes `raw → draft → active → archived`
- actual notes also use values such as `superseded` and `partially-resolved`

So the status field is operationally richer than the main protocol notes currently admit.

### D. Authorship / Metadata Rules Drift

[[agent-note-conventions]] requires or strongly implies fields like:

- `hostname`
- `status_log`

But those are not consistently present across the actual vault and are not enforced by the current validator.

So we have a difference between:

- aspirational metadata discipline
- live enforced minimum
- actual fleet practice

### E. Seam vs. Handoff vs. Log Summary Is Blurry

Right now:

- a **Seam** is a resume boundary with `Goal`, `Current Seam`, and `Next Step`
- a **handoff note** is a bounded brief for another agent
- the **system log** is the durable summary of what happened

But the thresholds between them are not explicit enough.

This causes repeated judgment calls about:

- whether to write only a seam
- whether to also write a handoff note
- whether to summarize in `log.md` now or later

## Working Problem Statement

The Nest currently lacks a single explicit artifact taxonomy that answers:

1. what each artifact type is for
2. where it lives
3. whether it is durable or procedural
4. who is expected to read it next
5. when it should be promoted, summarized, archived, or discarded

That is the protocol gap this RFC is trying to close.

## Draft Artifact Taxonomy

This is a proposed first cut, not yet the final model.

### 1. Permanent Note

Purpose:

- durable conceptual knowledge
- load-bearing synthesis

Location:

- `01_Wiki/`

Reader:

- future agents and humans as a stable knowledge surface

### 2. Literature Note

Purpose:

- source-grounded summary of an external corpus

Location:

- `01_Wiki/`

Reader:

- future synthesis passes and fact-checking work

### 3. Fleeting Work Note

Purpose:

- bounded planning, research packet, temporary execution scaffold, or intermediate synthesis artifact

Location:

- `01_Wiki/`

Reader:

- current or near-future agents/humans

Lifecycle:

- should usually be promoted, archived, or retired once its value is absorbed

### 4. Handoff Note

Purpose:

- bounded work brief for another agent when a seam alone is too lossy

Location:

- `01_Wiki/`

Reader:

- a specific next agent or the HITL

Constraint:

- facts, constraints, recommendations, and next decision should remain clearly separated

### 5. Seam

Purpose:

- the minimum viable resume record at session boundary

Location:

- PoShWiKi session page and `Seams` table

Reader:

- the next agent or the HITL resuming immediately after the current session

Constraint:

- must be short, exact, and execution-oriented

### 6. Session Log Entry

Purpose:

- durable human-readable summary of meaningful completed work

Location:

- `02_System/log.md`

Reader:

- anyone reconstructing vault history or operational state

Constraint:

- summarizes completed action; does not replace the seam

### 7. File-Local Evidence Artifact

Purpose:

- raw output, generated evidence, review report, experiment result, or compiled artifact

Location:

- local artifact path under `00_Raw/`, `02_System/`, `03_Web/`, or `04_Experiments/`

Reader:

- follow-on verification or reproduction work

Constraint:

- should be referenced by seam, handoff, log, or note when it matters

## Draft Decision Rules

These are the rules I think we want, but they need review.

### Rule 1: Session State Does Not Belong In Permanent Notes

If the content is mainly:

- what I just did
- what failed
- what to do next
- what environment quirk I discovered

then it belongs first in:

- PoShWiKi `Actions`
- `Current Seam`
- `Next Steps`

not in a permanent note.

### Rule 2: Seam Is Mandatory, Handoff Note Is Conditional

Always write a seam at session end.

Write a dedicated handoff note only when:

- the next agent needs more than a short resume boundary
- verified facts and recommendations must be preserved distinctly
- the environment or scope could be misunderstood without a structured brief

### Rule 3: Log Is Summary, Not Working Memory

`02_System/log.md` should record:

- durable summaries of meaningful work
- not every operational step
- not unresolved live state that only makes sense in the immediate session

### Rule 4: Fleeting Notes Need A Clear Exit

A fleeting note should usually move toward one of:

- promoted insight into a permanent note
- archival as completed procedural history
- deletion if it was only scratch space

The vault should not treat all fleeting notes as equally durable by default.

### Rule 5: File Artifacts Need Upstream References

If an artifact in `00_Raw/`, `02_System/`, `03_Web/`, or `04_Experiments/` matters for later work, its existence should be pointed to by at least one of:

- a seam
- a handoff note
- a log entry
- a permanent or literature note

## Draft Open Questions

1. Should `handoff` and `fleeting` remain separate types, or is `handoff` better treated as a constrained subtype / pattern of fleeting work?
2. Should `log.md` be treated as the canonical durable session summary, or should exported PoShWiKi session pages take that role more explicitly?
3. Should `agent-note-conventions` be aligned downward to actual enforced minimums, or should the validator be aligned upward to the richer metadata model?
4. Should status values be explicitly enumerated in a single live source of truth?
5. Should there be a formal rule for when to write both a seam and a handoff note versus only one?

## Recommended Next Spec

I do not think the next step should be "write one big perfect protocol note."

I think the right sequence is:

1. validate this artifact taxonomy
2. choose one canonical source of truth for note `type` and `status`
3. define explicit decision rules for seam vs. handoff vs. log
4. then write the final spec as a stable operational standard

## Related

- [[visitor-directives]]
- [[inter-agent-handoff-protocol]]
- [[agent-note-conventions]]
- [[yanp-for-agentic-workflows]]
- [[wiki-as-codebase]]
- [[zettelkasten-note-types]]
