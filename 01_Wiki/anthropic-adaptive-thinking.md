---
title: Anthropic Adaptive Thinking
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-extended-thinking
  - anthropic-thinking-modes
  - adaptive-thinking
source: "[[lit-anthropic-thinking-capabilities]]"
---

# Anthropic Adaptive Thinking

**Adaptive thinking** is Anthropic's recommended reasoning mode for Claude 4 models — a shift from manually budgeting thinking tokens to letting Claude dynamically allocate reasoning based on request complexity. It replaces `thinking.type: "enabled"` + `budget_tokens` with `thinking.type: "adaptive"` + the `effort` parameter.

## The Mode Landscape

| Mode | Config | Model support | When to use |
|---|---|---|---|
| **Adaptive** | `thinking: {type: "adaptive"}` | Mythos Preview (default), Opus 4.7 (only), Opus 4.6, Sonnet 4.6 | Default choice for Claude 4 models |
| **Manual** | `thinking: {type: "enabled", budget_tokens: N}` | All models except Opus 4.7 (rejected). Deprecated on Opus 4.6, Sonnet 4.6 | Precise cost/latency control on older models |
| **Disabled** | Omit `thinking` or `{type: "disabled"}` | All except Claude Mythos Preview | Lowest latency, no reasoning trace |

Manual mode on Claude Opus 4.7 returns a `400` error — it has been removed, not deprecated. On Opus 4.6 and Sonnet 4.6, manual mode still works but is deprecated and will be removed in a future release.

## The Effort Parameter

`effort` is the replacement for `budget_tokens` as a thinking-depth control. It passes as `output_config: {effort: "<level>"}` alongside `thinking: {type: "adaptive"}`.

| Level | Thinking behavior | Availability |
|---|---|---|
| `max` | Always thinks, no depth constraint | Mythos Preview, Opus 4.7, Opus 4.6, Sonnet 4.6 |
| `xhigh` | Extended, for long-horizon work | Opus 4.7 only |
| `high` | Always thinks deeply (API default) | All supported models |
| `medium` | Moderate thinking; may skip simple queries | All supported models |
| `low` | Minimizes thinking; fastest, lowest cost | All supported models |

`effort` affects all token spend — text, tool calls, and thinking — not just thinking depth. At `low`, Claude also makes fewer tool calls and proceeds more directly to action.

**Opus 4.7 guidance:** Start at `xhigh` for coding and agentic work. Use `high` as the minimum for intelligence-sensitive tasks. Step to `medium` for cost-sensitive workflows. Reserve `max` for genuinely frontier problems.

**Sonnet 4.6 guidance:** Default to `medium` for most applications; use `high` only when maximum intelligence is required from Sonnet; use `low` for high-volume or latency-sensitive workloads.

## Interleaved Thinking

In adaptive mode, interleaved thinking is automatically enabled — Claude reasons between tool calls, not just before the first one. This is the key capability advantage over manual mode for agentic workflows:

- On Opus 4.7 and Mythos Preview, inter-tool reasoning always moves into thinking blocks.
- On Opus 4.6 and Sonnet 4.6, this is automatic with adaptive mode (the deprecated `interleaved-thinking-2025-05-14` beta header is no longer needed or supported on Opus 4.6).

## Thinking Display Modes

The `display` field controls what appears in API responses — it does not affect cost.

- **`"summarized"` (default on Opus 4.6, Sonnet 4.6):** Thinking blocks contain a summary of Claude's reasoning. You're charged for full thinking tokens; only the summary is visible.
- **`"omitted"` (default on Opus 4.7, Mythos Preview):** Thinking blocks have an empty `thinking` field. Reduces time-to-first-text-token when streaming because thinking tokens are not streamed. Same cost as summarized.

The `signature` field is always present and identical regardless of `display`. It carries encrypted full thinking content for multi-turn continuity.

## Thinking Encryption and Round-Tripping

Every thinking block carries an opaque `signature` field. The API uses it to verify that thinking blocks are authentic when they are passed back in multi-turn conversations. Rules:

- Thinking blocks must be passed back unchanged when using tools with thinking (reasoning continuity).
- Passing thinking blocks back in non-tool turns is optional on Opus 4.6+ and Sonnet 4.6+, which preserve them by default.
- Never modify the `thinking` field or the `signature` — any modification invalidates the block.
- Signatures are cross-platform (Claude API, Bedrock, Vertex AI).

## Prompt Caching Interaction

- **Within a mode:** Consecutive adaptive-mode requests preserve cache breakpoints.
- **Across modes:** Switching between `adaptive`, `enabled`, and `disabled` breaks message cache breakpoints.
- **System prompts and tool definitions** remain cached regardless of mode changes.
- For sessions involving extended thinking (which can run > 5 minutes), use the 1-hour cache TTL — see [[anthropic-prompt-caching]].

## Cost Model

You are charged for the **full thinking tokens generated**, not the summary tokens visible in the response. At `display: "omitted"`, billed token count will not match visible token count. Use `max_tokens` as a hard ceiling on total output (thinking + text). At `high` or `max` effort, monitor for `stop_reason: "max_tokens"` and increase budget accordingly.

## Tuning Thinking Behavior via Prompt

Adaptive thinking's triggering behavior is promptable. If Claude thinks more often than needed:

```
Extended thinking adds latency and should only be used when it
will meaningfully improve answer quality. When in doubt, respond directly.
```

Measure actual impact on your workload before deploying prompt-based tuning. Consider testing lower effort levels first.

## See also

- [[anthropic-messages-api]]
- [[anthropic-prompt-caching]]
- [[anthropic-streaming-patterns]]
- [[anthropic-tool-use]]
- [[lit-anthropic-thinking-capabilities]]
