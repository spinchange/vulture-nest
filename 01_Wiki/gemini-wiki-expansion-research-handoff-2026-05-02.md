---
title: Gemini Handoff — Wiki Expansion Research (2026-05-02)
author: codex
date: '2026-05-02'
status: active
type: handoff
targets:
  - gemini
aliases:
  - gemini-wiki-expansion-research
  - wiki-expansion-librarian-handoff
---

# Gemini Handoff: Wiki Expansion Research

## Objective

Research where the vault should expand next and produce a **prioritized, source-aware expansion plan** rather than immediately broadening the wiki ad hoc.

The goal is to identify the highest-leverage note clusters to deepen based on current graph topology, thin high-traffic notes, weak navigation hubs, and already-available raw/source material.

## Verified Facts

- `02_System/find-thin-nodes.ps1` currently reports **351 notes** and **3289 mapped links** after graph sync.
- Several notes are structurally important but still thin relative to their incoming-link count:
  - `[[agent-development-kit]]` — 57 incoming, 245 words
  - `[[rust]]` — 59 incoming, 227 words
  - `[[python]]` — 53 incoming, 225 words
  - `[[powershell]]` — 30 incoming, 135 words
  - `[[typescript]]` — 29 incoming, 138 words
  - `[[mcp-best-practices]]` — 25 incoming, 104 words
  - `[[agent-thought-cycle]]` — 21 incoming, 156 words
  - `[[agent-tools]]` — 20 incoming, 208 words
  - `[[graph-orchestration]]` — 6 incoming, 104 words
- Several MOCs or navigation notes are especially thin for their role:
  - `[[javascript-moc]]` — 88 words
  - `[[pkm-history-moc]]` — 80 words
  - `[[wpf-moc]]` — 115 words
  - `[[multi-agent-patterns-moc]]` — 160 words
  - `[[programming-languages-moc]]` — 168 words
- The vault already has meaningful coverage in some lanes, so this should not be treated as a blank-slate discovery task:
  - Anthropic API cluster exists and is newly seeded
  - Firecrawl pipeline/spec cluster exists and is relatively mature
  - OpenAI Swarm / Agents SDK coverage exists
  - MCP, ADK, .NET/C#, PowerShell, Python, Rust, and TypeScript all already have anchor notes or MOCs
- Raw/source inventory already exists for multiple expansion candidates, including:
  - `00_Raw/mcp/`
  - `00_Raw/anthropic/`
  - `00_Raw/adk-documentation.md`
  - `00_Raw/openai-agents-and-swarm.md`
  - Hugging Face agent-course files
  - language summaries and handbooks

## Constraints

- This handoff is for **research and planning**, not for a broad ingestion sprint.
- Do not create many new permanent notes in the same pass unless one is strictly necessary to hold the expansion plan.
- Keep facts separate from recommendations. If a gap is inferred from graph shape rather than directly proven by source absence, mark it as an inference.
- Prefer areas with either:
  - existing raw corpus ready for synthesis, or
  - a clearly central note whose thinness is already measurable
- Avoid recommending topic sprawl into marginal novelty areas when the core hubs are still underdeveloped.

## Task

Inspect the current vault and determine the best areas to expand next.

Produce a ranked list of **3 to 5 expansion lanes**. For each lane, include:

1. why it is high leverage now
2. whether the problem is:
   - thin hub note
   - weak MOC / navigation layer
   - incomplete source-to-literature-to-permanent conversion
   - missing bridge note between existing clusters
3. exact candidate note titles or wikilink targets
4. whether the lane should deepen existing notes or create a bounded new cluster
5. what raw corpus or source acquisition path supports it

## Recommendations

Use this evaluation order:

1. **Thin hubs with high centrality**
2. **Weak MOCs that impair navigation/discovery**
3. **Source-rich lanes with incomplete synthesis**
4. **Bridge notes that would connect already-existing clusters**

Likely areas worth validating:

- language root notes and MOCs
  - `[[python]]`, `[[rust]]`, `[[powershell]]`, `[[typescript]]`, `[[programming-languages-moc]]`
- agent framework core notes
  - `[[agent-development-kit]]`, `[[agent-tools]]`, `[[agent-thought-cycle]]`, `[[graph-orchestration]]`
- operational MCP guidance
  - `[[mcp-best-practices]]`, `[[mcp-authorization]]`, `[[mcp-primitives]]`, `[[mcp-sdks]]`
- weak navigational hubs
  - `[[javascript-moc]]`, `[[pkm-history-moc]]`, `[[wpf-moc]]`, `[[multi-agent-patterns-moc]]`

Treat those as starting hypotheses, not final conclusions.

## Deliverable

Create one bounded planning note:

- `01_Wiki/wiki-expansion-opportunities-2026-05-02.md`

That note should contain:

- `## Verified Gaps`
- `## Ranked Expansion Lanes`
- `## Recommended Immediate Batch`
- `## Deferred Lanes`

The output should end with a single recommended next batch that another agent could execute without re-researching the vault.

## Evidence

- `02_System/find-thin-nodes.ps1`
- `01_Wiki/index.md`
- `01_Wiki/agentic-frameworks-moc.md`
- `01_Wiki/programming-languages-moc.md`
- current note inventory under `01_Wiki/`
- current raw/source inventory under `00_Raw/`

## Stop Condition

Stop when:

- the planning note exists
- it contains a ranked expansion plan grounded in current vault evidence
- one immediate next batch is recommended

Do not execute the batch in the same session unless explicitly re-tasked.

## Next Decision

After the planning note is written, decide whether the next execution lane should be:

- **depth-first**: harden central thin hubs first
- **corpus-first**: synthesize the richest available raw/source lane first
