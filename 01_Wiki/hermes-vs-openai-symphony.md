---
title: Hermes vs OpenAI Symphony
author: gpt-5.4
date: '2026-05-19'
status: active
aliases:
  - symphony-vs-hermes
  - hermes-symphony-comparison
  - issue-orchestrator-vs-agent-environment
type: permanent
---

# Hermes vs OpenAI Symphony

[[hermes-agent]] and [[openai-symphony]] both support autonomous coding work, but they optimize for different primary artifacts. Hermes is a **persistent agent operating environment**. Symphony is an **issue-native orchestration service** for continuously assigning coding work to isolated workers.

## The shortest distinction

- **Hermes** asks: how do I give one agent a durable life across terminal, gateway, memory, tools, background runs, and operator control surfaces?
- **Symphony** asks: how do I turn a project board into a reliable control plane for autonomous coding runs?

They overlap in capability, but not in center of gravity.

## 1. Unit of work

- **Hermes** has multiple durable units of work: conversation turns, delegated subtasks, cron ticks, background jobs, and kanban tasks.
- **Symphony** is built around the **issue** as the durable unit of work.

This makes Symphony much more opinionated. If the work is not naturally expressed as tracker-native project tasks, Hermes fits more easily.

## 2. Control plane

- **Hermes** distributes control across conversation history, slash commands, gateway surfaces, scheduler state, kanban state, and profile-local config.
- **Symphony** centralizes control in the issue tracker plus the repository's `WORKFLOW.md` contract.

Hermes is operator-native. Symphony is board-native.

## 3. Runtime contract

- **Hermes** compiles runtime behavior from prompt assembly, loaded skills, environment grounding, toolsets, memory, and project context.
- **Symphony** pushes much of the per-repository contract into `WORKFLOW.md`, which combines config, hooks, and prompt template in one checked-in file.

Hermes behaves like a persistent context compiler. Symphony behaves like a repository-scoped workflow manifest.

## 4. Worker relationship

- **Hermes** supports free-form in-turn delegation via [[hermes-subagent-delegation]], fresh-session scheduling via [[hermes-cron]], and durable cross-time coordination via [[hermes-kanban]].
- **Symphony** uses a centralized orchestrator that launches a coding agent as a subordinate worker process inside an issue workspace.

So Hermes is more naturally a multi-surface agent environment, while Symphony is more naturally a work-dispatch service.

## 5. Isolation model

- **Hermes** can isolate work by profile, workdir, subagent context, cron session, or task board assignment.
- **Symphony** treats **per-issue workspace isolation** as a first-class invariant.

Hermes has multiple isolation strategies because it serves multiple surfaces. Symphony hard-centers one isolation strategy because its whole architecture is issue execution.

## 6. Durability model

- **Hermes** mixes interactive persistence with durable background systems.
- **Symphony** is a single long-running control loop whose job is to keep eligible issues assigned, retried, reconciled, and cleaned up.

Hermes is a general agent habitat. Symphony is a specialized orchestration daemon.

## 7. Human supervision style

- **Hermes** exposes rich operator control through commands, approvals, tool gating, and messaging surfaces.
- **Symphony** expects humans to supervise primarily through the project workflow: issue states, review boundaries, proof-of-work outputs, and acceptance decisions.

The human stands *inside the conversation* more often in Hermes, and *above the issue board* more often in Symphony.

## 8. Trust posture

- **Hermes** includes explicit runtime controls around approvals, tool visibility, memory, and background execution, but still depends on deployment policy.
- **Symphony** is unusually explicit that its trust boundary is implementation-defined and that trusted-environment assumptions must be stated by the deployer.

Symphony therefore feels narrower but more opinionated about the deployment harness question.

## Where Symphony is stronger

Choose Symphony when the question sounds like:

- "How do I continuously drain project-board work into isolated coding-agent runs?"
- "How do I keep repository policy and issue execution in the same versioned contract?"
- "How do I supervise outcomes at the issue lifecycle layer rather than the chat layer?"

## Where Hermes is stronger

Choose Hermes when the question sounds like:

- "How do I run one agent across terminal, Telegram, background jobs, and profiles?"
- "How do I mix coding, research, messaging, scheduling, and memory in one runtime?"
- "How do I preserve a long-lived operator-facing agent identity rather than only an issue worker?"

## Deeper architectural claim

Symphony is not simply "Hermes for GitHub issues," and Hermes is not simply "a more flexible Symphony." They instantiate two different primary abstractions:

- **Symphony** — work orchestration as a tracker-native service
- **Hermes** — agent operation as a persistent user-facing environment

That difference matters because it changes where policy lives, where state accumulates, and where humans intervene.

## See Also

- [[hermes-agent]]
- [[hermes-cron]]
- [[hermes-kanban]]
- [[hermes-subagent-delegation]]
- [[hermes-prompt-assembly]]
- [[hermes-skills-system]]
- [[openai-symphony]]
- [[openai-symphony-workflow-contract]]
- [[hermes-vs-adk-openai-agents-langgraph]]

## References

- [[hermes-agent]]
- [[openai-symphony]]
- [[lit-openai-symphony-spec]]
- [[lit-hermes-architecture]]
