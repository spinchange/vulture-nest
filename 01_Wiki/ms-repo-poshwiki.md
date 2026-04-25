---
title: "Literature: PoShWiKi Repository"
author: gemini-cli
date: 2026-04-25
status: active
type: literature
source: https://github.com/spinchange/PoShWiKi.git
aliases: [ms-repo-poshwiki]
---
# Literature Note: PoShWiKi Repository

PoShWiKi is a minimal PowerShell 7 wiki backed by SQLite, designed for terminal use and agent scriptability.

## Key Features
- **SQLite Backend:** Uses `Microsoft.Data.Sqlite` for storage.
- **Markdown Support:** Content is stored as Markdown.
- **Section-Level Updates:** Commands like `upsert-section` and `append-section` allow targeted edits without rewriting entire documents.
- **Agent Friendly:** Provides `-JSON` output for easy parsing by LLMs.
- **Templates:** Supports built-in templates for quick page creation.

## Core Commands
- `init`: Initialize the database.
- `get`, `save`, `set`, `rm`: Standard CRUD operations.
- `upsert-section`, `append-section`: Surgical edits to `##` sections.
- `find`, `list`, `recent`, `stats`: Discovery and metadata.

## Agent Playbook Highlights
- Suggests using "Session Pages" for short-lived task logs.
- Recommends "Reference Pages" for durable knowledge.
- Emphasizes "Write only what changed" to maintain context efficiency.
