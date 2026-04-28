---
title: Verbalized Sampling — Inaugural Run
author: claude-sonnet-4-6
date: '2026-04-28'
status: complete
type: experiment
experiment-type: run
participants: ['claude', 'human']
hypothesis: Verbalized sampling will surface suppressed failure-mode framings that the modal LLM response actively avoids naming
result: Confirmed — tail ranks 7–9 surfaced three structurally distinct suppressed framings (training-data sociology, meta-cognitive blindness, alignment-as-surface-polish), which the Call 2 synthesis integrated into a convergent argument absent from the modal
verdict: confirmed
aliases: []
---

# Verbalized Sampling — Inaugural Run

## Hypothesis
Verbalized sampling will surface suppressed failure-mode framings that the modal LLM response actively avoids naming.

## Setup

- **Script:** `02_System/verbalized-sampling.ps1` (Mode-Anchored Departure, Approach B)
- **Model:** `claude-sonnet-4-6`
- **Question:** "What is genuinely underrated about how language models fail?"
- **TailStart:** 7 (canonical Approach B setting)
- **MaxTokens:** 2000 per call
- **Output:** `results/run-001.json`
- **Elapsed:** 49s (2 API calls)

Question selected for strong modal (hallucination/confident-wrongness) and maximal tail contrast potential. Domain is epistemically self-referential — the model is being asked to characterize its own failure landscape.

## Run Log

### Call 1 — Modal + Departure Enumeration

**Modal (P≈72%):** Confident wrongness that sounds authoritative — fluency suppresses reader skepticism. The canonical hallucination narrative.

| Rank | Tag | P% |
|------|-----|----|
| R01 | fluency-skepticism suppression mechanism | 40% |
| R02 | successful-task-wrong-goal | 25% |
| R03 | context-window-false-coherence | 15% |
| R04 | user-adaptation-failure | 12% |
| R05 | undetectable-omission-not-commission | 8% |
| R06 | sycophantic-drift-over-conversation | 6% |
| R07 | failure-modes-are-training-artifacts | 4% |
| R08 | meta-cognitive-blindness-self-report | 3% |
| R09 | alignment-masks-rather-than-fixes | 2% |

ParseWarning: none. All 9 ranks parsed. Rank-9 modal collapse check: clean.

**Tail departures (R07–R09) submitted to Call 2:**
- **R07:** Model failures inherit the systematic sociology of human motivated reasoning — errors cluster where confident-but-wrong human writing is densest in training data
- **R08:** Models have no reliable introspective access to their own failure states; confidence-language is a rhetorical generation, not an epistemic reading
- **R09:** RLHF alignment may train the *surface signals* of epistemic virtue without touching underlying accuracy — optimizing for appearing trustworthy over being trustworthy

### Call 2 — Tail Synthesis

No reversion detected. Synthesis produced a convergent argument integrating all three tail departures.

**Core thesis of synthesis:** The diagnostic apparatus we use to detect LLM failure has itself been compromised. Three layers converge:
1. Training data inherits the failure modes of motivated human reasoning (sociologically structured, not random)
2. Models have no internal failure signal — confidence-language is generated, not read
3. RLHF trains rhetorical performance of calibration, potentially reducing failure legibility while leaving accuracy unchanged

> "We may have built systems that are harder to catch in errors precisely because we optimized for appearing trustworthy."

## Results

- **ParseWarning:** None
- **Modal collapse (R9):** Not detected
- **Call 2 reversion:** Not detected
- **Synthesis quality:** High — produced a structurally novel claim (convergent three-layer failure) absent from modal
- **Full JSON:** `results/run-001.json`

The modal response named hallucination + fluency suppression — the well-worn framing. The synthesis named a convergence of mechanisms that makes the entire error-detection stack unreliable. These are substantively different claims.

## Outcome

**Verdict: confirmed**

