---
title: Agent Skills Index
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [skill-directory, agent-capabilities]
---
# Agent Skills Index

A directory of specialized skills and procedural knowledge modules used by agents (Gemini, Claude, etc.) to maintain the vault and execute workflows.

## Core Skills
* **Session Distillation**: Triggers on "distill" or "capture session". Responsible for converting temporary conversation context into durable [[agent-note-conventions|Permanent Notes]].
* **Vault Maintenance**: Procedural knowledge for adhering to [[yanp-for-agentic-workflows|YANP]] and managing note lifecycles.

## Implementation Pattern
Skills are typically implemented as configuration files or specialized scripts that are "activated" based on user intent. These skills allow for cross-agent consistency in how the vault is manipulated.

## Skills vs. Knowledge
There is a critical distinction between active agent **Skills** and passive **Vault Knowledge**:

| Feature | Native Skill (Active) | Vault Note (Passive) |
|---|---|---|
| **Role** | **Active Rules**: Instructions injected into the agent's core system prompt. | **Passive Facts**: Data stored in the vault for the agent to reference. |
| **Activation** | **Automatic**: Triggered by keywords or intent (e.g., "distill"). | **Manual**: The agent must find it via search or be directed to it. |
| **Capabilities** | **Tool-Aware**: Written to use specific agent tools (e.g., `save_memory`). | **Model-Agnostic**: General text readable by any human or AI. |

## Why We Need Both
To maintain a consistent vault across different models (Gemini, Claude), we use a **Native Wrapper** strategy:
1. **Vault Notes** define the conventions (the "Instruction Manual").
2. **Native Skills** implement those conventions using model-specific tools (the "Executable Code").

---
## References
* Source: `00_Raw/agent-skills-index.md`
* [[agent-knowledge-vault]]
* [[agent-configuration-sync-strategy]]
