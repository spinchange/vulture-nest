---
title: "Literature: OpenAI Symphony Service Specification"
author: claude-sonnet-4-6
date: '2026-05-03'
status: active
type: literature
aliases:
  - lit-symphony-spec
  - symphony-spec-literature
source_url:
  - https://openai.com/index/open-source-codex-orchestration-symphony/
  - https://github.com/openai/symphony/blob/main/SPEC.md
provenance:
  page_ids:
    - 76b9c652-9e51-4b5f-b8dc-7030b6aa9eff
    - f53a802d-126c-428a-97ea-90a2eac298c3
---

# Literature: OpenAI Symphony Service Specification

Grounded synthesis from two indexed sources: the OpenAI announcement (2026-04-27) and the SPEC.md specification document. See [[openai-symphony]] for the derived permanent note.

## Sources

- **Announcement:** "An open-source spec for Codex orchestration: Symphony" — openai.com, 2026-04-27 (page `76b9c652`, 24 chunks)
- **Specification:** Symphony SPEC.md, `openai/symphony` repository (page `f53a802d`, 78 chunks)

---

## Key Findings

- **Status:** Draft v1, language-agnostic. Symphony is technically a `SPEC.md` file — a problem definition and intended solution, not a shipping product. [chunk `63960b55`]
- **Purpose:** "Define a service that orchestrates coding agents to get project work done." [chunk `4168dbbb`]
- **Core shift:** Reorients coordination from *coding sessions* to *work items*. "We were optimizing the wrong thing. We were orienting our system around coding sessions and merged PRs, when PRs and sessions are really a means to an end." [chunk `0e9d4911`]
- **Four operational problems solved:** daemon workflow repeatability; per-issue execution isolation; in-repo policy versioning via `WORKFLOW.md`; multi-run observability. [chunk `4168dbbb`]
- **Important boundary (verbatim from spec):** "Symphony is a scheduler/runner and tracker reader. Ticket writes (state transitions, comments, PR links) are typically performed by the coding agent using tools available in the workflow/runtime environment." [chunk `4168dbbb`]
- **Terminal state ambiguity:** A successful run may end at a workflow-defined handoff state (e.g., `Human Review`), not necessarily `Done`. [chunk `4168dbbb`]
- **Reference implementation:** Elixir — chosen for concurrency primitives. Codex built the initial Elixir implementation in one shot. The spec was subsequently verified by having Codex implement it in TypeScript, Go, Rust, Java, and Python. [chunk `1dc433ee`]
- **Intentional minimalism:** "We don't plan to maintain Symphony as a standalone product. Think of it as a reference implementation." [chunk `75338bba`]

---

## Core Architecture

### Components (§3.1) [chunk `e07327a8`]

| Component | Role |
|---|---|
| **Workflow Loader** | Reads `WORKFLOW.md`; parses YAML front matter + prompt body; returns `{config, prompt_template}` |
| **Config Layer** | Typed getters for workflow config values; applies defaults and `$VAR` environment indirection |
| **Issue Tracker Client** | Fetches candidate issues; normalizes tracker payloads into a stable issue model; handles reconciliation fetches |
| **Orchestrator** | Owns the poll tick and in-memory runtime state; decides dispatch, retry, stop, release |
| **Workspace Manager** | Maps issue IDs to workspace paths; runs lifecycle hooks; cleans up terminal-issue workspaces |
| **Agent Runner** | Creates workspace; builds prompt; launches Codex app-server client; streams agent updates to orchestrator |
| **Status Surface** | *(OPTIONAL)* Human-readable runtime status — terminal output, dashboard, etc. Must not be required for correctness. |
| **Logging** | Structured runtime logs to one or more configured sinks; REQUIRED fields include `issue_id`, `issue_identifier`, `session_id` |

### Abstraction Layers (§3.2) [chunk `a8a9454f`]

Symphony is easiest to port when kept in these six layers:

