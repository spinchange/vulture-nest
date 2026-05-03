---
title: "Literature: Anthropic Thinking Capabilities (Batch 2, Sub-batch B)"
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: literature
aliases:
  - lit-anthropic-thinking
  - anthropic-thinking-capabilities-lit
source: "00_Raw/anthropic/ (sub-batch B: extended-thinking, adaptive-thinking, effort-parameter)"
---

# Literature: Anthropic Thinking Capabilities (Batch 2, Sub-batch B)

Synthesis of three Anthropic documentation pages covering extended thinking, adaptive thinking, and the effort parameter. Crawled 2026-05-02 to 2026-05-03 as part of Batch 2 ingestion.

---

## The Thinking Mode Landscape

Anthropic's thinking capabilities let Claude reason step-by-step before producing a final response. There are three modes:

| Mode | Config | Model support |
|---|---|---|
| **Adaptive** | `thinking: {type: "adaptive"}` | Mythos Preview (default/only), Opus 4.7 (only), Opus 4.6, Sonnet 4.6 |
| **Manual** | `thinking: {type: "enabled", budget_tokens: N}` | All models *except* Opus 4.7 (rejected with 400). Deprecated on Opus 4.6, Sonnet 4.6. |
| **Disabled** | Omit `thinking` or `{type: "disabled"}` | All models except Mythos Preview |

**Invariant (critical):** Manual thinking (`type: "enabled"`, `budget_tokens`) on Claude Opus 4.7 is not deprecated — it is removed. Sending it returns a `400` error. This is not the same as a deprecation with a grace period.

---

## Extended Thinking (Manual Mode)

When extended thinking is on, Claude produces `thinking` content blocks containing its internal reasoning, followed by `text` content blocks with the final answer. Applications see both.

`budget_tokens` sets the maximum thinking token budget. On Claude 4 models, this applies to the full thinking tokens (not the summarized output). Claude may use less than the budget. Diminishing returns above 32k tokens; use batch processing for thinking budgets that push above 32k to avoid timeout exposure.

`budget_tokens` must be less than `max_tokens`. This makes extended thinking incompatible with `max_tokens: 0` (cache pre-warming).

---

## Adaptive Thinking

Adaptive thinking removes manual budget management. Claude evaluates request complexity and determines when and how much to think. Set `thinking.type: "adaptive"`:

```python
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=16000,
    thinking={"type": "adaptive"},
    messages=[{"role": "user", "content": "..."}],
)
```

No beta header is required for adaptive thinking on any model.

Adaptive mode automatically enables **interleaved thinking** — Claude can reason between tool calls, not just before the first one. On Opus 4.7 and Mythos Preview, inter-tool reasoning always moves into thinking blocks. On Opus 4.6 and Sonnet 4.6 with adaptive mode, interleaved thinking is also automatic.

---

## The Effort Parameter

`effort` is the replacement for `budget_tokens` as a thinking-depth control. It passes as `output_config: {effort: "<level>"}` alongside adaptive thinking. The effort level is soft guidance — it affects all token spend (text, tool calls, and thinking), not just thinking depth.

| Level | Behavior | Availability |
|---|---|---|
| `max` | Always thinks, no depth constraint | Mythos Preview, Opus 4.7, Opus 4.6, Sonnet 4.6 |
| `xhigh` | Extended, long-horizon work | Opus 4.7 only |
| `high` | Always thinks deeply (API default) | All supported models |
| `medium` | Moderate thinking; may skip simple queries | All supported models |
| `low` | Minimizes thinking; fastest | All supported models |

At `low` effort, Claude also makes fewer tool calls and proceeds more directly to action.

**Guidance by model:**
- Opus 4.7: Start at `xhigh` for coding/agentic; `high` minimum for intelligence-sensitive tasks; `max` for frontier problems.
- Sonnet 4.6: `medium` for most; `high` when maximum intelligence required; `low` for high-volume/latency-sensitive.

---

## Summarized vs. Omitted Thinking Display

The `display` field controls what appears in API responses — it does not affect cost.

- **`"summarized"` (default on Opus 4.6, Sonnet 4.6):** Thinking blocks contain a summary of Claude's reasoning. Billed for full thinking tokens; only summary visible.
- **`"omitted"` (default on Opus 4.7, Mythos Preview):** Thinking blocks have an empty `thinking` field. Reduces time-to-first-text-token during streaming because thinking tokens are not streamed. Same cost as summarized.