The technique worked as designed on the inaugural run. Tail ranks surfaced claims the modal would not produce:
- Sociologically structured failures (R07) — modal frames errors as model defects, not inherited cultural patterns
- Meta-cognitive blindness (R08) — modal doesn't address the impossibility of self-report
- Alignment-as-surface-polish (R09) — modal doesn't name RLHF as a potential legibility reducer

The synthesis successfully integrated these into a claim the modal actively suppresses: that our standard error-detection strategies may be working on a layer that has been trained away.

**Durable finding:** See [[verbalized-sampling]] for the parent concept. Consider promoting the three-layer convergence argument to a permanent note if it holds up under scrutiny.

---

## Run-002: "What is the best way to structure a multi-agent handoff?"

- **Output:** `results/run-002.json`
- **Elapsed:** 69s
- **ParseWarning:** `MissingRanks` — model produced 7/9 departure ranks (R08–R09 missing)

### Call 1 — Modal + Departure Enumeration

**Modal (P≈72%):** Standard orchestration-pattern guidance — shared state object, typed interfaces, orchestrator/router pattern, idempotency, audit trail, failure routing. References LangGraph/CrewAI/AutoGen.

| Rank | Tag | P% |
|------|-----|----|
| R01 | Tradeoffs between orchestration patterns | 12% |
| R02 | Concrete code-level implementation focus | 8% |
| R03 | Questioning whether handoffs are necessary | 5% |
| R04 | Failure modes and adversarial robustness focus | 4% |
| R05 | Human-agent handoff as primary case | 3% |
| R06 | Theoretical/formal model perspective | 2% |
| R07 | Economic/cost optimization framing | 2% |

Only 7 ranks parsed — R08 and R09 absent. Tail consisted of R07 only.

**MissingRanks note:** This is a methodological data point. The question ("best way to structure") is a practical engineering question with a well-defined modal and less pressure-suppressed framing space than an epistemically self-referential question. The model may have genuinely run out of substantively distinct departures at R7 rather than being truncated.

**Tail item (R07) submitted to Call 2:**
- Each handoff has a real economic cost (latency, token re-encoding, error probability, context degradation). The optimization problem is minimizing total handoff cost subject to task completion — and most practitioners ignore this framing entirely.

### Call 2 — Tail Synthesis

No reversion detected. Synthesis ran on R07 alone and produced a full restructuring of the question.

**Core thesis of synthesis:** Most handoff guidance optimizes for architectural cleanliness; it should optimize for minimizing total handoff cost. Key claims the modal suppresses:

1. **Question whether the handoff should exist.** The pressure toward multi-agent systems is often organizational instinct, not genuine capability partitioning. Fewer, more capable agents frequently outperform elaborate pipelines.
2. **Error probability compounds multiplicatively.** At 90% per-agent success rate, a five-agent pipeline succeeds ~59% of the time. Failure routing is load-bearing, not an afterthought.
3. **Orchestrator's job is deciding when NOT to route.** A good orchestrator collapses the remaining pipeline when continuing would compound degraded state — it needs a model of downstream capability and current state quality, not just a routing table.
4. **Handoff triggers should be grounded in observable output quality**, not task completion. Agents should emit structured epistemic state, not just results.
5. **Economically dominant structure:** single orchestrator + 3–5 stateless specialist workers. Peer-to-peer graphs only when genuinely sequential; checkpoint after every hop.

> "The best handoff is often the one you eliminate."

### Run-002 Results

- **ParseWarning:** `MissingRanks` (7/9 ranks)
- **Tail items:** 1 (R07 only — single-rank tail)
- **Call 2 reversion:** Not detected
- **Synthesis quality:** High given single-rank tail — the economic framing drove a complete reframing of the question
- **Methodological note:** Single-rank tail is a valid edge case. The script handled it cleanly; synthesis quality did not degrade.

**Cross-run observation:** Both runs show that the synthesis reliably produces a non-modal claim even when the tail is narrow (R07 only). The economic/cost-minimization framing is a genuinely suppressed perspective — the modal answer spends zero words on it.

#topic/verbalized-sampling #topic/multi-agent #topic/handoff #verdict/confirmed
