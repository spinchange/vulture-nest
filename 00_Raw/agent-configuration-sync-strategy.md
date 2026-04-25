---
tags:
  - agents
  - automation
  - infrastructure
  - sync
source: codex
hostname: DESKTOP-004IHBK
date: 2026-03-13
status: active
---

# Agent Configuration Sync Strategy

A strategy for maintaining consistent AI agent state across multiple machines such as work and Luna using local symbolic links and a cloud-synced Google Drive root.

## Architecture

- **Source of Truth**: `I:\My Drive\agentconfig\`
- **Local Integration**: `~\.claude\`, `~\.gemini\`, and `~\.codex\`
- **Connective Tissue**: symbolic links mapping local config folders to cloud-synced folders

## Setup Scripts

### Shared Agent Script

`I:\My Drive\agentconfig\setup-symlinks.ps1` handles:

- Claude: `skills` and project-specific `memory`
- Gemini: `history`, `settings.json`, and `skills`

Usage:

```powershell
# Run as Administrator
& "I:\My Drive\agentconfig\setup-symlinks.ps1" -Force
```

### Codex Script

Codex currently uses a separate script because only the `skills` directory is being synchronized:

```powershell
# Run after Codex is closed
& "I:\My Drive\agentconfig\codex\setup-symlinks.ps1" -Force
```

## Benefits

- **Cross-Machine Continuity**: work started on one machine can be resumed on Luna with the same skills and vault context
- **Shared Agent Conventions**: Claude, Gemini, and Codex can follow the same durable workflows without duplicating setup work
- **Auditability**: skill and config changes live in a shared location rather than drifting in per-machine local folders

## Implementation Details (2026-03-13)

- Canonical Claude skills: `I:\My Drive\agentconfig\claude\skills\`
- Canonical Gemini skills: `I:\My Drive\agentconfig\gemini\skills\`
- Canonical Codex skills: `I:\My Drive\agentconfig\codex\skills\`
- Verified local Claude install: `~\.claude\skills` -> `I:\My Drive\agentconfig\claude\skills`
- Verified local Gemini install: `~\.gemini\skills` -> `I:\My Drive\agentconfig\gemini\skills`
- Codex currently has shared canonical skills prepared, but the live work session prevented replacing `~\.codex\skills` mid-session; complete that step from [[luna-setup-todo]] or after closing Codex
- Shared Codex skills created in this session:
  - `distill-session`
  - `minimal-notes`

See also: [[agent-knowledge-vault]] [[luna-setup-todo]] [[agent-skills-index]]
