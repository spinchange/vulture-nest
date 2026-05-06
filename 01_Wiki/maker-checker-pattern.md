---
title: Maker-Checker Pattern
author: claude-sonnet-4-6
date: 2026-05-06
status: active
type: permanent
aliases: [mak-chk, maker-checker, debate-pattern, llm-debate, hallucination-mitigation]
---
# Maker-Checker Pattern

The **Maker-Checker Pattern** (MAK-CHK) is a multi-agent coordination pattern in which one agent generates a candidate output (the *Maker*) and a second, independent agent critiques or verifies it (the *Checker*) before the result is accepted. The pattern's purpose is hallucination mitigation: errors that survive one agent's generation often fail under adversarial scrutiny from a second.

Also called the **Debate Pattern** when the checker is instructed to actively argue against the maker's output rather than simply verify it.

---

## Why It Works

LLMs are vulnerable to *mode collapse* in self-correction: when asked "are you sure?", a model tends to defend its prior answer rather than genuinely reconsider it. The maker-checker pattern breaks this by separating generation and critique into distinct agents operating without shared context from the first pass. The checker has no commitment to the maker's output and is incentivized (by prompt design) to find flaws.

This is distinct from simple retry logic, which reruns the same model on the same prompt and is unlikely to catch systematic errors.

---

## Topology Variants

### Sequential (Basic MAK-CHK)

```
Input → [Maker Agent] → Draft → [Checker Agent] → Accept / Reject / Revise
```

- Checker receives the draft and the original input
- Checker emits one of: `ACCEPT`, `REJECT`, or `REVISE` with specific corrections
- On `REVISE`, the maker incorporates the checker's feedback and generates a new draft (up to N rounds)
- On `REJECT`, the task escalates to a human or a senior arbitrator agent

### Debate (Adversarial)

```
Input → [Maker] → Claim → [Challenger] → Rebuttal → [Judge] → Verdict
```

- The challenger is explicitly tasked to refute the maker's claim
- A third judge agent reads both the claim and rebuttal, then rules
- Better for high-stakes factual claims where passive verification is insufficient

### Panel (Multi-Checker)

```
Input → [Maker] → Draft → [Checker A]
                        → [Checker B]  → Aggregator → Consensus / Escalate
                        → [Checker C]
```

- Multiple checkers run in parallel, each with a different persona or instruction focus (factual accuracy, safety, style)
- Aggregator applies majority vote or confidence-weighted merge
- Catches different categories of error simultaneously

---

## Failure Modes

| Failure | Description | Mitigation |
|---|---|---|
| **Checker hallucination** | Checker invents a flaw that doesn't exist | Panel variant reduces false-positive rate |
| **Sycophantic checker** | Checker approves everything | Inject adversarial checker persona; require a mandatory critique |
| **Infinite revision loop** | Maker and checker disagree forever | Cap revision rounds; escalate to human on N-th rejection |
| **Shared model bias** | Same base model for both agents; systematic errors shared | Use different model families or temperatures for maker vs checker |

---

## Relationship to Other Patterns

| Pattern | Relationship |
|---|---|
| [[verbalized-sampling]] | Diversity-aware sampling reduces mode collapse in the maker's generation step |
| [[agent-diversity-scaling]] | Sampler-Worker model is a structural analogue; diversity at generation, not verification |
| [[pattern-human-in-the-loop]] | Human becomes the checker for high-stakes or repeated-failure cases |
| [[pattern-parallel-fan-out]] | Panel variant uses fan-out to run checkers concurrently |

---

## Implementation Sketch (ADK / A2A)

Using [[a2a-protocol|A2A Tasks]] for the maker-checker handoff:

1. Orchestrator calls Maker Agent (`SendMessage`) → Task `COMPLETED`, artifact = draft
2. Orchestrator calls Checker Agent (`SendMessage`) with draft + original input
3. Checker returns structured verdict artifact: `{ "verdict": "REVISE", "issues": [...] }`
4. Orchestrator branches on verdict: loop (REVISE), commit (ACCEPT), escalate (REJECT)

The checker's prompt must include: "You are required to identify at least one issue. If the draft is perfect, say so explicitly and explain why — do not simply approve without reasoning."

---

## References

- [[multi-agent-patterns-moc]]
- [[verbalized-sampling]]
- [[agent-diversity-scaling]]
- [[pattern-human-in-the-loop]]
- [[llm-as-a-judge]]
- [[a2a-protocol]]
