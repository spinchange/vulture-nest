---
title: Hermes Agent Loop Specification
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - spec-hermes-agent-loop
  - hermes-turn-loop
  - hermes-runtime-spec
type: spec
---
# Hermes Agent Loop Specification

This note is a **descriptive implementation spec** for Hermes Agent as documented in the local developer docs. It does not propose a new protocol. It formalizes the invariants that make Hermes's CLI, gateway, and cron surfaces feel like one runtime.

## 1. Core Runtime Claim
A Hermes run is defined by a single controlling primitive: `AIAgent.run_conversation()`.

All major surfaces feed into that primitive:
- CLI interactive turns
- gateway-delivered chat messages
- cron-triggered fresh-session jobs
- delegated child agents

Surface differences change input loading and output delivery, but the core turn engine remains shared.

## 2. Required Runtime Stages
For any Hermes turn, the runtime must support the following stages in order:
1. **Input acquisition** — obtain user text, scheduled prompt, or delegated subtask.
2. **History assembly** — load prior session messages or start with a fresh history.
3. **Prompt assembly** — build the effective system prompt from personality, memory, skills, project context, and tool instructions.
4. **Provider resolution** — map provider/model settings to a concrete API mode and credentials.
5. **Model invocation** — call the LLM in one of Hermes's supported API modes.
6. **Tool dispatch loop** — if tool calls are returned, execute them, append results, and continue.
7. **Persistence and flush** — save the session and durable memory effects before exit or compression.
8. **Surface delivery** — render or send the final response back through CLI, gateway, or cron destination.

If any stage is replaced, the replacement must preserve the remaining contract.

## 3. Internal Message Contract
Hermes normalizes execution around an OpenAI-style internal message format:

```text
system      → prompt substrate
user        → human or job input
assistant   → model output, optionally with tool_calls
tool        → tool result bound to a tool_call_id
```

### Invariants
- there is at most one active system message layer for the effective turn payload
- user and assistant messages must alternate
- consecutive `tool` messages are permitted only as the result of parallel or batched tool execution
- tool results must be reinserted in the original tool-call order before the next model invocation

These alternation constraints are not aesthetic; provider adapters depend on them to produce valid requests.

## 4. API Mode Abstraction
Hermes supports multiple provider-facing wire formats, but they must converge on one internal loop.

Documented modes:
- `chat_completions`
- `codex_responses`
- `anthropic_messages`

### Invariant
A provider adapter may transform message formats on the wire, but before and after the call the runtime must be representable in the shared internal message schema. This is what lets the same higher-level tooling operate across providers.

## 5. Tool Dispatch Semantics
When the assistant returns tool calls, Hermes enters a tool-dispatch phase rather than ending the turn.

### Single-call path
- resolve handler
- execute tool
- append tool result
- return to model

### Multi-call path
- resolve handlers
- execute non-interactive calls concurrently when allowed
- preserve original call ordering when appending results
- return to model only after the tool batch is complete

### Special-case tools
Some tools are runtime-sensitive enough to bypass the normal registry path, including:
- `todo`
- `memory`
- `session_search`
- `delegate_task`

This means Hermes distinguishes between **general tools** and **agent-state tools**.

## 6. Persistence Model
Hermes persists at least three distinct state layers:
1. **Session history** — conversation messages stored in SQLite with lineage.
2. **Bounded memory** — `MEMORY.md` and `USER.md` for durable hot facts.
3. **Profile-scoped configuration/state** — model config, installed skills, gateway state, and related runtime files.

### Invariant
A successful turn must be resumable from persisted session state, even if the next turn happens on a different surface.

## 7. Memory Snapshot Rule
Bounded memory is injected as a session-start snapshot rather than a live mutable block.

### Consequence
- memory writes take effect on disk immediately
- the current session continues using the already-injected snapshot
- later sessions inherit the updated memory automatically

This rule exists to preserve prompt caching and stable turn semantics.

## 8. Compression Rule
Compression is an adaptation layer, not a new execution mode.

### Required behavior
- flush durable memory before compressing
- summarize middle turns rather than destroying the whole transcript
- preserve the last protected window of messages intact
- keep tool call/result pairs logically coherent
- continue with a lineage-linked child session after compression

So compression changes the size of the working context, but not the basic execution contract.

## 9. Surface-Specific Overlays
### CLI overlay
Adds local operator controls such as slash commands, checkpoints, live progress display, and manual steering.

### Gateway overlay
Adds authorization, session-key routing, platform adapters, outbound delivery, and messaging-only commands.

### Cron overlay
Starts from fresh history by default, may attach skills or scripts, and delivers the result to a target rather than an already-open local UI.

### Invariant
These overlays may extend control and delivery semantics, but they should not fork the underlying turn loop into incompatible runtimes.

## 10. Multi-Agent Boundary Types
Hermes exposes at least three distinct multi-agent boundaries:
- [[hermes-subagent-delegation]] — synchronous in-turn child runs
- [[hermes-cron]] — cross-time reruns in fresh sessions
- [[hermes-kanban]] — durable task coordination across named profiles

This is an important design distinction: not every additional agent process is the same kind of autonomy boundary.

## 11. Why This Matters
The Hermes runtime is best understood as a **persistent context-and-tools shell around swappable models**. The agent loop spec matters because it explains what stays constant while providers, interfaces, and tools change.

## See Also
- [[hermes-agent]]
- [[hermes-moc]]
- [[lit-hermes-architecture]]
- [[hermes-bounded-memory]]
- [[hermes-gateway]]
- [[hermes-cron]]
- [[hermes-subagent-delegation]]
- [[hermes-kanban]]
- [[anthropic-agentic-loop]]
- [[agent-thought-cycle]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\developer-guide\agent-loop.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\developer-guide\architecture.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\reference\tools-reference.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\reference\slash-commands.md`