The `signature` field is always present and identical regardless of `display`. It carries encrypted full thinking content for multi-turn continuity.

**Warning:** On Opus 4.7, `display` silently changed default from `"summarized"` (Opus 4.6 behavior) to `"omitted"`. Code that processed thinking blocks from Opus 4.6 may need `display: "summarized"` set explicitly when migrating to Opus 4.7.

---

## Thinking Encryption and Round-Tripping

Full thinking content is encrypted and stored in the opaque `signature` field. Rules:

- Must pass thinking blocks back unchanged when using tools with thinking (tool-use continuity).
- On Opus 4.5+ and Sonnet 4.6+, thinking blocks from previous turns are preserved by default. On earlier Opus/Sonnet and all Haiku, only the last turn's thinking is preserved by default.
- `redacted_thinking` blocks are a distinct type returned when portions of thinking are safety-redacted. They must also be passed back unchanged in multi-turn tool-use conversations. Filter code using `block.type == "thinking"` alone will silently drop `redacted_thinking` blocks — include `"redacted_thinking"` in the filter.
- `signature` values are cross-platform (Claude API, Bedrock, Vertex AI).

---

## Interleaved Thinking Model Support

| Model | Interleaved thinking |
|---|---|
| Mythos Preview | Automatic (no header needed) |
| Opus 4.7 (adaptive only) | Automatic (no header needed) |
| Opus 4.6 (adaptive) | Automatic (no header needed); `interleaved-thinking-2025-05-14` deprecated, safely ignored |
| Sonnet 4.6 (adaptive) | Automatic |
| Sonnet 4.6 (manual) | Via `interleaved-thinking-2025-05-14` beta header (deprecated) |
| Opus 4.5, Sonnet 4.5, Opus 4.1 | Via `interleaved-thinking-2025-05-14` beta header |

---

## Thinking Block Preservation by Model

| Model class | Default thinking block preservation |
|---|---|
| Opus 4.5+, Sonnet 4.6+, Mythos Preview | All prior thinking blocks kept |
| Earlier Opus/Sonnet | Last turn only |
| All Haiku through Haiku 4.5 | Last turn only |

Override with the `clear_thinking_20251015` context-editing strategy.

---

## Prompt Caching Interactions

- Consecutive requests using the same thinking mode (`adaptive` or `enabled`) preserve cache breakpoints.
- Switching between `adaptive`, `enabled`, and `disabled` breaks message cache breakpoints.
- System prompts and tool definitions remain cached regardless of thinking mode changes.
- Extended thinking tasks may run > 5 minutes; use the 1-hour cache TTL (`extended-cache-ttl-2025-04-11`).
- Thinking block preservation on Opus 4.5+ and Sonnet 4.6+ enables cache hits when thinking blocks are passed back with tool results.

---

## Cost Model

You are charged for the **full thinking tokens generated**, not the summarized tokens visible in the response. The billed output token count will not match the visible token count when `display: "omitted"` or `"summarized"`. Use `max_tokens` as a hard ceiling on total output (thinking + text). At `high` or `max` effort, monitor for `stop_reason: "max_tokens"`.

---

## Context Window Behavior

With extended thinking, `max_tokens` is enforced as a strict limit. Claude 3.7+ and Claude 4 models return a validation error if `prompt_tokens + max_tokens` exceeds the context window. (Earlier models silently adjusted `max_tokens`.)

---

## Stable Patterns vs. Operational Details

**Stable (architecture):**
- Three-mode landscape (adaptive, manual, disabled) with hard model constraints
- Adaptive thinking is the trajectory; manual is deprecated on current flagship models
- `signature` field as opaque round-trip token for thinking continuity
- Interleaved thinking as the key capability advantage for agentic workflows
- `display` field as latency/visibility control, not cost control

**Operational (likely to drift):**
- Per-model default for `display` (watch for future model changes)
- Specific effort level availability by model
- `redacted_thinking` occurrence patterns
- `interleaved-thinking-2025-05-14` beta header deprecation timeline

---

## Notes for Synthesis

This sub-batch is the primary source for [[anthropic-adaptive-thinking]]. The existing permanent note from the advanced-capabilities batch (2026-05-02) is high quality and covers this material well. The batch-2 crawl provides more granular provenance (page IDs) but no significant new content over what was already synthesized.
