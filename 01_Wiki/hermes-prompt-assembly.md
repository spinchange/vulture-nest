---
title: Hermes Prompt Assembly
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-system-prompt-builder
  - hermes-prompt-builder
  - hermes-context-files
type: permanent
---
# Hermes Prompt Assembly

[[hermes-prompt-assembly]] describes how Hermes builds the system prompt that governs each turn. The prompt is not a single static template; it is a **composed artifact** assembled from identity, environment facts, memory guidance, skill indexes, and project context files.

## Core idea

Hermes treats prompt construction as runtime infrastructure.

The prompt builder in `agent/prompt_builder.py` assembles several layers:
1. identity/persona content
2. durable memory guidance
3. environment hints about the actual execution substrate
4. a live skills index
5. project context files such as `HERMES.md`, `AGENTS.md`, `CLAUDE.md`, or `.cursorrules`

This makes the system prompt less like a monolithic prompt string and more like a **compiled context bundle**.

## Environment hints are grounded, not assumed

`build_environment_hints()` shows an important Hermes design principle: tell the model where its tools actually run.

For local backends, Hermes injects:
- host OS
- user home directory
- current working directory
- Windows-specific warnings such as hostname != username
- a Windows-local shell warning that `terminal` uses bash, not PowerShell

For remote backends, Hermes suppresses host-machine details and instead describes the active sandbox/backend environment. This prevents the prompt from teaching the agent the wrong machine model.

So prompt assembly is also **execution grounding**.

## Skills are indexed through a cached manifest

Hermes does not dump every `SKILL.md` file into the system prompt. Instead, `build_skills_system_prompt()` builds a compact index of available skills.

The implementation uses two caches:
- an in-process LRU cache keyed by skills directory, tool availability, toolsets, platform hint, and disabled-skill state
- a disk snapshot (`.skills_prompt_snapshot.json`) validated by an mtime/size manifest

This matters because skill discovery is part of every turn, but full filesystem rescans would make startup and prompt building unnecessarily expensive.

The resulting prompt block teaches the model which skills exist and when it must load them with `skill_view()`.

## Conditional skill visibility

The skills index is not universal. Hermes filters skills by:
- platform compatibility
- disabled-skill configuration
- required tools or toolsets
- fallback conditions that hide a skill when a primary tool is available

That means the prompt surface reflects the **actual capability envelope** of the current session rather than an aspirational list.

## Context files are prioritized and sanitized

Hermes loads project context files with a strict priority order:
1. `.hermes.md` or `HERMES.md` walking toward git root
2. `AGENTS.md`
3. `CLAUDE.md`
4. `.cursorrules` or `.cursor/rules/*.mdc`

Only one project-context source wins, which prevents prompt bloat from stacking multiple competing instruction files.

Before injection, Hermes:
- strips YAML frontmatter where needed
- scans content for prompt-injection patterns
- truncates long files with explicit head/tail markers
- labels each injected section so the model knows where it came from

This means prompt assembly is also a **context-security layer**.

## SOUL.md as identity slot

`SOUL.md` is handled separately from project context. Hermes loads it from `HERMES_HOME` as the identity slot for the agent, then avoids injecting it twice.

That separation implies two kinds of prompt material:
- **identity context** — who the agent is
- **project context** — what environment or repo rules apply right now

Hermes keeps those concepts distinct, which is cleaner than mixing persona and project directives in one giant file.

## Prompt assembly as prompt operations

Several details reveal that prompt building in Hermes is operational, not decorative:
- environment facts are probed live
- skill indexes are cached and filtered dynamically
- context files are discovered per working directory
- truncation budgets are explicit
- injection scanning is treated as a real safety concern

So [[hermes-prompt-assembly]] is best understood as the **control-plane layer** that prepares a usable operating context for the model before the turn loop starts.

## Architectural consequence

The prompt in Hermes is not just instructions; it is a compact projection of the current agent world: identity, tools, platform, skills, and project constraints. That is why Hermes can preserve behavior across CLI, gateway, and profile surfaces while still adapting to local context.

## See Also
- [[hermes-agent]]
- [[hermes-skills-system]]
- [[hermes-bounded-memory]]
- [[hermes-profiles]]
- [[hermes-provider-abstraction]]
- [[spec-hermes-agent-loop]]
- [[lit-hermes-architecture]]
- [[agent-skills-index]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\agent\prompt_builder.py`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\developer-guide\architecture.md`
