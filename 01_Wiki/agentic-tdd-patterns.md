---
title: Agentic TDD Patterns
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [llm-tdd, evaluation-driven-development, edd, agent-testing]
---

# Agentic TDD Patterns

Test-Driven Development (TDD) for agents shifts the focus from deterministic unit tests to **Evaluation-Driven Development (EDD)**. This protocol allows frontier models to build bespoke software with high reliability by treating tests as "Executable Intent."

## The Agentic Red-Green-Refactor Loop

1. **RED (Intent):** The agent (or user) defines a **Scenario Note** or a failing test script.
   - For logic: A standard test file (e.g., `pytest`, `Pester`, `xUnit`).
   - For behavior: A "Judge" rubric or a prompt-evaluator configuration.
2. **GREEN (Implementation):** The agent modifies the codebase or its own system prompt to satisfy the test.
3. **REFACTOR (Optimization):** The agent optimizes the implementation for performance or token cost, ensuring the suite remains "Green."

## High-Leverage Patterns

### 1. Scenario-Based Testing
Instead of testing isolated functions, define a "User Story" as a test case.
- **Example:** "When a user provides a raw PDF, the system must extract the title and link it to the index."
- **Agent Action:** The agent must prove it can complete the full chain before the task is considered "Done."

### 2. The "Judge" Evaluation
For non-deterministic outputs (like summaries), use a second agent (The Judge) to grade the primary agent's output against a specific rubric.
- **Pass Criteria:** A score of ≥ 85/100 or a boolean "Meets all directives."

### 3. Property-Based Invariants
Test for things that must *always* be true, regardless of the specific text output.
- Every note created must be lowercase-kebab-case.
- Every note must have valid YAML frontmatter.
- No PII (secrets, keys) may ever be logged to `02_System/log.md`.

## Executable Specifications
In a bespoke software context, the **Technical Design Document (TDD)** serves as the "Spec." Agents should read the TDD in `00_Raw/` and generate a test suite in `tests/` *before* writing a single line of production code.

---
## References
- [[executable-note-standard]]
- [[agent-thought-cycle]]
- [[yanp-for-agentic-workflows]]
