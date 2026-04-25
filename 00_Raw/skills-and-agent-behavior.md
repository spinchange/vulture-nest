---
tags:
  - agents
  - meta
  - skills
  - architecture
source: gemini
hostname: DESKTOP-004IHBK
date: 2026-03-13
status: active
---

# Skills and Agent Behavior

This note explains the relationship between native agent **Skills** (installed in CLI tools) and **Vault Knowledge** (markdown notes).

## Skills vs. Knowledge

| Feature | Native Skill (.skill / SKILL.md) | Vault Note (.md) |
|---|---|---|
| **Role** | **Active Rules**: Instructions injected into the agent's core system prompt. | **Passive Facts**: Data stored in the vault for the agent to reference. |
| **Activation** | **Automatic**: Triggered by keywords in the conversation (e.g., "distill"). | **Manual**: The agent must be told to read the note or find it via search. |
| **Capabilities** | **Tool-Aware**: Specifically written to use an agent's unique tools (e.g., save_memory). | **Model-Agnostic**: General text that any agent can read. |
| **Persistence** | Installed in ~/.gemini/skills or ~/.claude/skills. | Stored in I:\My Drive\mnvault. |

## Why We Need Both

To maintain a consistent [[agent-knowledge-vault]] across different models (Gemini, Claude), we use a "Native Wrapper" strategy:

1. **Vault Notes** define the *conventions* (e.g., [[minimal-notes-skill]] documentation). This is the "Human-Readable Instruction Manual."
2. **Native Skills** implement those conventions using model-specific tools. This is the "Agent-Executable Code."

## Cross-Machine Sync

Native skills are synchronized using the [[agent-configuration-sync-strategy]]. By symlinking the local skills directories to Google Drive, an update to a skill on one machine is immediately available to all agents on other machines (after a /skills reload).

## Current Implementation

Every agent in this system should have a native version of:
- **Distill Session**: To capture and version knowledge.
- **Minimal Notes**: To maintain vault structure and link integrity.

See also: [[agent-skills-index]]
