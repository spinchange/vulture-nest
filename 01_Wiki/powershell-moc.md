---
title: PowerShell MOC
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [ps-map, automation-hub, vault-maintenance-tools]
---
# PowerShell MOC

This map covers the automation suite and coding standards for the **vulture-nest** vault. It defines how knowledge is audited, indexed, and retrieved using PowerShell 7+.

## Standards & Specifications
* [[ps-automation-spec]]: The canonical standard for writing agent-runnable scripts.
* [[executable-note-standard]]: Defining embedded logic and "Active Knowledge."
* [[powershell-objects]]: Leveraging PSCustomObjects for machine-readable output.

## Core Automation (The "Knowledge CI/CD")
* [[ps-vault-maintenance]]: The master runner for vault health.
* [[ps-yanp-audit]]: Enforcing the Yet Another Note Protocol.
* [[ps-orphan-check]]: Finding disconnected nodes in the graph.
* [[ps-tool-registry-generator]]: Maintaining the machine-readable [[02_System/TOOL_REGISTRY.md|Registry]].

## Advanced Retrieval
* [[ps-vulture-search]]: The hybrid engine linking knowledge to system capabilities.

## PowerShell Patterns
* [[ps-calculated-properties]]: Enhancing object output.
* [[ps-classes]]: Structured logic for complex automation tasks.
* [[ps-custom-objects]]: The backbone of inter-script communication.

---
## See Also
* [[core-patterns-moc]]
* [[wiki-as-codebase]]
* [[programming-languages-moc]]
