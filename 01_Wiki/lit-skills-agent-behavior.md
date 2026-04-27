---
title: 'Literature: Skills and Agent Behavior'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: literature
aliases:
  - skills-agent-behavior-source
  - native-skills-docs
---

# Literature: Skills and Agent Behavior

## Source Metadata
*   **File:** `00_Raw/skills-and-agent-behavior.md`
*   **Origin:** Internal synthesis, hostname DESKTOP-004IHBK, 2026-03-13
*   **Domain:** agentic-frameworks / meta-architecture
*   **Relevance:** Defines the foundational distinction between *active* agent skills (injected rules) and *passive* vault knowledge (retrievable facts) — the epistemological split that governs how this vault itself is structured.

## High-Level Summary
This source establishes the "Native Wrapper" strategy for maintaining consistent agent behavior across heterogeneous models (Gemini, Claude, Codex). The core claim is that agent cognition requires two distinct storage modalities: **Skills** (executable, model-specific, always-active) and **Vault Notes** (declarative, model-agnostic, retrieval-triggered). These are not interchangeable — conflating them produces agents that are either inflexible (everything in skills) or unreliable (everything in notes).

## Core Dichotomy

| Dimension | Native Skill | Vault Note |
|---|---|---|
| **Role** | Active rules injected into system prompt | Passive facts retrieved on demand |
| **Activation** | Automatic (keyword/event triggered) | Manual (agent must search or be directed) |
| **Capabilities** | Tool-aware, model-specific | Model-agnostic markdown |
| **Persistence** | `~/.gemini/skills` / `~/.claude/skills` | Vault markdown directory |
| **Scope** | Single agent instance | Any agent with vault access |

## The Native Wrapper Pattern
For each convention defined in the vault:
1.  A **Vault Note** defines the convention in human-readable, model-agnostic prose (the "instruction manual").
2.  A **Native Skill** implements that convention using model-specific tool calls (the "executable code").

This pattern decouples *what to do* (in the vault) from *how to do it* (in the skill), enabling convention evolution without rewriting skill implementations.

## Cross-Machine Sync Strategy
Native skills are symlinked to a shared drive (Google Drive), giving all agent instances on all machines access to skill updates immediately after a `/skills reload`. This is the agent equivalent of a hot-reload deployment pipeline.

## Architectural Themes
1.  **Active vs. Passive Knowledge:** The distinction maps directly to the difference between compiled-in configuration and runtime-retrieved context. Skills are "firmware"; vault notes are "data."
2.  **Model-Agnostic Convention Layer:** By keeping conventions in neutral markdown (vault), they remain valid as the agent fleet evolves (new models, new tools). Only the thin skill wrapper needs updating per model.
3.  **Skill as Policy Enforcement:** Because skills are injected into the system prompt, they can enforce invariants (e.g., always use YANP frontmatter) that the agent cannot forget or override mid-session.

## Connections to Vault
*   [[agent-skills-index]] — registry of installed skills
*   [[agent-configuration-sync-strategy]] — the sync mechanism for cross-machine skill distribution
*   [[agent-knowledge-vault]] — the vault as the passive knowledge layer
*   [[executable-note-standard]] — extends "vault notes" toward executable hybrids
*   [[pattern-dynamic-delegation]] — skills as the mechanism for encoding delegation policies

## Next Steps for Synthesis
*   Formalize the Native Wrapper pattern as a permanent note with a template.
*   Explore whether A2A Agent Skills (in the Agent Card) and Native Skills share a structural isomorphism — both are declared capability surfaces consumed by a runtime.
*   Map skill lifecycle (install → activate → reload) to agent deployment patterns.
