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

The [[agent-development-kit|ADK]] provides a comprehensive, schema-driven framework for assessing agent performance. Unlike simple LLM benchmarks, ADK evaluation focuses on the **Agent Trajectory**—the sequence of decisions and actions taken to reach a goal.

## 1. Core Evaluation Philosophy
*   **Final Output vs. Trajectory:** An agent might get the right answer through a flawed process (e.g., inefficient tool calls). ADK evaluates both the result and the "how."
*   **Non-Deterministic Assertions:** Since agents are probabilistic, ADK moves beyond binary pass/fail to qualitative scoring using rubrics and LLM-based "judges."

## 2. Evaluation Sets (`.test.json`)
Evaluations are defined in JSON files using standard schemas (`EvalSet` and `EvalCase`).
*   **EvalCase:** Represents a single interaction scenario. Includes the input query, the expected result (ground truth), and potentially the expected tool trajectory.
*   **EvalSet:** A collection of evaluation cases.

## 3. Evaluation Criteria & Metrics
ADK supports multiple built-in criteria:
*   **Trajectory Matching:** Compares the agent's tool calls against a known "correct" sequence.
*   **Rubric-Based Scoring:** Uses an LLM to grade the response based on a specific set of rules (e.g., politeness, accuracy, conciseness).
*   **Ground-Truth Comparison:** Directly compares the final output against a reference answer.

## 4. Running Evaluations

### CLI (`adk eval`)
Run batch evaluations from the terminal.
```bash
adk eval my_eval_set.test.json
```

### Programmatic (`pytest`)
Integrate evaluations into standard CI/CD pipelines.

### Web UI (`adk web`)
An interactive mode where developers can:
1.  Run a live session with an agent.
2.  "Add current session" to a test set.
3.  Visually inspect failures and step through trajectories.

## 5. Ecosystem Integrations
ADK is designed to work with production observability and evaluation platforms:
*   **Arize Phoenix / AX:** For tracing and dataset management.
*   **Freeplay:** For prompt management and team-based evaluation.
*   **Galileo:** For online monitoring and safety scoring.

---
*Source: [[lit-adk-documentation]]*

