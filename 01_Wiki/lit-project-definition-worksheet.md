---
title: "Literature: Project Definition Worksheet"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: "[[00_Raw/project-definition-worksheet.md]]"
aliases: ["Project Definition Worksheet", "Build Intake Template"]
---

# Literature: Project Definition Worksheet

The **Project Definition Worksheet** is a comprehensive diagnostic and planning tool used to ground software projects before deep implementation. It prioritizes clarity over completeness and serves as a "build intake" form for developers and AI collaborators.

## Key Sections

### 1. Identity & Purpose
- **Project Identity**: Defines names and one-sentence core definitions.
- **Problem Statement**: Focuses on the real-world friction being solved rather than just the software idea.
- **Outcome**: Defines what changes for the user after the system exists.

### 2. User & Jobs to Be Done
- **User Profile**: Maps technical comfort, frequency of use, and environment.
- **Core Jobs**: Lists the essential tasks the user must accomplish.
- **Moment of Value**: Identifies the "Aha!" moment where the project proves its utility.

### 3. Constraints & Scope
- **Hard Constraints**: Operating systems, data storage, connectivity, and skills.
- **MVP Definition**: Defines the "Smallest Honest Version" that provides real value.
- **Scope Traps**: Explicitly identifies what is out of scope to prevent feature creep.

### 4. System Architecture
- **System Shape**: Classifies the project (e.g., CRUD, Parser, Agent Orchestration).
- **Data Model**: Defines main entities (nouns), their relationships, and the canonical Source of Truth.
- **Interface & Storage**: Justifies the choice of UI (CLI, GUI, etc.) and persistence (SQLite, Flat Files, etc.).

### 5. Risk & Validation
- **Failure Modes**: Distinguishes between "what can go wrong" (likely failures) and "what must never happen" (catastrophic failures).
- **Milestones**: Sets clear markers for progress.
- **Success Criteria**: Defines both qualitative and quantitative success/failure metrics.

## Strategic Concepts
- **Smallest Honest Version**: A proof of concept that is genuinely useful, not just a demo.
- **Source of Truth**: The definitive location for stored vs. derived data.
- **Version 2 Pressure**: Identifying future needs without optimizing for them prematurely.

## Relationships
- **Predecessor**: [[software-design-checklist]]
- **Application**: Used in [[spec-agentic-source-orchestrator]] for defining ingestion workflows.