1. **Policy Layer** (repo-defined) — `WORKFLOW.md` prompt body; team-specific rules for ticket handling and handoff
2. **Configuration Layer** — Parses front matter into typed runtime settings; handles defaults, env tokens, path normalization
3. **Coordination Layer** — Polling loop, issue eligibility, concurrency, retries, reconciliation
4. **Execution Layer** — Filesystem lifecycle, workspace preparation, coding-agent protocol
5. **Integration Layer** — Linear API calls and payload normalization
6. **Observability Layer** — Operator visibility into orchestrator and agent behavior

### External Dependencies (§3.3) [chunk `ce4acb33`]

Issue tracker API (Linear for `tracker.kind: linear`); local filesystem; optional workspace population tooling (e.g., Git CLI); coding-agent executable supporting Codex app-server mode; host environment authentication for tracker and agent.

---

## Workflow Contract

### File Format (§5.2) [chunk `3ff54047`]

`WORKFLOW.md` is a Markdown file with **optional** YAML front matter.

- If file starts with `---`, lines until the next `---` are parsed as YAML front matter.
- Remaining lines become the prompt body.
- If front matter is absent, the entire file is the prompt body with an empty config map.
- YAML front matter MUST decode to a map/object — non-map YAML is an error.
- Prompt body is trimmed before use.

**Design constraint:** `WORKFLOW.md` SHOULD be self-contained enough to describe and run different workflows (prompt, runtime settings, hooks, tracker selection/config) without out-of-band service-specific configuration.

**Returned workflow object:** `config` (front matter root object) + `prompt_template` (trimmed Markdown body).

### Prompt Template Contract (§5.4) [chunk `a164b516`]

The Markdown body of `WORKFLOW.md` is the per-issue prompt template.

- Template engine: strict, Liquid-compatible semantics. Unknown variables **MUST** fail rendering. Unknown filters **MUST** fail rendering.
- Template input variables: `issue` (object — all normalized issue fields including labels and blockers); `attempt` (null on first attempt, integer on retry/continuation).
- Fallback: if the prompt body is empty, the runtime MAY use `"You are working on an issue from Linear."`.
- Parse/read failures are **configuration errors** and MUST NOT silently fall back to any prompt.

### Core Config Fields (§6.4) [chunk `00690797`]

Key fields confirming the contract scope:

- `tracker.active_states`: default `["Todo", "In Progress"]`
- `tracker.terminal_states`: default `["Closed", "Cancelled", "Done"]`
- `polling.interval_ms`: default 30 seconds
- `agent.max_concurrent_agents`: default 10
- `agent.max_turns`: default 20
- `agent.max_retry_backoff_ms`: default 5 minutes
- `codex.approval_policy`, `codex.thread_sandbox`, `codex.turn_sandbox_policy`: **all implementation-defined defaults**
- Workspace lifecycle hooks: `after_create`, `before_run`, `after_run`, `before_remove`

The config layer's support for `$VAR` indirection means sensitive credentials (Linear API key, Codex auth) resolve from environment variables rather than being embedded in the file.

---

## Trust Boundary

### §15.1 Trust Boundary Assumption [chunk `6eac575a`]

> "Each implementation defines its own trust boundary."

Operational safety requirements (normative SHOULD, not MUST):

- Implementations SHOULD state clearly whether they target trusted environments, more restrictive environments, or both.
- Implementations SHOULD state clearly whether they rely on auto-approved actions, operator approvals, stricter sandboxing, or some combination.
- Workspace isolation and path validation are **important baseline controls, but not a substitute** for whatever approval and sandbox policy an implementation chooses.

### Non-Goals Re: Trust (§2.2) [chunk `85c240a9`]

Explicitly out of scope:

- Mandating strong sandbox controls beyond what the coding agent and host OS provide.
- Mandating a single default approval, sandbox, or operator-confirmation posture for all implementations.

### Implication

The spec's trust language is normative architecture without normative policy: it defines *how* to wire trust configuration (the `codex.approval_policy`, `codex.thread_sandbox`, `codex.turn_sandbox_policy` config fields exist) but leaves the values and their enforcement to the implementation. "High-trust" (fully autonomous, auto-approved) and "low-trust" (human-in-the-loop, sandboxed) configurations are equally conformant. Claims that Symphony mandates a specific sandbox model are not supported by the indexed text.

---

## Critical Distinctions

### Symphony is not A2A

