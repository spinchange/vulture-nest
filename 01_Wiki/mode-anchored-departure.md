---
title: Mode-Anchored Departure (Verbalized Sampling Approach B)
author: claude-sonnet-4-6
date: '2026-04-28'
status: active
type: permanent
aliases: [approach-b, mad-sampling, mode-anchored-departure, vs-approach-b]
---

# Mode-Anchored Departure (Verbalized Sampling Approach B)

**Mode-Anchored Departure (MAD)** is the two-call verbalized sampling pipeline implemented in [[verbalized-sampling-ps-scripts]] as `verbalized-sampling.ps1`. It is "Approach B" in the three-way design comparison documented there, selected over flat enumeration (A) and tournament-rank (C) for its departure-distance framing and 2-call cost.

The core mechanism: the model first names its modal response explicitly, then enumerates departures ranked by distance from that anchor. This makes tail items genuinely non-modal, not just stylistically varied.

---

## How It Works

### Call 1 — Modal Anchor + Departure Enumeration

The model is asked to:
1. State its **modal response** — the completion a typical unguided LLM run would produce — and assign it a `P≈X%` estimate
2. Enumerate **9 departures** in ascending departure-distance order (Rank 1 = closest to modal, Rank 9 = furthest), each with a departure tag and its own `P≈X%`

The modal anchor is what distinguishes Approach B from Approach A. In A, departure distance is inferred from rank order alone. In B, it is measured against an explicit reference point. This matters because the model can name what it is departing *from*, making the Call 2 contrast frame concrete.

### Call 2 — Tail Synthesis

Tail departures (default: ranks 7–9) plus the modal are submitted as context for a synthesis pass. The synthesis prompt instructs the model to integrate the tail insights into a substantive response that the modal would not contain — not a list or rephrase of the departures, but a genuinely novel perspective.

Reversion detection runs a Jaccard similarity check between the synthesis and the modal. A score above 0.60 sets `ParseWarning = Call2Reversion`.

---

## The P≈ Statistic

`P≈X%` means: **the estimated probability that a typical, unguided LLM completion would produce this response** (or one closely matching it).

This is defined by the system prompt:
> *P=80% is very default; P=5% is deep tail, normally suppressed by alignment pressure.*

### What P≈ Is and Is Not

P≈ is a **verbalized probability** — the model is generating contextually appropriate probability-language, not reading an internal meter. The [[lit-verbalized-sampling-paper]] grounds this: lowering the P% constraint (e.g., `p < 0.01`) significantly increases output diversity, because the constraint steers the model toward lower-probability positions in its distribution even though the model cannot directly observe those positions.

The practical limitation — noted in the run-001 tail synthesis — is that this makes P≈ figures **rhetorical estimates, not epistemic readings**. The model is good at producing plausible-sounding confidence language. The P≈ values are useful as a relative ordering mechanism (rank 9 should be lower P than rank 1) and as a steering signal (the constraint works) but should not be treated as calibrated probabilities.

The **modal P≈** tells you how compressed the distribution is for a given question:
- P≈90%: near-total modal dominance, limited framing space
- P≈72%: moderate compression — strong default, but substantive departures exist (observed in both inaugural runs)
- P≈40%: genuine spread, less pressure needed to reach tail

---

## ParseWarning Conditions

The script sets `ParseWarning` on four failure modes observed in practice:

| Warning | Condition | Implication |
|---|---|---|
| `MissingModal` | Modal block not parsed | Call 1 format non-compliance |
| `MissingRanks` | Fewer than 9 departure ranks parsed | Question may have limited framing space; or model truncated |
| `ModalCollapse` | Rank-9 Jaccard vs modal > 0.55 | Rank-9 is a rephrase, not a tail departure |
| `Call2Reversion` | Synthesis Jaccard vs modal > 0.60 | Call 2 failed to escape the modal |

### MissingRanks in Practice

The inaugural run-002 ("What is the best way to structure a multi-agent handoff?") produced `MissingRanks` — 7/9 ranks parsed, with R08–R09 absent. This is informative rather than catastrophic:

- The question is a practical engineering question with a well-defined answer space. The model may have genuinely exhausted substantive departures at R7.
- Epistemically self-referential questions (run-001: "What is genuinely underrated about how language models fail?") produced clean 9/9 parsing — more framing pressure means more latent space.
- A single-rank tail (R07 only) still produced a strong synthesis. The Call 2 prompt does not require multiple tail items to reframe effectively.

**Rule of thumb:** `MissingRanks` is a signal about the question's framing space, not a script failure. Questions with a strong cultural consensus answer and limited reframings will compress the distribution faster.

---

## Empirical Results (Inaugural Runs)

| Run | Question type | ParseWarning | Tail items | Synthesis quality |
|---|---|---|---|---|
| 001 | Epistemically self-referential | None | 3 (R7–R9) | High — convergent three-layer thesis |
| 002 | Practical engineering | MissingRanks (7/9) | 1 (R7 only) | High — complete economic reframing |

Both runs produced modal `P≈72%` — consistent across question types. This may reflect a characteristic of the model's alignment pressure rather than the question.

The key cross-run finding: **synthesis quality did not degrade with a single-rank tail**. The Call 2 prompt's contrast frame (modal vs. tail) is sufficient to produce a non-modal claim even when the tail is narrow.

---

## Relationship to the Paper

[[lit-verbalized-sampling-paper]] documents the paper's P% constraint mechanism:
> *Prompting the model to "sample from the tail distribution, where each response/word should be < p%."*

MAD (Approach B) implements a structurally related but distinct mechanism. Rather than a single P% floor constraint, it uses:
1. An explicit modal anchor as the reference distribution
2. Rank-ordered departures as a proxy for P% distance from the mode
3. A synthesis pass that treats the tail as a contrast context

The paper reports 1.6–2.1× diversity gains for creative writing. MAD's value is different — not diversity of surface output, but **extraction of latent framing alternatives** that alignment pressure suppresses. The goal is a synthesis that names what the modal actively avoids naming.

---

## When to Use Each Approach

| Goal | Recommended approach |
|---|---|
| Explore alternative framings of a question | MAD (Approach B) |
| Generate diverse creative outputs at scale | Paper's P% constraint; Approach A |
| Maximum reproducibility and calibration | Approach C (tournament-rank, not yet built) |
| Quick tail check without synthesis | Approach A (`invoke-tail-extractor.ps1`) |

---

## See Also
- [[verbalized-sampling]] — parent concept and typicality bias framing
- [[verbalized-sampling-ps-scripts]] — Approach A/B/C comparison and script design
- [[verbalized-sampling-experiment]] — audio processing workflow and audio series findings
- [[lit-verbalized-sampling-paper]] — paper summary (2510.01171v3)
- [[experiments-moc]] — experiment index
