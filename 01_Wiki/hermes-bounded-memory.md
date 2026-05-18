---
title: Hermes Bounded Memory
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-persistent-memory
  - memory-md-user-md
type: permanent
---
# Hermes Bounded Memory

[[hermes-bounded-memory]] is Hermes Agent's built-in long-horizon recall model: a **small, curated prompt-resident memory** paired with **searchable session history**. It is designed to keep a few critical facts always in scope without turning the system prompt into an unbounded transcript.

## Structure

Hermes maintains two persistent text stores:
- **`MEMORY.md`** — environment facts, conventions, lessons learned
- **`USER.md`** — user identity, preferences, communication style

These stores are deliberately tiny. They are injected into the system prompt as a **frozen snapshot at session start**, then managed through a `memory` tool that supports add/replace/remove operations.

## The key design tradeoff

Hermes chooses **boundedness over completeness**.

That means:
- important facts are always available at low latency
- memory remains legible enough for the agent to curate deliberately
- prompt cost stays predictable
- stale or low-value facts must be pruned instead of accumulating forever

This is the opposite of the "store every observation and retrieve later" pattern used by pure vector-memory systems.

## Three-layer recall model

Hermes effectively splits recall into three layers:
1. **Hot memory** — `MEMORY.md` and `USER.md`; always in prompt
2. **Episodic archive** — full session history searchable via `session_search`
3. **Optional external providers** — semantic or graph-style memory plugins that extend, but do not replace, the built-in memory

This places Hermes between [[agent-knowledge-vault]] and [[memory-spectrum]]:
- more structured and selective than raw transcript accumulation
- less expressive than a full relational or semantic memory substrate
- optimized for practical continuity rather than exhaustive knowledge modeling

## Frozen snapshot pattern

A crucial implementation detail is that memory is **not** live-updated inside the current prompt after each write. The injected memory block is captured once at session start.

This preserves prompt caching and makes memory updates a next-session effect:
- the tool writes to disk immediately
- later sessions see the new memory automatically
- the current session continues using the original injected snapshot

So Hermes memory behaves more like **boot-time configuration for the next conversational process** than like an in-place mutable context window.

## Why session search matters

Because prompt memory is intentionally small, Hermes complements it with `session_search` over stored conversations.

The split is:
- **memory** = facts worth always carrying
- **session search** = facts worth finding on demand

That distinction prevents prompt bloat while still allowing cross-session continuity.

## Relationship to skills

Memory and skills solve different persistence problems:
- **memory** stores stable facts about the user and environment
- **skills** store reusable procedures and workflows

So if Hermes learns "Chris prefers concise answers," that belongs in memory. If Hermes learns "how to debug Telegram topic sessions on Windows," that belongs in a skill.

This makes built-in memory the agent's **semantic shortlist**, while skills are its **procedural library**.

## Design implication

Hermes shows that persistent agent memory does not have to mean a giant autonomous knowledge base. A small, aggressively curated memory can be enough if it is paired with:
- durable transcripts
- explicit retrieval tools
- procedural skills
- optional deeper memory backends

In that sense, [[hermes-bounded-memory]] is a practical compromise between the wiki layer, the sidekick layer, and the inference layer described in [[memory-spectrum]].

## See Also
- [[hermes-agent]]
- [[hermes-gateway]]
- [[agent-knowledge-vault]]
- [[agent-skills-index]]
- [[memory-spectrum]]
- [[adk-long-term-memory]]
- [[shared-memory-blackboard]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\features\memory.md`
- Source: `C:\Users\executor\AppData\Local\hermes\skills\autonomous-ai-agents\hermes-agent\SKILL.md`
