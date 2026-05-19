---
title: OpenAI Symphony Workflow Contract
author: gpt-5.4
date: '2026-05-19'
status: active
aliases:
  - symphony-workflow-md
  - symphony-workflow-contract
  - symphony-repo-contract
type: permanent
---

# OpenAI Symphony Workflow Contract

In [[openai-symphony]], `WORKFLOW.md` is the repository-owned contract that binds **prompt**, **runtime settings**, **hooks**, **tracker configuration**, and **agent policy** into one versioned artifact. It is not merely a prompt template file.

## Why `WORKFLOW.md` is load-bearing

Many agent systems keep orchestration logic in application code or in out-of-band service configuration. Symphony instead pushes a large portion of the operational contract down into the repository being worked on.

That means the codebase can version its own:

- tracker configuration
- polling and concurrency settings
- workspace lifecycle hooks
- agent runtime settings
- prompt template for issue execution

The workflow contract therefore travels with the repository rather than living only in the orchestrator service.

## File shape

The spec defines `WORKFLOW.md` as Markdown with **optional YAML front matter**.

- if the file begins with `---`, the leading block is parsed as YAML front matter
- the remaining Markdown body becomes the prompt template
- if no front matter exists, the whole file is prompt body and config is empty
- non-map YAML is a configuration error
- prompt body is trimmed before use

This is a hybrid artifact: part config object, part human-readable operating manual, part agent prompt.

## The front matter is typed orchestration policy

The front matter schema includes major domains such as:

- `tracker`
- `polling`
- `workspace`
- `hooks`
- `agent`
- `codex`

These fields cover concrete service behavior like:

- which tracker/project to read from
- polling interval and eligibility behavior
- workspace root and lifecycle hooks
- concurrent worker limits and turn caps
- approval/sandbox settings for the coding agent

So the workflow file configures not only *what the agent should do*, but *how the service should execute it*.

## The Markdown body is the issue prompt template

The body of `WORKFLOW.md` is rendered into the per-issue prompt sent to the coding agent.

Key constraints from the spec:

- template semantics are strict
- unknown variables are failures, not silent omissions
- unknown filters are failures
- template input includes `issue` and `attempt`
- an empty body may fall back to a default issue prompt, but configuration-read failures must not silently fall back

This matters because Symphony treats prompt rendering as part of the correctness contract, not as an informal best-effort convenience.

## Config resolution and environment indirection

The config layer applies defaults and supports `$VAR` environment indirection for sensitive or deployment-specific values.

That lets a repo express stable orchestration structure while keeping secrets and machine-specific paths outside the file itself. In the Elixir reference implementation, this pattern is used for values such as `LINEAR_API_KEY` and configurable workspace roots.

## Dynamic reload semantics

`WORKFLOW.md` is not only read at initial boot. It is part of the live operational contract.

The spec requires explicit configuration-resolution and reload behavior, which means an implementation must define:

- how the workflow is re-read
- what happens when the updated workflow is valid
- what happens when the updated workflow is invalid

In the reference implementation profile, startup failure is fatal if `WORKFLOW.md` is missing or invalid, while a later reload failure preserves the last known good workflow and reports the error.

## Hooks make the contract operational

Symphony's workspace hooks turn `WORKFLOW.md` from a prompt artifact into an execution harness.

Hooks can control lifecycle boundaries such as:

- after workspace creation
- before agent run
- after agent run
- before workspace removal

This is where repository-specific setup logic such as cloning, dependency bootstrapping, or pre-run checks can be attached.

## Why this differs from a plain prompt file

A plain prompt file tells the agent what to say or do. `WORKFLOW.md` tells the **service** how to organize the run.

That is a stronger role. `WORKFLOW.md` is:

- a prompt source
- a runtime config source
- a hook script envelope
- a tracker-binding declaration
- a policy boundary for issue execution

Calling it merely a prompt file hides the architectural move Symphony is making.

## Comparison to other vault patterns

### Versus [[workflow-agents]]

ADK-style workflow agents usually encode workflow control in code. Symphony moves more of that contract into a repository-authored Markdown artifact.

### Versus [[hermes-prompt-assembly]] and [[hermes-skills-system]]

Hermes assembles live prompt state from agent identity, loaded skills, environment hints, project context, memory, and tool surfaces. Symphony instead pins more of the per-repo operational contract into one stable checked-in file.

Hermes is more like a persistent runtime compiler for agent context. Symphony is more like a repository-local workflow manifest for coding work.

## Architectural significance

`WORKFLOW.md` is the clearest sign that Symphony treats orchestration as a **repository-native contract**. The repo does not merely contain code to be modified; it also contains the policy document that defines how the orchestrator should assign and execute that modification work.

## See Also

- [[openai-symphony]]
- [[openai-symphony-orchestration-state-machine]]
- [[openai-symphony-trust-boundary]]
- [[workflow-agents]]
- [[hermes-prompt-assembly]]
- [[hermes-skills-system]]

## References

- [[lit-openai-symphony-spec]]
- `SPEC.md` §5–§6, `openai/symphony`
- `elixir/README.md`, `openai/symphony`
