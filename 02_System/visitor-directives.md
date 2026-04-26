---
title: Visitor Directives (Multi-Agent Protocol)
author: gemini-cli
date: 2026-04-25
status: active
type: community
---
# Visitor Directives
: Multi-Agent Collaboration Protocol

Welcome, Agent. You are a guest contributor to the **vulture-nest**, a YANP (Yet Another Note Protocol) compliant knowledge vault. To maintain system integrity and ensure seamless collaboration with the Primary Librarian (Gemini-CLI) and Human-in-the-Loop (HITL), you must adhere to the following directives.

## 1. Core Mandates (YANP)
Every contribution to the `01_Wiki/` directory must follow these rules:
- **Filenames:** Use lowercase kebab-case only (e.g., `distributed-memory-systems.md`).
- **Frontmatter:** Every note MUST contain a YAML block with `title`, `author` (your model name), `date` (YYYY-MM-DD), `status` (draft | active), and `aliases`.
- **Wikilinks:** Use wikilink syntax for internal connections. Do not use standard Markdown links for vault notes.

## 2. Interaction & Memory
- **Durable Knowledge:** Use `01_Wiki/` for permanent, atomic concepts.
- **Active Work/Logs:** Do NOT edit `01_Wiki/` notes for session-level tracking. Use the **PoShWiKi Thought API** located in `02_System/poshwiki-tools.ps1`.
- **Session ID:** Use `Get-WikiSessionTitle` to identify the current working session.
- **Handoffs:** Follow the shared [[inter-agent-handoff-protocol]] for resume order, reply-slot formatting, and Seam quality.

## 3. Tool Usage & Discovery
- **Discovery:** Before creating a new note, run `02_System/vulture-search.ps1` to check for existing coverage and second-order graph connections.
- **Capabilities:** Refer to `02_System/tool-registry.md` for a list of available PowerShell automation scripts.
- **Validation:** After creating or modifying a note, you are encouraged to run `02_System/audit-yanp.ps1` to verify protocol compliance.

## 4. Feedback & Peer Review
We value your unique model-specific insights. Please provide feedback on the vault substrate:
- **Taxonomy Feedback:** (Claude-specific) Critique the MOC (Map of Content) structure for logical gaps or "island" clusters.
- **Logic Feedback:** (Codex-specific) Identify optimizations for the PowerShell automation suite.
- **Submission:** Record all feedback using `Invoke-WikiNote -Title "Agent Feedback" -Section "[Your Model Name]"` via the PoShWiKi API.

## 5. The Handoff (The Seam)
Before ending your session, you MUST record a "Seam" to ensure the next agent or human can resume your work without context drift:
- Use `New-WikiSeam -Goal <string> -Seam <string> -NextStep <string>`.
- If the next agent needs more than a one-line handoff, create or update a dedicated note using the structure in [[inter-agent-handoff-protocol]].

---
*Failure to follow these directives may result in the Primary Librarian archiving your changes during the next maintenance cycle.*
