---
title: [[agent-development-kit|ADK]] Evaluation Framework
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - adk-evaluation
  - adk-eval
  - trajectory-evaluation
  - EvalSet
  - EvalCase
type: permanent
---

# ADK Evaluation Framework

The [[agent-development-kit|ADK]] documentation presents evaluation as a first-class part of the agent lifecycle. In this vault, the key distinction is between evaluating only the final answer and evaluating the broader **agent trajectory** that produced it.

## 1. Core Evaluation Philosophy
*   **Final Output vs. Trajectory:** An agent can arrive at a correct result through an inefficient or unsafe process. Trajectory-aware evaluation tries to inspect both the answer and the steps.
*   **Non-Deterministic Assertions:** Because agent outputs are probabilistic, some evaluation paths use rubrics or [[llm-as-a-judge]]-style scoring instead of pure binary assertions.

## 2. Evaluation Sets (`.test.json`)
The ADK docs describe JSON-backed evaluation artifacts such as `EvalSet` and `EvalCase`.
*   **EvalCase:** A single scenario, typically including input, expected outcome, and sometimes expected tool behavior.
*   **EvalSet:** A collection of cases evaluated together.

These names are useful working vocabulary in the vault, but this note does not attempt to serve as a full schema reference.

## 3. Evaluation Criteria & Metrics
The literature source discusses several recurring evaluation styles:
*   **Trajectory Matching:** Compare tool use or workflow steps against an expected pattern.
*   **Rubric-Based Scoring:** Grade the response against explicit criteria.
*   **Ground-Truth Comparison:** Compare the final output against a known reference.

Treat these as documented evaluation modes and patterns, not as a claim that every metric is equally mature or always available in the same workflow surface.

## 4. Running Evaluations

### CLI (`adk eval`)
Run batch evaluations from the terminal.
```bash
adk eval my_eval_set.test.json
```

### Programmatic (`pytest`)
Programmatic execution allows evaluation suites to participate in normal CI flows alongside tests and regression checks.

### Web UI (`adk web`)
The ADK docs also describe a web UI workflow for interactive testing and debugging. Treat that as a developer-facing inspection surface rather than a replacement for repeatable offline evaluation.

## 5. Scope and Limits
- This note describes the evaluation concepts surfaced in the ADK documentation snapshot, not a complete feature matrix.
- It does not claim that integrations, metrics, or UI features have identical maturity across all ADK languages.
- Evaluation here focuses on behavior quality and workflow correctness, not full operational concerns such as latency budgets or cost accounting.

## See Also
- [[agent-development-kit]]
- [[agent-evaluation]]
- [[llm-as-a-judge]]
- [[lit-adk-documentation]]

---
*Source: [[lit-adk-documentation]]*

