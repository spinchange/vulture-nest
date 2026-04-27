---
title: HITL UI Patterns
author: gemini-cli
date: '2026-04-26'
status: active
type: permanent
aliases:
  - human-in-the-loop
  - agent-approvals
  - hitl-design
---
# HITL UI Patterns

Human-in-the-loop (HITL) UI patterns balance agent autonomy with human oversight, evolving beyond simple binary approvals into sophisticated collaboration models.

## 1. Core Interaction Patterns
*   **Approval Gate (Interrupt & Resume)**: The agent pauses and waits for user approval before executing a specific action.
*   **Confidence-Based Routing**: The agent only requests help when its internal confidence score falls below a threshold.
*   **Collaborative Drafting**: The agent presents a draft that the human can refine in an inline editor before the agent continues.
*   **Strategic Guidance (Fork in the Road)**: The agent asks the user to "Set Direction" at critical decision points rather than just approving a task.

## 2. UI/UX Design Principles
*   **Decision-Ready Narratives**: Summarize the **Intent**, **Action**, and **Impact** rather than showing raw JSON.
*   **Irreversibility Highlighting**: Use visual cues (e.g., red borders) for high-risk, non-undoable actions like data deletion.
*   **Active Engagement**: Require the user to answer a question or highlight text before the "Approve" button activates to prevent rubber-stamping.

## 3. Risk Classification Tiers
*   **Low Risk (Reversible)**: Auto-execute + Audit Log.
*   **Medium Risk (Uncertain)**: Confidence-based review.
*   **High Risk (Irreversible)**: Mandatory Approval Gate.

---
## References
* [[agent-thought-cycle]]
* [[orchestration-tradeoffs]]
* [[agentic-frameworks-moc]]
