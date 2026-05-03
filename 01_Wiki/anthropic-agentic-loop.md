---
title: Anthropic Agentic Loop
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases:
  - tool-use-loop
  - agentic-loop-pattern
  - client-tool-loop
source: "[[lit-anthropic-tool-use-depth]]"
---

# Anthropic Agentic Loop

The **agentic loop** is the execution pattern that powers multi-step tool use in Claude. Its shape — and who drives it — depends on where tools run.

## The Tool-Use Contract

Tool use is a contract between application and model. You specify schemas; Claude decides when and how to call them. Claude never executes code directly — it emits a structured request, and either your application or Anthropic's servers runs the operation and feeds the result back.

## Tool Execution Categories

Every Anthropic tool falls into one of three execution buckets:

| Category | Who runs the code | Response indicator | Your responsibility |
|---|---|---|---|
| **User-defined client tools** | Your application | `tool_use` block, `stop_reason: "tool_use"` | Define schema, execute, return `tool_result` |
| **Anthropic-schema client tools** | Your application | `tool_use` block | Execute using Anthropic's published schema (`bash`, `text_editor`, `computer`, `memory`) |
| **Server-executed tools** | Anthropic infrastructure | `server_tool_use` block | Enable in request; read final answer |

Anthropic-schema tools (`bash`, `text_editor`, etc.) use trained-in schemas. Claude calls them more reliably than equivalent custom tools because the schema is part of its training distribution.

## The Client-Side Loop

Client-executed tools (both user-defined and Anthropic-schema) require the application to drive a `while` loop:

1. Send request with `tools` array and user message.
2. Claude responds with `stop_reason: "tool_use"` and one or more `tool_use` blocks.
3. Execute each tool. Wrap outputs in `tool_result` blocks.
4. Send a new request: original messages + assistant response + `tool_result` user message.
5. Repeat while `stop_reason == "tool_use"`.

The loop exits when `stop_reason` is `"end_turn"`, `"max_tokens"`, `"stop_sequence"`, or `"refusal"`. Each is a distinct signal:

- `end_turn` — Claude has a complete final answer.
- `max_tokens` — Hit the output ceiling; increase `max_tokens` or restructure.
- `stop_sequence` — A configured stop sequence was emitted.
- `refusal` — Claude declined to continue; inspect the response and handle upstream.

## The Server-Side Loop

Server-executed tools (`web_search`, `web_fetch`, `code_execution`, `tool_search`) run inside Anthropic's infrastructure. A single API request may trigger several tool invocations before a response arrives. Your application does not participate in that inner loop.

If the model is still iterating when it hits the server-side iteration cap, the response arrives with `stop_reason: "pause_turn"`. Resume by re-sending the full conversation (including the paused response) — this lets Claude continue from exactly where it stopped.

The client-side loop and server-side loop are independent. A single conversation turn can involve both: server tools run internally, client tools require a round-trip.

## When Tools Are the Right Choice

Tools fit when the task requires something the model cannot do from text alone:
- Side-effecting actions (write a file, send a request, update a record)
- Fresh or external data not in training (current prices, database records)
- Guaranteed-shape structured output enforced by a schema
- Calls into existing application systems

**Tell that you need tools:** if you're writing regex to extract a decision from model output, that decision should have been a tool call. Parsing free-form text to recover structured intent is a sign the structure belongs in the schema.

Tools do not fit for:
- One-shot Q&A answerable from training — no round-trip needed
- Cases where tool-call latency exceeds the benefit of the operation

## Thinking Integration

When adaptive thinking is active, Claude reasons between tool calls (interleaved thinking) rather than only before the first one. This is automatic on Opus 4.7 and Mythos Preview, and on Opus 4.6/Sonnet 4.6 with adaptive mode. The thinking blocks produced between tool calls must be preserved and passed back in subsequent requests.

## See also

- [[anthropic-server-tools]]
- [[anthropic-tool-use]]
- [[anthropic-adaptive-thinking]]
- [[anthropic-mcp-connector]]
- [[lit-anthropic-tool-use-depth]]
