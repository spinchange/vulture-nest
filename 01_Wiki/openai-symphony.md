---
title: OpenAI Symphony
author: gemini-cli
date: '2026-05-03'
status: active
type: permanent
aliases:
  - symphony
  - symphony-spec
  - codex-orchestration
---

# OpenAI Symphony

**OpenAI Symphony** is an open-source service specification for orchestrating coding agents around project work items rather than interactive sessions. It shifts the unit of coordination from individual chat messages to **Issues/Work Items** (e.g., tickets in Linear).

## What It Is
Symphony is a **scheduler, runner, and tracker reader**. It acts as an autonomous background daemon that:
1.  Polls an issue tracker for work.
2.  Creates isolated, per-issue workspaces.
3.  Runs a coding agent guided by a repository-owned `WORKFLOW.md` file.
4.  Manages retries and terminal state transitions (e.g., moving a ticket to "Human Review").

## Core Model
The Symphony model is built on **Always-On Orchestration**. Instead of a user initiating a session, the service ensures that every active task in the tracker has an agent assigned to it.

*   **Unit of Work:** The **Issue** (Work Item).
*   **Control Plane:** The **Issue Tracker** (e.g., Linear). Ticket statuses drive the orchestrator's state machine.
*   **Contract:** The `WORKFLOW.md` file stored in the codebase repository.

## Main Components
*   **Orchestrator:** The central loop managing concurrency and dispatching issues.
*   **Issue Tracker Client:** Interface for polling and updating external trackers.
*   **Workspace Manager:** Handles filesystem isolation and population (cloning/syncing) for each issue.
*   **Agent Runner:** Prepares the rendered prompt from `WORKFLOW.md` and executes the agent subprocess.
*   **Workflow Loader:** Parses the in-repo configuration and instructions.

## Workflow Contract (`WORKFLOW.md`)
The `WORKFLOW.md` file serves as the versioned "brain" of the agent for a specific repository.
*   **Front Matter (YAML):** Configuration for polling intervals, concurrency, and workspace hooks.
*   **Body (Markdown):** The **Prompt Template**, rendered with issue metadata (title, description) before being sent to the agent.

## Safety and Trust Boundary
*   **Isolation:** Mandatory per-issue workspace isolation. Agents are restricted to a specific `cwd`.
*   **Normative vs. Implementation-Defined:** The spec mandates *how* components interact but leaves the **trust posture** (sandboxing depth, approval levels) to the implementation. It can operate in "high-trust" (fully autonomous) or "low-trust" (human-in-the-loop) environments.

## How It Differs From Interactive Agent Use
| Feature | Interactive Use | OpenAI Symphony |
| :--- | :--- | :--- |
| **Bottleneck** | Human attention (steering) | Project work capacity |
| **Trigger** | User prompt | Issue tracker state change |
| **Persistence** | Session-based | Task-based (Issue lifecycle) |
| **Supervision** | Step-by-step | High-level (Reviewing results) |

## Relationship To Existing Vault Notes
*   **[[openai-swarm]]**: Swarm is a lightweight framework for *ephemeral, chat-driven handoffs*. Symphony is a *service spec* for *background, task-driven orchestration*.
*   **[[openai-agents-sdk]]**: The SDK provides the tools to build agents; Symphony provides the *platform* to run them autonomously at scale.
*   **[[workflow-agents]]**: While ADK's workflow agents are *deterministic code controllers*, Symphony externalizes the "workflow" into a repository-owned Markdown file and uses an external tracker for state.
*   **[[multi-agent-systems]]**: Symphony implements a pure **Orchestrator/Manager Pattern**, where the Symphony service is the Manager and the Coding Agent is a specialized Worker.
*   **[[agent-development-kit|ADK]]**: Symphony aligns with the ADK philosophy of "Agents-as-Code," but focuses on the service-layer orchestration of those agents.

---
*Source: [[lit-openai-symphony-spec]]*
