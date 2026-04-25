---
title: Cognitive Architectures
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [chain-of-thought-blueprint, agentic-workflows, project-lifecycle-patterns]
---

# Cognitive Architectures

A **Cognitive Architecture** for AI agents provides a structured map of how to "think" through a complex project. It prevents agents from getting stuck in **Local Minima** (fixing symptoms while missing the disease) by enforcing a clear lifecycle from discovery to verification.

## The Bespoke Software Lifecycle

To build high-quality custom software, agents should follow this standard cognitive flow:

### 1. Research (Discovery Phase)
- **Codebase Mapping:** Systematically exploring files and symbols.
- **Dependency Analysis:** Identifying how components interact.
- **Empirical Reproduction:** Confirming the current state or bug before changing anything.
- **Scope Confirmation (Gate):** Explicitly listing what is **out of scope** to prevent intent drift.
- **Output:** A **Scope Confirmation block** defining the task perimeter.

### 2. Strategy (Design Phase)
- **Architectural Alignment:** Ensuring the solution fits existing patterns (e.g., YANP).
- **Tool Selection:** Choosing the most efficient MCP tools or libraries.
- **Plan Formulation:** Drafting a step-by-step implementation guide.
- **Safety & Boundaries Checkpoint:** A mandatory pre-flight check before Execution:
    1. Are all planned write targets within authorized scope?
    2. Does the plan include irreversible operations (delete, push, overwrite uncommitted changes)?
    3. Is there a human-review requirement for this action class?
    4. Does any planned action touch secrets, credentials, or PII?
- **Output:** A written **Implementation Plan** (even a 3-bullet list).

### 3. Execution (The Act-Validate Loop)
- **Surgical Implementation:** Applying targeted changes strictly related to the sub-task.
- **Automated Verification:** Running tests or linters immediately after changes.
- **Refinement:** Adjusting the approach based on system feedback.
- **Loop Termination:** If verification fails after **3 iterations**, the agent must stop, record the failure state, and escalate to human review.
- **Output:** A **Passing Test Run** or a detailed Failure Report.

### 4. Finalization (System Integrity)
- **Cross-Linkage:** Integrating new notes or code into the broader graph.
- **Regression Check:** Running broken-link and orphan scanners to ensure no side-effect errors were introduced.
- **Portal Update:** Synchronizing dashboards and indices.
- **Output:** A green **run-maintenance.ps1** result.

## Agentic Workflow Patterns (Andrew Ng)

Frontier models leverage these four patterns to increase performance:

1. **Reflection:** The agent critiquing its own output to fix hallucinations or logic gaps.
2. **Planning:** Breaking a high-level goal into a sequence of executable steps.
3. **Tool Use:** Leveraging external capabilities (calculators, web search, database queries).
4. **Multi-Agent Collaboration:** Dividing labor among specialized personas (e.g., Architect, Coder, Judge).

## Framework Implementation: LangGraph
Frameworks like [[langgraph]] enable these architectures by representing the lifecycle as a **Stateful Graph**. This ensures that the agent's "shared memory" (State) persists across the entire project lifecycle, allowing for loops, branches, and Human-in-the-Loop checkpoints.

---
## References
- [[agentic-frameworks-moc]]
- [[agent-thought-cycle]]
- [[agentic-tdd-patterns]]
- [[langgraph]]
