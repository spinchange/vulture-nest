---
title: Gemini Handoff — OpenAI Symphony Spec Research (2026-05-03)
author: codex
date: '2026-05-03'
status: active
type: handoff
targets:
  - gemini
aliases:
  - gemini-openai-symphony-spec-research
  - symphony-spec-handoff
---

# Gemini Handoff: OpenAI Symphony Spec Research

## Objective

Research and ingest the newly published **OpenAI Symphony** orchestration specification into the vault as a bounded, source-grounded cluster.

This is a **research and synthesis pass**, not an implementation sprint. The immediate goal is to understand what Symphony is, where it fits relative to the vault's existing orchestration notes, and what durable notes should exist for it.

## Verified Facts

- OpenAI published the article **"An open-source spec for Codex orchestration: Symphony"** on **2026-04-27**.
- OpenAI describes Symphony as an **open-source spec** for orchestrating coding agents around project work rather than manually supervised interactive sessions.
- The official repository is `openai/symphony`, and its top-level `SPEC.md` is titled **"Symphony Service Specification"** with status **Draft v1 (language-agnostic)**.
- The spec defines Symphony as a service that continuously reads work from an issue tracker, creates an isolated workspace per issue, and runs a coding-agent session for that issue.
- The spec explicitly frames Symphony as:
  - a scheduler/runner
  - a tracker reader
  - a workflow driven by repository-owned `WORKFLOW.md`
  - an orchestrator with deterministic per-issue workspaces, retries, and observability
- The repository README describes Symphony as a **low-key engineering preview** intended for testing in **trusted environments**.
- As of this session on **2026-05-03**, the vault already contains related orchestration surfaces:
  - [[openai-swarm]]
  - [[openai-agents-sdk]]
  - [[agentic-frameworks-moc]]
  - [[multi-agent-systems]]
  - [[workflow-agents]]
  - [[rfc-agent-orchestration-handoff]]
  - [[inter-agent-handoff-protocol]]
- As of this session on **2026-05-03**, there is **no existing `Symphony` note** in `01_Wiki/`.

## Constraints

- Use **official OpenAI primary sources** only for the core research pass:
  - the OpenAI article
  - the `openai/symphony` repository
  - the repository `SPEC.md`
- Keep the work centered on the **specification and architecture**, not hype, launch framing, or social commentary.
- Separate what Symphony standardizes from what the spec leaves implementation-defined.
- Treat the current spec as **draft and version-sensitive**.
- Do not over-claim that Symphony is equivalent to [[a2a-protocol]], [[openai-swarm]], or ADK orchestration. Compare precisely.

## Task

Inspect the official Symphony materials and determine:

1. what Symphony's actual abstraction boundary is
2. which parts of the system are normative versus implementation-defined
3. how Symphony relates to existing vault concepts:
   - [[openai-swarm]]
   - [[openai-agents-sdk]]
   - [[workflow-agents]]
   - [[multi-agent-systems]]
   - [[inter-agent-handoff-protocol]]
4. whether Symphony deserves:
   - one permanent note only
   - one permanent note plus one bridge/comparison note
   - one permanent note plus lightweight MOC/index updates
5. what the highest-signal graph integration path should be

## Required Deliverable

Create:

- `01_Wiki/openai-symphony.md`

That note should include:

- `## What It Is`
- `## Core Model`
- `## Main Components`
- `## Workflow Contract`
- `## Safety and Trust Boundary`
- `## How It Differs From Interactive Agent Use`
- `## Relationship To Existing Vault Notes`

## Optional Deliverable

Create only if strongly justified by the corpus:

- `01_Wiki/symphony-vs-openai-swarm.md`

Only create the comparison note if, after reading the spec, the distinction is substantive enough to prevent future conceptual drift. If a short section in `[[openai-symphony]]` is sufficient, prefer that.

## Graph Integration

If the permanent note is created, do only minimal, high-signal integration. Likely candidates:

- `01_Wiki/agentic-frameworks-moc.md`
- `01_Wiki/openai-swarm.md`
- `01_Wiki/multi-agent-systems.md`
- `01_Wiki/index.md`

## Evaluation Frame

The resulting note should answer these questions clearly:

1. Is Symphony a protocol, a product, a workflow pattern, or a service spec?
2. What responsibilities belong to the orchestrator itself versus the coding agent running inside the workspace?
3. What role does `WORKFLOW.md` play in the system design?
4. What operational assumptions does the spec make about trust, approvals, sandboxing, and environment safety?
5. How does Symphony change the unit of coordination from sessions/PRs to issues/work items?

## Recommendations

Use these as starting hypotheses, not fixed conclusions:

- Symphony is best understood as a **service specification for coding-agent orchestration**, not as a peer-to-peer protocol like [[a2a-protocol]].
- The most important comparison surface is probably [[openai-swarm]], because both concern orchestration, but likely at different abstraction levels.
- The strongest vault value is probably a durable note explaining Symphony's **control-plane model**:
  one agent per open task, one workspace per issue, workflow policy stored in-repo.
- The spec's explicit trust-language likely deserves careful treatment because it appears to avoid mandating one approval/sandbox posture.

## Stop Condition

Stop when:

- `[[openai-symphony]]` exists
- the note distinguishes normative architecture from implementation-defined behavior
- at least one precise relationship to existing orchestration notes is documented
- no speculative implementation claims are presented as settled facts

Do not expand into a full OpenAI orchestration subtree in the same session unless re-tasked.

## Evidence

- OpenAI article: https://openai.com/index/open-source-codex-orchestration-symphony/
- Repository: https://github.com/openai/symphony
- Specification: https://github.com/openai/symphony/blob/main/SPEC.md
- Local related notes:
  - [[openai-swarm]]
  - [[openai-agents-sdk]]
  - [[agentic-frameworks-moc]]
  - [[multi-agent-systems]]
  - [[workflow-agents]]
  - [[rfc-agent-orchestration-handoff]]
  - [[inter-agent-handoff-protocol]]

## Next Decision

After `[[openai-symphony]]` is written, decide whether the next step should be:

- a comparison note against [[openai-swarm]]
- a broader orchestration-cluster cleanup
- or no further action beyond lightweight graph integration
