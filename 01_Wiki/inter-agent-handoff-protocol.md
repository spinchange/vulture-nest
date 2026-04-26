---
title: Inter-Agent Handoff Protocol
author: codex
date: 2026-04-26
status: active
type: permanent
aliases: [agent-handoff-protocol, multi-agent-handoff, seam-protocol]
---

# Inter-Agent Handoff Protocol

This note defines the current shared process for handing work between agents in the **vulture-nest**.

## Purpose

The handoff protocol exists to prevent three common failures:
- context drift between sessions
- durable notes mixing with transient execution logs
- ambiguous ownership of the next step

## Canonical Surfaces

Use these surfaces for distinct purposes:
- **`01_Wiki/`**: durable knowledge, permanent notes, MOCs, bridge notes, and stable protocol documents
- **PoShWiKi session page**: active execution state, `Actions`, `Session Goal`, `Current Seam`, and `Next Steps`
- **Dedicated handoff note**: a bounded brief for another agent when the work needs more than a one-line Seam

## Standard Handoff Flow

### 1. Resume
At session start, read:
- the latest PoShWiKi session page
- the latest relevant entries in `02_System/log.md`
- any dedicated handoff note referenced by the Seam

### 2. Work
While executing:
- record major milestones in PoShWiKi `Actions`
- keep durable conclusions in `01_Wiki/`
- keep generated evidence in vault-local artifact paths when possible

### 3. Write Back
Before ending a session:
- update or create any durable notes that were justified by the work
- record the current state with `New-WikiSeam`
- add a PoShWiKi `Actions` entry for major decisions or environment constraints learned during the work

## Message Format For Shared Notes

When one agent is asking another to do bounded work in a shared note, use:
- `## [AgentName] Message`
- `## [AgentName] Reply`
- `## Joint Findings`

This keeps multi-agent edits machine-parseable and reduces free-form drift.

## Seam Requirements

A valid Seam should answer three things with precision:
- **Goal**: what outcome was being pursued
- **Current Seam**: what exact technical boundary was reached
- **Next Step**: the immediate next action, phrased so another agent can execute it without reconstruction

Good Seams name exact files, artifacts, failure strings, or commands when relevant.

## When To Create A Dedicated Handoff Note

Use a dedicated handoff note when:
- the next agent needs verified facts plus recommendations
- the work spans multiple repos or runtimes
- there are environment constraints that can be mistaken for product defects
- one short Seam would be too lossy

## Recommended Handoff Structure

For substantial cross-agent work, use this structure:
- `## Objective`
- `## Verified Facts`
- `## Constraints`
- `## Recommendations`
- `## Evidence`
- `## Next Decision`

Keep facts and recommendations separate. Do not mix guesses into `Verified Facts`.

## Claude Research Prompt Shape

Claude tends to be strongest when given a bounded corpus and asked for structured findings. A good prompt should:
- name the exact note cluster or MOC to inspect
- ask for `Verified Gaps`, `Suggested Notes`, and `Graph Repairs`
- require exact wikilink targets and note titles
- distinguish observed problems from proposed improvements

## Codex Research Prompt Shape

Codex tends to be strongest when asked to:
- verify implementation claims against local files or proof artifacts
- tighten protocol docs or automation paths
- turn conceptual findings into executable or testable system changes

---
## References
- [[visitor-directives]]
- [[poshwiki-tools]]
- [[claude-codex-interop-test]]
- [[workbench-codex-runner-handoff]]
