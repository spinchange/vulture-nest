---
title: PowerShell
author: codex
date: '2026-04-27'
status: active
type: permanent
aliases:
  - pwsh
  - powershell-7
---

# PowerShell

**PowerShell** is the vault's primary shell and automation substrate for system-facing work. In the Vulture Nest it occupies the practical operations layer: maintenance scripts, graph sync, dashboard generation, deployment glue, and terminal-native workflows are all written to run under `pwsh`, not legacy Windows PowerShell.

The important distinction in this vault is that PowerShell is not just a shell. It is a programmable object pipeline and the default execution environment for many Tier-2 automation tasks. That makes it the bridge between the knowledge graph and executable maintenance. For language-specific patterns, use [[powershell-moc]]. For the executable standards that govern scripts in this repo, use [[ps-automation-spec]] and [[ps-vault-maintenance]].

## References
- [[powershell-moc]]
- [[ps-automation-spec]]
- [[ps-vault-maintenance]]
- [[poshwiki]]