A2A (Agent-to-Agent) is a peer-to-peer delegation protocol where agents discover and call each other directly. Symphony has no peer-to-peer delegation layer. It is a centralized orchestrator pattern: one Orchestrator component owns the poll tick and in-memory runtime state; the coding agent is a subordinate subprocess, not a peer. [chunk `e07327a8`]

### Symphony is not Swarm [chunk `bd24c15d`, `0e9d4911`]

[[openai-swarm]] is an ephemeral, session-based framework for interactive handoffs between agents — a user initiates a session, agents route via return-based handoffs, and state is the caller's responsibility. Symphony is a persistent background daemon driven entirely by tracker state: no user initiates a session; the Orchestrator ensures every active issue has an agent running until terminal state is reached. The unit of coordination is the **issue**, not the **turn** or **session**.

| Dimension | [[openai-swarm]] | Symphony |
|---|---|---|
| Lifecycle | Session (user-initiated) | Issue (tracker-driven) |
| Persistence | Stateless per turn | Daemon + per-issue workspace |
| Trigger | User prompt | Tracker state change |
| Agent relationship | Peer handoff via return | Subordinate subprocess |
| Concurrency model | Single thread | Bounded concurrent workers |

### Symphony is not a general workflow engine

Explicitly listed as a non-goal: "General-purpose workflow engine or distributed job scheduler." Symphony knows about issues, workspaces, and coding agents. Business logic for editing tickets, PRs, or comments lives in the workflow prompt and the coding agent's tooling — not in Symphony. [chunk `85c240a9`]

### WORKFLOW.md is load-bearing, not a prompt file

`WORKFLOW.md` is the repository-owned contract for runtime behavior: it configures polling intervals, concurrency, workspace hooks, tracker authentication, and agent policies, in addition to providing the prompt template. Dynamic reload/re-apply is a conformance requirement. Parse failures are hard errors. [chunks `3ff54047`, `a0767396`]

### Ticket writes are agent-side

Symphony reads from the tracker; it does not write to it. State transitions (`In Progress` → `Human Review` → `Done`), PR links, and comments are performed by the coding agent using tools in the runtime environment. This boundary is stated as a spec-level invariant. [chunk `4168dbbb`]

---

## See Also

- [[openai-symphony]] — permanent note derived from this literature
- [[openai-swarm]] — contrast: ephemeral, session-based, handoff-oriented
- [[openai-agents-sdk]] — the SDK that provides agent primitives Symphony orchestrates
- [[workflow-agents]] — contrast: deterministic code-controlled agents vs. tracker-driven orchestration
- [[multi-agent-systems]] — Symphony as canonical Orchestrator/Manager pattern implementation

---

## Provenance

| Chunk ID | Source | Section |
|---|---|---|
| `4168dbbb` | SPEC.md | §1 Problem Statement |
| `63960b55` | openai.com announcement | SPEC.md §1-3 embedded |
| `e07327a8` | SPEC.md | §3.1 Main Components |
| `a8a9454f` | SPEC.md | §3.2 Abstraction Levels |
| `ce4acb33` | SPEC.md | §3.3 External Dependencies |
| `85c240a9` | SPEC.md | §2.2 Non-Goals |
| `3ff54047` | SPEC.md | §5.2 File Format |
| `a164b516` | SPEC.md | §5.4 Prompt Template Contract |
| `00690797` | SPEC.md | §6.4 Core Config Fields |
| `9c20f580` | SPEC.md | §10 Agent Runner Protocol |
| `03824ae3` | SPEC.md | §10.2 Session Startup Responsibilities |
| `6eac575a` | SPEC.md | §15.1 Trust Boundary Assumption |
| `a0767396` | SPEC.md | §18.1 REQUIRED for Conformance |
| `292d97e9` | SPEC.md | §18.2 RECOMMENDED Extensions |
| `0e9d4911` | openai.com announcement | "A shift in perspective" |
| `bd24c15d` | openai.com announcement | "Turning our issue tracker into an agent orchestrator" |
| `30b7e27a` | openai.com announcement | "An increase in exploration" |
| `1dc433ee` | openai.com announcement | "Using Symphony to build Symphony" (cont.) |
| `75338bba` | openai.com announcement | "What's next" |
