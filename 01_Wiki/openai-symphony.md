---
title: OpenAI Symphony
author: gpt-5.4
date: '2026-05-19'
status: active
type: permanent
aliases:
  - symphony
  - symphony-spec
  - codex-orchestration
---

# OpenAI Symphony

**OpenAI Symphony** is an open-source service specification for orchestrating coding agents around project work items rather than interactive sessions. It shifts the unit of coordination from chat turns and merged pull requests to the **issue lifecycle** itself.

## What It Is

Symphony is a **scheduler, runner, and tracker reader**. In the current repository shape, that means:

1. polling an issue tracker such as Linear for active work
2. creating an isolated workspace per issue
3. rendering a repository-owned `WORKFLOW.md` contract into a coding-agent prompt
4. launching the coding agent as a subordinate worker process
5. retrying, reconciling, and releasing work until the issue reaches a workflow-defined terminal boundary

The result is an **always-on coding-work orchestrator**: engineers manage work items and review outcomes rather than supervising every agent turn.

## Core Model

The Symphony model is built around three strong claims.

- **Unit of work:** the **issue** or work item, not the interactive session
- **Control plane:** the **issue tracker**, whose states determine when work is eligible, active, or terminal
- **Repository contract:** the in-repo `WORKFLOW.md` file, which binds prompt, runtime settings, hooks, tracker config, and agent policy into one versioned artifact

This makes Symphony a service-layer orchestration substrate rather than a chat framework.

## Current Repository Shape

The live `openai/symphony` repository presents Symphony as three related artifacts:

- **`SPEC.md`** — the normative language-agnostic service specification
- **`README.md`** — the operator-facing framing: trusted environments, harness engineering, and proof-of-work outcomes
- **`elixir/`** — the experimental reference implementation, including the current Elixir/OTP service and its setup guidance

So Symphony should be read as both a **specification** and a **reference implementation profile**, not as a polished end-user product.

## Main Components

The spec centers the following components:

- **Orchestrator** — owns the poll tick, claims, retries, and in-memory runtime state
- **Issue Tracker Client** — fetches candidate issues and refreshes their current tracker state
- **Workspace Manager** — maps issue IDs to workspaces, applies hooks, and enforces isolation boundaries
- **Agent Runner** — launches the coding agent, streams events, and maps worker outcomes back into orchestration state
- **Workflow Loader / Config Layer** — parses `WORKFLOW.md` into typed configuration and prompt material
- **Observability Surface** — optional dashboards, logs, and status APIs that help operators inspect the service without being required for correctness

## Key Subsystems

Symphony is easier to reason about as a cluster of related concepts than as one overloaded overview note.

- [[openai-symphony-orchestration-state-machine]] — internal claim states, retries, reconciliation, and worker lifecycle
- [[openai-symphony-workflow-contract]] — why `WORKFLOW.md` is the real repository-owned control artifact
- [[openai-symphony-trust-boundary]] — trusted-environment framing, implementation-defined safety posture, and harness hardening
- [[hermes-vs-openai-symphony]] — contrast between Symphony's issue-native orchestration service and Hermes's broader persistent agent environment

## What Makes Symphony Distinctive

### 1. Tracker-native orchestration

Symphony does not treat the issue tracker as a notification source layered on top of a chat system. The tracker is the **control plane**. Issue state determines candidate selection, active work ownership, retries, and release.

### 2. `WORKFLOW.md` is load-bearing

`WORKFLOW.md` is not a decorative prompt file. It carries configuration, workspace hooks, tracker selection, runtime policy, and the prompt template itself. That makes repository policy versioned with the codebase the agent is modifying.

### 3. The coding agent is a subordinate worker, not a peer agent

Symphony is a centralized orchestrator pattern. The coding agent runs as a worker subprocess inside an issue-specific workspace. This is not an A2A-style peer delegation fabric.

### 4. Trust posture is intentionally left open

The spec defines how the pieces relate, but leaves approval and sandbox posture to the implementation. Symphony can run in a permissive trusted environment or a more restrictive human-reviewed one, as long as the implementation states the chosen boundary clearly.

## Relationship To Existing Vault Notes

- **[[openai-swarm]]** — Swarm is an ephemeral, session-oriented handoff framework. Symphony is a persistent, issue-oriented orchestration service.
- **[[openai-agents-sdk]]** — the SDK provides primitives for building agents and agent runs; Symphony provides a tracker-native platform for continuously assigning project work to coding-agent workers.
- **[[workflow-agents]]** — ADK workflow agents keep workflow logic in code. Symphony externalizes much of the workflow contract into a repository-owned Markdown artifact.
- **[[multi-agent-systems]]** — Symphony is a strong example of the **Orchestrator/Manager** pattern where the manager owns issue state, workspace lifecycle, and retry policy.
- **[[hermes-agent]]** — Hermes is a broader persistent agent environment spanning conversations, tools, memory, gateway surfaces, cron, and delegation. Symphony is much narrower and more issue-native.

## See Also

- [[lit-openai-symphony-spec]]
- [[openai-swarm]]
- [[openai-agents-sdk]]
- [[multi-agent-systems]]
- [[agentic-frameworks-moc]]
- [[hermes-vs-openai-symphony]]

## References

- [[lit-openai-symphony-spec]]
- `README.md` in `openai/symphony`
- `SPEC.md` in `openai/symphony`
- `elixir/README.md` in `openai/symphony`
