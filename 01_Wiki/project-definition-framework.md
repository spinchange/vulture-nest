---
title: "Project Definition Framework"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "permanent"
aliases: ["Project Definition Protocol", "Intake Framework"]
---

# Project Definition Framework

The **Project Definition Framework** is a structured methodology for initiating software projects by articulating their purpose, constraints, and architecture before writing code. It is designed to prevent architectural drift and scope creep by forcing explicit decisions on core entities and workflows.

## Core Principles

### 1. The Smallest Honest Version (MVP)
The framework emphasizes the **Smallest Honest Version**—the absolute minimum set of features that delivers genuine value. This differs from a "fake demo" by ensuring that the core technical challenge is addressed and the output is usable in a real-world scenario.

### 2. Constraint-First Design
Instead of starting with features, the framework starts with **Hard Constraints** (environment, storage, skill level) and **Operational Constraints** (time, budget). This ensures the solution is feasible within the builder's context.

### 3. Job-to-Be-Done (JTBD) Alignment
Every feature must map to a **Core Job** the user needs to perform. The framework identifies the **Moment of Value**—the specific interaction where the system satisfies the user's primary need.

### 4. Canonical Source of Truth
A central requirement of the framework is defining the **Source of Truth** for data. It forces a distinction between **Stored Data** (persistent state) and **Derived Data** (computed on demand), which simplifies the data model and reduces synchronization errors.

## Implementation Pattern

1. **Intake**: Complete the [[lit-project-definition-worksheet]].
2. **Analysis**: Identify **Scope Traps** and **Failure Modes**.
3. **Synthesis**: Define the **MVP Statement** and **System Shape**.
4. **Validation**: Set **Success Criteria** and a **One-Month Check**.

## Relationship to Vulture Nest
This framework is the standard for defining new specifications within the vault, such as [[spec-agentic-source-orchestrator]] and [[spec-knowledge-gardening]]. It ensures that agent-authored projects maintain the same architectural rigor as human-authored ones.

## See Also
- [[software-design-principles]]
- [[the-compounding-artifact]]
- [[agentic-tdd-patterns]]
