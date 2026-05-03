---
title: "Literature: Anthropic Tool Use — Full Depth (Batch 2, Sub-batch A)"
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: literature
aliases:
  - lit-anthropic-tool-use-depth
  - anthropic-tool-use-depth-lit
source: "00_Raw/anthropic/ (sub-batch A: tool-use-overview, tool-use-how-it-works, tool-use-define-tools, tool-use-handle-tool-calls, tool-use-tool-reference, tool-use-server-tools, tool-use-strict-mode, tool-use-parallel, tool-use-runner-sdk, tool-use-mcp-connector, tool-use-tool-search)"
---

# Literature: Anthropic Tool Use — Full Depth (Batch 2, Sub-batch A)

Synthesis of eleven Anthropic documentation pages covering tool use from overview through server tools, strict mode, parallel calls, the Tool Runner SDK, the MCP connector, and tool search. Crawled 2026-05-01 to 2026-05-02 as part of Batch 2 ingestion.

---

## Core Model: Three Execution Buckets

The fundamental distinction in Anthropic tool use is who executes the code.

**User-defined client tools:** Custom business logic, internal APIs, proprietary data. You define the schema; Claude emits a `tool_use` block with `stop_reason: "tool_use"`; your code runs the operation; you return a `tool_result` block. Your application drives the loop.

**Anthropic-schema client tools:** Standard operations with Anthropic-published schemas — `bash`, `text_editor`, `computer`, `memory`. Same execution model as user-defined tools, but the schema is trained-in. Claude calls them more reliably than equivalent custom tools.

**Server-executed tools:** `web_search`, `web_fetch`, `code_execution`, `tool_search`. Anthropic's infrastructure runs the code. Response contains `server_tool_use` blocks (prefixed `srvtoolu_`) and results. Your application reads the final answer without participating in execution. If the server-side iteration cap is hit, the response carries `stop_reason: "pause_turn"` — resend the conversation to continue.

**The contract:** Claude never executes anything on its own. It emits a structured request; the appropriate executor (application or server) runs the operation and feeds the result back into the conversation.

---

## The Client-Side Agentic Loop

For user-defined and Anthropic-schema client tools, the application drives a `while` loop:

1. Send request with `tools` array.
2. Claude responds: `stop_reason: "tool_use"`, one or more `tool_use` blocks.
3. Execute tools; wrap results in `tool_result` blocks.
4. Send new request: original messages + assistant response + user message with `tool_results`.
5. Repeat while `stop_reason == "tool_use"`.

Exit on `"end_turn"`, `"max_tokens"`, `"stop_sequence"`, or `"refusal"`. Each is a distinct operational signal.

See [[anthropic-agentic-loop]] for the canonical architectural note.

---

## Defining Tools

Tool schemas are JSON Schema objects. Each tool has `name`, `description`, and `input_schema`. The description is the highest-leverage part of a tool definition — Claude cannot read your implementation, only the schema and description.

**Description writing heuristics:**
- Describe what the tool does, when to use it, what each parameter means, and important caveats.
- Mention what the tool cannot do or when not to use it.
- Aim for 3–4 sentences minimum; more for complex tools.

**Tool choice modes:**
- `"auto"` (default) — Claude decides whether and which tools to call.
- `"any"` — Claude must call at least one tool.
- `"tool": {"name": "..."}` — Claude must call the named tool.
- `"none"` — Claude cannot call any tool (tools are still listed, but disallow invocation).

Forced tool use (`"any"` or specific `"tool"`) is incompatible with extended thinking.

**Strict mode (`strict: true`):** Add to a tool definition to ensure Claude's tool calls always conform exactly to the schema. Claude will not produce tool calls with fields outside the schema or missing required fields. Use when downstream code validates schema compliance strictly.

---

## Handling Tool Calls

When Claude calls multiple tools in one response, you can execute them in parallel before the next request. Claude expects all results for a given assistant turn to arrive in the same `tool_result` user message.

