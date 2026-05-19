---
title: OpenAI Symphony Trust Boundary
author: gpt-5.4
date: '2026-05-19'
status: active
aliases:
  - symphony-trust-boundary
  - symphony-harness-hardening
  - symphony-safety-posture
type: permanent
---

# OpenAI Symphony Trust Boundary

[[openai-symphony]] is unusually explicit about a tension many agent systems leave implicit: the architecture is normative, but the **trust posture is implementation-defined**.

## The operator framing

The current repository README describes Symphony as:

- a **low-key engineering preview**
- intended for testing in **trusted environments**
- most appropriate for codebases that have already adopted **harness engineering**

This immediately signals that the reference implementation is not claiming universal safe defaults.

## What the spec fixes and what it leaves open

The spec strongly defines the service shape:

- tracker-driven issue orchestration
- per-issue workspaces
- agent-runner protocol
- workflow contract via `WORKFLOW.md`
- retries, reconciliation, and cleanup behavior

But on security posture it explicitly says each implementation defines its own trust boundary.

So Symphony standardizes **how the orchestrator is structured** more strongly than **how aggressive or restrictive the deployment must be**.

## Baseline controls are necessary but insufficient

The spec treats some safety measures as important baselines:

- workspace isolation
- path validation and filesystem safety rules
- explicit hook boundaries
- secret handling through environment-backed configuration

But it also warns that these are **not substitutes** for a deployment's larger sandbox and approval model.

In other words: isolated workspaces reduce blast radius, but they do not by themselves solve prompt injection, malicious repository content, dangerous tool invocation, or data exfiltration.

## The key hardening insight

The spec's harness hardening guidance says implementations should not assume that the following are trustworthy simply because they arrived through a normal workflow:

- tracker data
- repository contents
- prompt inputs
- tool arguments

That is an important stance. Symphony assumes the work pipeline itself may carry hostile or risky content.

## What remains implementation-defined

A conformant Symphony implementation still has to choose its own posture around:

- auto-approved vs operator-approved actions
- restrictive vs permissive sandboxing
- OS/container/VM isolation depth
- network restrictions
- credential scoping and partitioning
- whether the environment is trusted enough for direct autonomous mutation

This means "Symphony-compliant" does not automatically mean "secure enough for my environment."

## Ticket writes are a boundary of responsibility

The spec also draws an operational trust boundary around tracker writes.

Symphony itself is primarily a scheduler/runner and tracker reader. State transitions, comments, PR links, and similar ticket mutations are typically performed by the coding agent through the tools available in the runtime environment.

That matters because risk is not only in the orchestrator loop. It is also in the permissions granted to the worker's tool surface.

## Harness engineering as the real safety substrate

The README's recommendation that Symphony works best in repositories that have adopted harness engineering implies a deeper claim:

Symphony is safest when the surrounding repository and execution environment are already structured for agent use.

That includes patterns like:

- reproducible setup
- bounded tool surfaces
- explicit validation steps
- auditable handoff or review states
- proof-of-work outputs rather than opaque claims of completion

Without that substrate, Symphony's orchestration power can amplify bad runtime assumptions just as easily as good ones.

## Architectural consequence

Symphony should be read as a **control-loop architecture plus a hardening envelope left to the deployer**. It is not a turnkey safety doctrine.

This is part of what distinguishes it from frameworks whose primary value lies in developer APIs alone. Symphony explicitly invites the operator to reason about the environment, the harness, and the approvals model as first-class design choices.

## See Also

- [[openai-symphony]]
- [[openai-symphony-workflow-contract]]
- [[openai-symphony-orchestration-state-machine]]
- [[wiki-as-codebase]]
- [[lit-mcp-security-best-practices]]

## References

- [[lit-openai-symphony-spec]]
- `README.md` in `openai/symphony`
- `SPEC.md` §15 and §18, `openai/symphony`
- `elixir/README.md` in `openai/symphony`
