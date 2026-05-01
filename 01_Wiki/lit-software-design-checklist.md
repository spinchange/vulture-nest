---
title: "Literature: Software Design Checklist"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: "00_Raw/software-design-checklist.md"
aliases: ["Software Design Checklist", "Engineering Principles Checklist"]
---

# Literature: Software Design Checklist

The **Software Design Checklist** provides a step-by-step procedural guide for taking a software concept from initial spark to a structured build plan. It emphasizes naming, job-to-be-done definitions, and proportional architecture.

## Procedural Steps

### 1. Conceptual Framing
- **Naming & Definition**: Establishes what the thing *is* (script, app, library) and its intended lifespan.
- **Job to Be Done (JTBD)**: Focuses on the friction being solved and the user's primary outcome.
- **Primary User**: Maps the technical level and working environment of the first user.

### 2. Constraints & Scope
- **Non-Negotiables**: Lists hard constraints (offline-first, portable, no dependencies).
- **Bucketing**: Separates "Must-haves" from "Nice-to-haves" to ensure Version 1 is finishable.
- **MVP Statement**: A single paragraph defining the Smallest Honest Version.

### 3. Structural Design
- **System Category**: Classifies the system (CRUD, Agent Runner, etc.) to predict architecture.
- **Component Mapping**: Lists the moving pieces (Input layer, State model, Storage).
- **Data-Model-First**: Prioritizes entities and relationships over UI.

### 4. Technical Stack & Interface
- **Intentional Storage**: Justifies storage choices (Flat files vs. SQLite vs. Postgres).
- **Stack Reality**: Matches language and framework to both the job and the builder's skill.
- **Interface Model**: Justifies the choice (CLI vs. TUI vs. Web) based on user needs.

### 5. Implementation Strategy
- **Proportional Architecture**: Avoids overbuilding; prefers the simplest surviving solution.
- **Happy Path First**: Focuses on the end-to-end vertical slice before polishing.
- **Milestone Planning**: Sets natural checkpoints that can be demonstrated.

### 6. Validation & Risk
- **Risk-Based Testing**: Focuses testing on what is most likely to break or is most costly to fix.
- **Version 2 Pressure**: Captures future requirements to ensure current decisions don't block them.
- **Sanity Check**: Final blunt questions on problem-solution fit and finishability.

## Core Rules
- **"Name the thing correctly"**: Predicting architecture starts with naming the system type.
- **"Data model first"**: Most software problems are data-model problems in disguise.
- **"Architecture proportional"**: Prefer the simplest architecture that survives the next 2–3 versions.

## Relationships
- **Successor**: [[lit-project-definition-worksheet]]
- **Parallel**: [[agentic-tdd-patterns]]
- **Application**: Used in [[spec-knowledge-gardening]] for tool design.
