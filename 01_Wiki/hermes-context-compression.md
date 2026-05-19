---
title: Hermes Context Compression
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-session-compression
  - hermes-session-lineage
  - hermes-compaction-boundary
type: permanent
---
# Hermes Context Compression

[[hermes-context-compression]] describes how Hermes shrinks an overgrown conversation without pretending the session simply continued unchanged. Compression is both a **summarization step** and a **session-boundary operation**.

## Core idea

When Hermes approaches its context limit, it does not merely replace old messages with a summary in memory. `compress_context()` performs a coordinated rollover that touches:
- the message list
- the system prompt
- the SQLite session database
- memory extraction hooks
- context-engine lineage hooks
- token estimates
- file-read dedup state

This makes compression a first-class lifecycle transition.

## What compression preserves

The compression path tries to preserve several kinds of continuity:
- a summary of earlier turns
- the live todo snapshot, re-injected as a user message
- the session title, with automatic lineage numbering
- a parent/child session relationship in the session database
- memory-provider continuity through `on_session_switch(reset=False)`
- context-engine continuity through `boundary_reason="compression"`

So Hermes treats compaction as **continuation with explicit lineage**, not a silent reset.

## Session rotation is deliberate

A key implementation detail is that Hermes generates a new `session_id` after compression and creates a new DB session row with the old session as `parent_session_id`.

That means the compressed continuation is modeled as:
- same logical conversation
- new physical session segment
- explicit ancestry link

This is architecturally important because it keeps transcript storage, search, and future replay aligned with what actually happened.

## Compression is coupled to memory extraction

Before the session rotates, Hermes triggers memory extraction on the old session and notifies any external memory manager with `on_pre_compress(messages)`.

This reveals a broader Hermes pattern:
- prompt-resident context is bounded
- durable recall is delegated to persistence layers
- compression is the moment where short-term context is intentionally distilled into longer-lived artifacts

So [[hermes-context-compression]] sits directly between [[hermes-bounded-memory]] and session persistence.

## Failure is surfaced, not hidden

The implementation contains explicit warning paths for:
- summary-generation failure
- auxiliary compression model failure followed by recovery on the main model
- repeated compressions that may degrade fidelity

Hermes will still continue by inserting fallback markers or retrying on the main model, but it records that degradation so the operator can reason about trust in the result.

This is a good example of Hermes preferring **graceful degradation with visibility** over silent failure.

## Post-compression bookkeeping matters

After compaction, Hermes also:
- rebuilds the system prompt
- recomputes token estimates including tool schemas
- resets file-read dedup state so re-reading a file fetches the full content again
- updates the context compressor's latest token counts

These details show that compression is not isolated to transcript summarization. It reshapes the whole runtime state that the next turn will inherit.

## Contrast with naive chat compaction

A naive compaction design would:
- summarize old turns
- keep the same session identity
- ignore persistence hooks
- leave downstream caches untouched

Hermes instead models compaction as a bounded but durable seam in the conversation. That makes the system more suitable for:
- session search
- lineage-aware replay
- long-running gateway conversations
- external memory providers
- agent auditing

## Architectural consequence

[[hermes-context-compression]] is where Hermes turns bounded context from a token-limit hack into an explicit runtime protocol. Compression is simultaneously a summarization algorithm, a persistence boundary, and a lineage-preserving handoff from one session segment to the next.

## See Also
- [[hermes-agent]]
- [[hermes-bounded-memory]]
- [[hermes-prompt-assembly]]
- [[spec-hermes-agent-loop]]
- [[lit-hermes-architecture]]
- [[memory-spectrum]]
- [[anthropic-prompt-caching]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\agent\conversation_compression.py`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\agent\context_compressor.py`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\developer-guide\agent-loop.md`
