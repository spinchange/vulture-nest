---
title: Agent Skills Index
author: claude-sonnet-4-6
date: 2026-05-02
status: active
type: permanent
aliases: [skill-directory, agent-capabilities]
---
# Agent Skills Index

A directory of specialized skills and procedural knowledge modules used by agents (Gemini, Claude, etc.) to maintain the vault and execute workflows.

## Core Skills
* **Session Distillation**: Triggers on "distill" or "capture session". Responsible for converting temporary conversation context into durable [[agent-note-conventions|Permanent Notes]].
* **Vault Maintenance**: Procedural knowledge for adhering to [[yanp-for-agentic-workflows|YANP]] and managing note lifecycles.

## .NET Agentic Stack (Tier-1, Planned)

> These five notes are planned but do not yet exist in the vault. Links are aspirational stubs pending synthesis from source material in `00_Raw/`.

* `dotnet-agent-integration` — Main architectural bridge for .NET/C# in agentic loops.
* `csharp-mcp-sdk` — Building type-safe, performance-critical MCP servers.
* `lm-kit-dotnet` — On-device inference and GGUF integration for .NET agents.
* `foundry-local` — Local ONNX inference with OpenAI-compatible interfaces.
* `microsoft-data-sqlite-agent-patterns` — Lightweight, idempotent memory services.

## Implementation Pattern

Skills are injected into an agent's context at session start or loaded on demand. Three concrete forms in this fleet:

* **Slash-command skills** (Claude Code): A skill file (e.g., `session-distillation.md`) loaded by the harness when the user types the corresponding slash command (e.g., `/distill`). The skill text becomes part of the active context and instructs Claude to call `save_memory()` with a structured summary.
* **Instruction-set skills** (Gemini CLI): A named section in the system prompt or `GEMINI.md` referencing vault conventions — e.g., the YANP compliance block that instructs Gemini to call `write_file()` with correct frontmatter whenever it synthesizes a new note.
* **PowerShell scripts** (Codex): Automation scripts in `02_System/` (e.g., `audit-yanp.ps1`) that encode vault health rules as executable checks, run by the Codex engineer on demand or in CI.

All three forms encode the same conventions; they differ only in the native tool API each model exposes.

## Skills vs. Knowledge
There is a critical distinction between active agent **Skills** and passive **Vault Knowledge**:

| Feature | Native Skill (Active) | Vault Note (Passive) |
|---|---|---|
| **Role** | **Active Rules**: Instructions injected into the agent's core system prompt. | **Passive Facts**: Data stored in the vault for the agent to reference. |
| **Activation** | **System-prompt injection**: Prepended to the agent's context at session start, or loaded on demand via a slash command (e.g., `/distill` loads the distillation skill, which then calls `save_memory()`). | **Manual**: The agent must find it via search or be directed to it. |
| **Capabilities** | **Tool-Aware**: Written to use specific agent tools (e.g., `save_memory`, `write_file`). | **Convention-aware prose**: Human-readable text that requires an agent configured for this vault's YANP conventions to use correctly; not universally parseable by arbitrary models. |

## Why We Need Both

> **Status: Active** — This pattern is in current use across all three fleet members (Gemini, Claude, Codex).

To maintain a consistent vault across different models, we use a **Native Wrapper** strategy:
1. **Vault Notes** define the conventions (the "Instruction Manual").
2. **Native Skills** implement those conventions using model-specific tools (the "Executable Code").

The strategy exists because each model exposes different tool APIs (`save_memory` vs. `write_file` vs. PowerShell) — a single YANP-compliant outcome requires model-specific wiring around a shared convention.

---
## References
* Source: `00_Raw/agent-skills-index.md`
* [[agent-knowledge-vault]]
* [[agent-configuration-sync-strategy]]
- [[mcp-agent-skills]]
- [[agentic-frameworks-moc]]

