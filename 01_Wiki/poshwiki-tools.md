---
title: PoShWiKi Tools API
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [poshwiki-api, thought-api]
---
# PoShWiKi Tools API

The **PoShWiKi Tools API** is a high-level PowerShell wrapper around the PoShWiKi CLI. It standardizes how agents record durable thoughts, session logs, and goal states.

## Core Functions
- **`Invoke-WikiNote`**: Standardizes section-level updates (upserts).
- **`Invoke-WikiLog`**: Appends chronological progress to the `## Actions` section.
- **`New-WikiSeam`**: Records a session handoff point (Goal, Seam, Next Step).
- **`Get-WikiSessionTitle`**: Generates a daily session ID.

## Standardized Usage
Agents should use this API to ensure that session-level data is stored relatiionally while the primary knowledge base remains in flat YANP files.

---
## References
- [[poshwiki]]
- [[ps-automation-spec]]
- [[visitor-directives]]
