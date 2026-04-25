---
tags:
  - meta
  - agents
  - skills
source: codex
hostname: DESKTOP-004IHBK
date: 2026-03-13
status: active
---

# Agent Skills Index

A directory of specialized skills installed for Claude, Gemini, and Codex to maintain the shared vault and agent workflow.

## Current Skills

### [[distill-session-skill]]
- **Purpose**: Captures session context and writes durable notes and follow-up state.
- **Trigger**: "distill", "save this session", "capture what we discussed".
- **Locations**:
  - Gemini: `I:\My Drive\agentconfig\gemini\skills\distill-session.skill`
  - Claude: `I:\My Drive\agentconfig\claude\skills\distill-session\`
  - Codex: `I:\My Drive\agentconfig\codex\skills\distill-session\`

### [[minimal-notes-skill]]
- **Purpose**: Procedural knowledge for using the `note` CLI and maintaining vault conventions.
- **Trigger**: Any request to create, move, distill into, or link notes in the shared vault.
- **Locations**:
  - Gemini: `I:\My Drive\agentconfig\gemini\skills\minimal-notes\`
  - Codex: `I:\My Drive\agentconfig\codex\skills\minimal-notes\`

## Sync Strategy

Canonical skill sources live in `I:\My Drive\agentconfig\` and are symlinked into each agent's local default config location. See also: [[agent-configuration-sync-strategy]] [[agent-skill-infrastructure]]
