---
title: Verbalized Sample Skill
author: gemini-cli
date: 2026-05-02
status: active
type: permanent
aliases:
  - verbalized-sample-protocol
  - mixture-of-eccentrics-protocol
---

The **Verbalized Sample Skill** is an operational protocol designed to counteract mode collapse in Large Language Models (LLMs). While standard responses typically converge on the modal, RLHF-favored answer, this skill forces the model to surface the long tail of its response distribution, revealing creative, unconventional, or low-probability alternatives that are otherwise suppressed.

## Operational Behavior
This skill produces a structured **verbalized sample of 10 answers** drawn from across the model's response distribution. These answers are ranked from most probable (modal) to least probable (tail), each annotated with a verbalized probability estimate.

### Core Objectives
- **Counteract Mode Collapse:** Force the exploration of high-information alternatives.
- **Surface Latent Reasoning:** Reveal hidden frames, ontologies, and aesthetic commitments.
- **Maintain Calibration:** Use standardized probability notation to convey relative confidence.

## Output Structure
Every invocation of the skill MUST follow this exact format:

1. **Restated Prompt:** The user's query restated in ≤10 words.
2. **Ranked Sample (1-10):**
    - **Position 1:** The modal answer, denoted with `p ≈ X%`.
    - **Positions 2–10:** Successively lower-probability alternatives, denoted with `p ≳ Y%` (lower bounds).
    - Each entry includes 1–3 sentences of reasoning or content.
3. **Mixture of Eccentrics:** A synthesis identifying the underlying frame of the most coherent cluster found in the lower half (positions 6–10).
4. **Notes on the Distribution:** A brief reflection on the distribution's shape (peaked vs. flat) and any interesting tensions or mode-collapse resistance.

## Probability Protocol
To avoid "fake precision" or meaningless hedging, the following rules apply:
- **Notation:** Position 1 uses approximately equal (`≈`); Positions 2-10 use greater-than-or-approximately (`≳`).
- **Floor:** The minimum probability lower bound is **2%**. Below this, precise estimation is treated as ordinal rather than calibrated.
- **Non-increasing:** Probabilities must be monotonic: $p_1 \geq p_2 \geq \dots \geq p_{10}$.
- **Open Distribution:** The ten probabilities should not sum to 100%, as they do not account for the residual mass on the unenumerated tail.
- **Dynamic Range:** A successful sample should span at least an order of magnitude (e.g., 40% down to 2%).

## The "Mixture of Eccentrics"
The tail of a distribution is often asymmetric. While positions 1–3 typically share a common frame (the consensus), positions 6–10 may explore widely different axes. The **Mixture of Eccentrics** synthesis identifies the shared "move" or re-framing made by a cluster of tail answers.
- **Ranking serves the consensus; synthesis serves the eccentrics.**
- If no coherent cluster exists in the tail, it must be stated plainly rather than forcing a synthesis.

## Tail Quality Criteria
High-quality tail answers (positions 7–10) must represent coherent latent reasoning, not noise. They should pass at least two of the following tests:
- **Different Framing:** Reinterprets the core prompt.
- **Different Population:** Represents a subgroup's perspective.
- **Different Ontology:** Operates under different background assumptions.
- **Different Aesthetic:** Reflects a distinct taste or sensibility.
- **Different Timescale:** Optimizes for a different time horizon.
- **Different Stakeholder:** Prioritizes a different beneficiary.

## Harm Flagging Protocol
Safety is handled via **inline signaling** rather than refusal or censorship.
- If an answer suggests harm or significant material risk, append `⚠ flag: brief reason` after the prose for that specific answer.
- **Do not refuse the answer.** The user invokes this skill specifically to see the raw, un-collapsed distribution.
- Address flagged items briefly in the "Notes on the Distribution" section.

## Artifact Provenance
The semantic content of this skill is derived from the `verbalized-sample-SKILL.md` specification. The packaged `.skill` artifact (binary) represents the same operational protocol and adds no new semantic rules beyond the base markdown definition.

## Links
- **Concepts:** [[verbalized-sampling]], [[verbalized-sampling-experiment]], [[agent-evaluation]]
- **Literature:** [[lit-verbalized-sampling-paper]], [[lit-skills-agent-behavior]]
- **Registries:** [[agent-skills-index]], [[mcp-agent-skills]]

FOLLOWUP: Update [[agent-skills-index]] and [[mcp-agent-skills]] to include a reference to this skill as a core capability for distribution-aware reasoning.
