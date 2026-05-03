---
title: Agentic TDD Patterns
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [llm-tdd, evaluation-driven-development, edd]
---

# Agentic TDD Patterns

Test-Driven Development for agentic systems extends normal TDD with evaluation, rubric checks, and workflow-level verification. The core idea is still test-first discipline; the difference is that some agent behaviors require richer checks than a deterministic unit assertion.

## The Agentic Red-Green-Refactor Loop

1. **RED (Intent):** The agent (or user) defines a **Scenario Note** or a failing test script.
   - For logic: A standard test file (e.g., `pytest`, `Pester`, `xUnit`).
   - For behavior: A rubric, evaluator configuration, or judged scenario.
2. **GREEN (Implementation):** The agent modifies the codebase or its own system prompt to satisfy the test.
3. **REFACTOR (Optimization):** The agent optimizes the implementation for performance or token cost, ensuring the suite remains "Green."

## High-Leverage Patterns

### 1. Scenario-Based Testing
Instead of testing isolated functions, define a "User Story" as a test case.
- **Example:** "When a user provides a raw PDF, the system must extract the title and link it to the index."
- **Agent Action:** The agent must prove it can complete the full chain before the task is considered "Done."

### 2. The "Judge" Evaluation
For non-deterministic outputs (like summaries), use a second agent (The Judge) to grade the primary agent's output against a specific rubric.
- **Pass Criteria:** Thresholds such as `85/100` are project choices, not universal defaults. For important flows, pair judge scores with spot human review or multiple checks to reduce score gaming and judge drift.

### 3. Structural Constraints and Invariants
Test for things that must remain true regardless of the exact wording of the output.
- Every note created must be lowercase-kebab-case.
- Every note must have valid YAML frontmatter.
- No PII (secrets, keys) may ever be logged to `02_System/log.md`.

## Spec-First Development for Agents
In this vault, a design note or implementation spec can act as executable intent: the agent reads the spec, derives tests or evaluation cases, and only then begins implementation. That is compatible with TDD, but it should not be confused with renaming the methodology itself.

## Limits
- Agentic TDD is an emerging practice, not a settled discipline with universal terminology.
- Rubric-based judging is useful, but it adds its own failure modes: inconsistent scoring, shallow proxies for quality, and susceptibility to prompt framing.
- Some checks belong in normal unit tests; others belong in scenario evaluation. Mixing them indiscriminately makes failures harder to interpret.

---
## References
- [[agent-evaluation]]
- [[llm-as-a-judge]]
- [[executable-note-standard]]
- [[agent-thought-cycle]]
- [[yanp-for-agentic-workflows]]
