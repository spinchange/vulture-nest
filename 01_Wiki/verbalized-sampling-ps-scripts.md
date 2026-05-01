---
title: Verbalized Sampling — [[powershell|PowerShell]] Script Ideas
author: claude-code
hostname: LYRA
date: 2026-04-26
status: active
type: permanent
aliases: [vs-ps-ideas, verbalized-sampling-scripts, tail-distribution-ps]
---
# Verbalized Sampling — PowerShell Script Ideas

Five candidate PowerShell scripts for unlocking tail-distribution and latent-diverse knowledge from an aligned LLM using verbalized sampling techniques. All five are buildable against the Claude API with `Invoke-RestMethod`. The probability verbalization in each is structural, not cosmetic — it is what lets the script steer toward the tail rather than relying on temperature alone.

## Idea 1 — Probability-Ranked Variation Generator

Prompt the model to produce N variations of a response and self-assign a `P(%)` score representing "how likely the modal response would include this." The script filters out anything above 50% and retains only the tail. Each retained tail item becomes the seed for the next round — a **tail-chasing ratchet** that drifts progressively away from the prior without changing model weights.

Key mechanisms: explicit probability labeling per variation, loop-based seed replacement, threshold filter as a dial.

## Idea 2 — Stepwise Distribution-Shift Chain

Each API call opens with: *"State what you would most probably say (P≈X%), then deliberately shift your answer one step toward a valid but underrepresented response and assign a new P."* The script chains 4–6 iterations, accumulates the shift log, and terminates when it reaches a configured floor (e.g. P < 10%).

Key mechanisms: chain-of-thought as the steering mechanism, verbalized P as the progress metric, configurable floor parameter.

## Idea 3 — Self-Calibrated Top-N Tail Extractor

Prompts the model to enumerate its top-10 responses to a question in descending probability order, explicitly labeling each rank and approximate P. The script discards ranks 1–6 and submits ranks 7–10 as context for a follow-up generation pass. Ranks 7–10 consistently surface creative, training-edge knowledge that the model suppresses in a single-shot prompt.

Key mechanisms: one-shot top-N enumeration, rank-based slice, two-pass structure (enumerate then generate).

## Idea 4 — Contrastive Corpus Persona Probe

Two-stage call structure. Stage 1: *"What would a model trained only on mainstream sources say? (P≈?%)"*. Stage 2: *"What would a model trained on [rare/specialized corpus] say? (P≈?%)"*. The script computes semantic distance between the two outputs and flags divergences above a threshold as unlocked knowledge. Probability verbalization anchors both stages and makes the contrast measurable.

Key mechanisms: counterfactual corpus framing, semantic diff scoring, threshold-flagged divergence output.

## Idea 5 — Cross-Persona Confidence-Weighted Ensemble

Issues one API call per persona (e.g., statistician, domain expert, contrarian, child, historian) with a shared question. Each call instructs: *"verbalize your confidence as P(%) that a randomly sampled human expert would agree."* The script collects all responses, inverts the scores (low-confidence = high novelty weight), and synthesizes a final response that preferentially incorporates low-P but internally consistent insights.

Key mechanisms: multi-call persona matrix, inverted confidence weighting, synthesis pass from the weighted minority.

---

## Common Affordances

All five scripts share a common structural approach:

- system prompt establishes the verbalized-sampling contract upfront
- user prompt delivers the actual question
- a parsing pass extracts the `P(%)` values from the response text
- output is structured (PSCustomObject or JSON) so results can feed downstream tooling or vault notes

The main implementation variable is how aggressively to filter: a strict P < 10% floor gives maximum novelty but higher incoherence risk; P < 30% is a safer starting point.

---
## See Also
- [[verbalized-sampling]]
- [[verbalized-sampling-experiment]]
- [[experiments-moc]]
- [[powershell-moc]]
- [[function-calling]]

---

## 2026-04-26 13:40 · LYRA · claude-code

### Idea 3 — Three Approach Plans (Agent Comparison)

Three parallel planning agents were run against Idea 3 (Self-Calibrated Top-N Tail Extractor), each given a distinct architectural premise. Results compared below.

#### Head-to-Head

| | **A: Flat Enumeration** | **B: Mode-Anchored Departure** | **C: Tournament-Rank** |
|---|---|---|---|
| API calls | 2 | 2 | 11 |
| Approx. cost | ~$0.05 | ~$0.06 | ~$0.26 |
| Latency | ~5s | ~6s | ~30–45s |
| Tail identification | Rank order only | Departure distance from modal | Borda count over pairwise rounds |
| P(%) role | Metadata (not steering) | Structural anchor | Not used |
| Core failure mode | Format compliance | Modal collapse into meta-response | JSON parse failures + positional bias |
| Parsing complexity | Single regex | Two-phase regex | JSON + tournament aggregation |
| Graceful degradation | Rank-only fallback | Pseudo-anchor fallback | Skip failed groups, ambiguity flag |
| Call 2 quality | Tail items as seeds | Modal + tail = contrast framing | "Suppressed ideas" framing |

#### Decisive Differences

**A vs B:** Both are 2-call pipelines at nearly identical cost. B adds one structural change: the model first identifies its modal response, then enumerates 9 departures explicitly ranked by departure distance from that anchor. This makes the tail items genuinely non-modal rather than stylistically varied. B also includes a reversion detection step — if Call 2's output too closely resembles the modal, it sets `ParseWarning = "Call2Reversion"`.

**B vs C:** C is the most calibrated approach (pairwise comparison is more reliable than absolute P assignment), but at 11 calls it is a research-grade instrument. C also identified a non-obvious problem absent from A and B: positional bias — models tend to label whatever appears first as "most default." C mitigates this by randomizing candidate order within each tournament batch before labeling. B avoids the problem entirely because the modal is explicitly named upfront, not inferred from a ranking.

**A vs C:** A's verbalized probabilities are metadata. C's Borda scores are mechanically derived from comparisons. C wins for reproducible tail identification across runs; A wins for fast iteration and minimal cost.

#### Recommendation

**Build B first** (`verbalized-sampling.ps1`). It is 2 calls like A but the departure framing is the strongest mechanism for reaching actual tail knowledge. The modal anchor gives Call 2 an explicit contrast target, which is what makes the synthesized output surprising rather than just off-format. The primary failure mode (modal collapse) is detectable and recoverable.

**Keep A as fallback/debug** (`invoke-tail-extractor.ps1`). Simpler to reason about when B's output looks wrong.

**Build C later** (`invoke-verbalised-sampling.ps1`) once the concept is validated and reproducibility becomes a requirement. The Swiss-system + Borda plan is clean; codebase analogues exist in `sync-embeddings.ps1` (retry) and `suggest-links.ps1` (score aggregation).

#### Script Names Proposed by Agents

- A → `02_System/invoke-tail-extractor.ps1`
- B → `02_System/verbalized-sampling.ps1`
- C → `02_System/invoke-verbalised-sampling.ps1`

