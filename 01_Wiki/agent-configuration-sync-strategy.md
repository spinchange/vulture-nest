---
title: Agent Configuration Sync Strategy
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [sync-strategy, agent-state-synchronization]
---
# Agent Configuration Sync Strategy

A technical strategy for maintaining consistent agent state (skills, history, and preferences) across multiple physical machines using cloud-synced symbolic links.

## Architecture
* **Source of Truth**: A cloud-synced directory (e.g., Google Drive) containing canonical configurations.
* **Local Integration**: Local agent configuration directories (e.g., `~/.gemini/`, `~/.claude/`) are symlinked to the cloud-synced source.
* **Orchestration**: [[powershell.md|PowerShell]] scripts (e.g., `setup-symlinks.ps1`) automate the creation and maintenance of these links.

## Key Benefits
* **Cross-Machine Continuity**: Resume work on different hardware with identical context and toolsets.
* **Unified Conventions**: Ensures all agents (Claude, Gemini, etc.) share the same [[agent-note-conventions|durable workflows]].
* **Centralized Auditability**: Configuration changes are tracked in one location rather than drifting across local installs.

## Implementation Details
The strategy involves mapping local `skills/`, `memory/`, and `history/` folders to their canonical counterparts in the cloud root. This allows for a "Shared Agent Environment" that transcends individual machines.

---
## References
* Source: `00_Raw/agent-configuration-sync-strategy.md`
* [[agent-knowledge-vault]]
* [[agent-skills-index]]

