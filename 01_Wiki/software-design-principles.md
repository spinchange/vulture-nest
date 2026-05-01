---
title: "Software Design Principles"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "permanent"
aliases: ["Engineering Wisdom", "Design Rules of Thumb"]
---

# Software Design Principles

**Software Design Principles** are heuristic-based rules that guide the construction of durable, maintainable, and proportional systems. Unlike rigid patterns, these principles focus on the relationship between the problem, the builder, and the machine.

## Core Principles

### 1. Proportional Architecture
Architecture should be proportional to the project's complexity and intended lifespan. 
- **Rule**: Prefer the simplest architecture that can survive the next 2–3 versions.
- **Goal**: Avoid "accidental complexity" and "over-abstraction" before they are needed.

### 2. Data-Model-First Development
Most software problems are essentially data-model problems in disguise.
- **Rule**: Define nouns (entities), fields, and relationships before designing the UI or interaction model.
- **Stored vs. Derived**: Explicitly distinguish between persistent state and computed output to reduce synchronization bugs.

### 3. Vertical Happy Path
Build the "Happy Path" vertical slice first—from input to storage to output.
- **Rule**: Prove the core loop end-to-end before expanding into edge cases or polish.
- **Goal**: Teaches the most about the system's viability early in the build.

### 4. Risk-Based Testing
Automated tests should be prioritized based on risk rather than code coverage.
- **Rule**: Test what is most likely to break, what is most costly if wrong, and what is hardest to manually verify.
- **Strategy**: Unit tests for logic transforms (parsing, validation); Integration tests for state cycles (save/load).

### 5. Intrinsic Documentation
A system's naming and structure should reflect its intent.
- **Rule**: Name the system category correctly (Script vs. Library vs. Service) to set the architectural expectations.
- **Clarity over Polish**: Readable code is a more valuable asset than "clever" code during the early stages of a project.

### 6. Managing "Version 2 Pressure"
Good design leaves room for future expansions without optimizing for them prematurely.
- **Rule**: Capture "what Version 2 probably wants" in a note, then ignore it for Version 1 development.

## Implementation Tools
- [[lit-software-design-checklist]]: A procedural pass for project initialization.
- [[project-definition-framework]]: A structured intake process.
- [[agentic-tdd-patterns]]: Applying these principles to AI-led development.

## Relationship to Vulture Nest
These principles govern how the Nest's internal tools (e.g., `run-maintenance.ps1`, `epistemic_classifier.py`) are designed. They ensure the vault remains an **Executable Knowledge** base where the "Knowledge is the Code."

## See Also
- [[the-compounding-artifact]]
- [[wiki-as-codebase]]
- [[plain-plus-design]]
