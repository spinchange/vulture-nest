---
title: Hermes Command Control Plane
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-slash-commands
  - hermes-operator-surface
  - hermes-command-registry
type: permanent
---
# Hermes Command Control Plane

[[hermes-command-control-plane]] describes the layer that lets humans steer Hermes *as a runtime* rather than only talking to it as a model. The key idea is that Hermes exposes an **operator control plane** alongside its model-facing tool plane.

## Core idea

Many agent systems give the user one main steering surface: the next chat message. Hermes adds a second surface made of slash commands that directly manipulate the session, model, tools, gateway, and background systems.

That means Hermes has two distinct interfaces:
- **tool surface** — what the model can call
- **command surface** — what the human operator can reconfigure or trigger

This is one reason Hermes feels like an environment rather than a library.

## Central registry rather than scattered commands

The architecture note in `hermes_cli/commands.py` is explicit: `COMMAND_REGISTRY` is the single source of truth for slash commands.

From that registry, Hermes derives:
- CLI help text
- gateway help text
- autocomplete
- Telegram bot command menus
- Slack subcommand mappings
- alias resolution

So the command surface is not just a collection of ad hoc handlers. It is a **registered control vocabulary** shared across surfaces.

## Command categories reveal the runtime model

The built-in categories in the registry show what Hermes considers first-class runtime concerns:
- **Session** — `/new`, `/resume`, `/background`, `/queue`, `/steer`, `/goal`, `/compress`, `/rollback`
- **Configuration** — `/model`, `/reasoning`, `/voice`, `/fast`, `/yolo`, `/footer`
- **Tools & Skills** — `/tools`, `/toolsets`, `/skills`, `/cron`, `/kanban`, `/reload-mcp`, `/reload-skills`
- **Info** — `/usage`, `/insights`, `/platforms`, `/profile`, `/debug`
- **Gateway-only controls** — `/approve`, `/deny`, `/sethome`, `/topic`, `/restart`, `/update`

This is a strong clue about Hermes's self-concept: it is operating not just a prompt loop but a **persistent agent substrate with operator-facing lifecycle hooks**.

## Cross-surface parity with deliberate asymmetry

The slash-command reference makes an important distinction: the CLI and messaging gateway share one registry, but not every command is available everywhere.

Examples:
- `/tools`, `/skills`, `/browser`, `/statusbar`, and `/handoff` are CLI-specific.
- `/sethome`, `/approve`, `/deny`, `/topic`, and `/restart` are gateway-specific.
- `/model`, `/background`, `/queue`, `/steer`, `/goal`, `/rollback`, and `/reload-mcp` work on both surfaces.

So Hermes aims for **shared command semantics where possible, surface-specific affordances where necessary**.

## Commands as live control, not static configuration

Several Hermes commands act on an already-running runtime rather than merely editing config files.

Examples:
- `/steer` injects guidance after the next tool call without creating a new user turn.
- `/goal` establishes a standing continuation objective across turns.
- `/background` launches a separate session that continues independently.
- `/compress` manually triggers context compaction.
- `/reload-mcp` refreshes external tool servers without leaving chat.
- `/approve` and `/deny` resolve pending dangerous-command gates in messaging.

This makes the command surface a **runtime control plane**, not just a settings menu.

## The registry also encodes policy

`CommandDef` includes fields such as:
- category
- aliases
- argument hints
- subcommands
- `cli_only`
- `gateway_only`
- optional config gates

So the registry does more than list names. It defines:
- discoverability
- availability by surface
- operator ergonomics
- help-text generation
- partial command governance

In other words, it is both a command index and a **policy schema for human control**.

## Dynamic extension via skills and quick commands

Hermes extends its command surface in two ways:
- installed skills can appear as dynamic slash commands
- user-defined quick commands can map a short slash command to a shell command or another slash command

That means the command layer is open-ended. Hermes can grow a personalized operator grammar without changing the core registry for every customization.

## Why this matters architecturally

[[hermes-command-control-plane]] explains how Hermes avoids a common agent UX trap: forcing every operational action to be phrased as natural-language chat.

Instead, Hermes separates:
- **conversation content** — passed through the model loop
- **runtime control** — applied directly through registered commands

That separation improves:
- predictability
- recoverability
- surface parity
- operator trust
- long-running session management

## Architectural consequence

The command surface is a major reason Hermes belongs in the same conversation as shells, IDEs, and long-lived daemons, not only agent frameworks. It gives the user a structured way to manage the runtime itself while leaving the model free to manage task reasoning inside that runtime.

## See Also
- [[hermes-agent]]
- [[hermes-moc]]
- [[hermes-gateway]]
- [[hermes-cron]]
- [[hermes-kanban]]
- [[hermes-tool-registry]]
- [[spec-hermes-agent-loop]]
- [[lit-hermes-architecture]]
- [[daemon-design-pattern]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\reference\slash-commands.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\hermes_cli\commands.py`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\cli.py`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\gateway\run.py`