For each `tool_use` block:
- Extract `id`, `name`, and `input`
- Run the operation
- Return `{"type": "tool_result", "tool_use_id": id, "content": result}`

Tool results can include text, images, or documents. If a tool fails, return an error message in the `content` and optionally set `"is_error": true`.

---

## Tool Runner SDK

The Tool Runner SDK (Python, TypeScript, Ruby only) automates the agentic loop. Instead of writing the `while stop_reason == "tool_use"` loop manually, you define tools as decorated functions and pass them to `tool_runner`:

```python
runner = client.beta.messages.tool_runner(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[my_tool_function],
    messages=[{"role": "user", "content": "..."}],
)
for message in runner:
    print(message.content)
```

The SDK handles loop iteration, tool dispatch, result formatting, and stopping conditions. It is also the integration point for client-side compaction (see [[lit-anthropic-sdk-service-2026]]).

Tool Runner is available in Python, TypeScript, and Ruby only.

---

## MCP Connector

The MCP connector allows Claude to use tools exposed by Model Context Protocol (MCP) servers without requiring client-side execution. You pass MCP server URLs and authentication; the API connects to the server and makes tools available to Claude.

The current beta header is `mcp-client-2025-11-20`. The `2025-04-04` header is deprecated.

**Architectural note:** The MCP connector moves MCP tool execution server-side, eliminating the need for the application to act as an MCP client. This is architecturally equivalent to server-executed tools for the application's perspective — you configure the connection; the server handles execution.

See [[anthropic-mcp-connector]] for the full architectural note.

---

## Tool Search

Tool search (`tool_search`) is a server-executed tool that allows Claude to discover and load tools from a registry on demand. Instead of providing the full tool set upfront, the application registers tools in a searchable index; Claude queries the index when it needs a capability. This pattern reduces prompt size for large tool libraries and allows Claude to reason about capability availability before committing to a call.

---

## Server Tools: ZDR, Domain Filtering, Versioning

See [[anthropic-server-tools]] for the full note. Key facts:

- `web_search_20250305` and `web_fetch_20250910` are ZDR-eligible. `_20260209` versions are not by default.
- `allowed_callers: ["direct"]` on `_20260209` tools disables dynamic filtering and restores ZDR eligibility.
- Domain filtering: `allowed_domains` and `blocked_domains` (not both). Subdomain inclusion is automatic for base domains; specific subdomains restrict to that subdomain only.
- `pause_turn` continuation: re-send the full conversation including the paused response.

---

## Pricing

Tool schemas and `tool_use`/`tool_result` blocks count as input/output tokens. A system prompt is automatically injected for tool use; its cost (measured in tokens) varies by model and `tool_choice`. For Opus 4.7, Opus 4.6, and Sonnet 4.6 with `auto`/`none` choice: 346 tokens. With `any`/`tool` choice: 313 tokens. Server-side tools incur additional usage-based charges (e.g., per search for `web_search`).

---

## Stable Patterns vs. Operational Details

**Stable (architecture):**
- Three-bucket execution model (user-defined, Anthropic-schema, server-executed)
- Tool-use contract: schema → request → execute → result
- `stop_reason` as the loop control signal
- Tool Runner as the SDK-level loop abstraction
- MCP connector as server-side MCP execution

**Operational (likely to drift):**
- Specific system prompt token counts per model/choice combination
- Beta header dates for MCP connector and server tools
- Tool Search feature maturity and API shape
- ZDR eligibility by tool version (check current documentation)

---

## Notes for Synthesis

This sub-batch is the primary source for [[anthropic-agentic-loop]], [[anthropic-server-tools]], [[anthropic-mcp-connector]], and [[anthropic-tool-runner-sdk]]. The existing [[anthropic-tool-use]] note covers base tool-use mechanics. Tool Runner SDK and Tool Search are the newest additions not yet in the first-batch notes.
