---
title: Anthropic Server Tools
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases:
  - server-executed-tools
  - anthropic-web-search-tool
  - server_tool_use
source: "[[lit-anthropic-tool-use-depth]]"
---

# Anthropic Server Tools

**Server tools** are tools where Anthropic's infrastructure executes the code. You enable the tool in your request; the server runs it and feeds results back to the model before the response reaches you. You never construct a `tool_result` block for these tools.

The current server tools are `web_search`, `web_fetch`, `code_execution`, and `tool_search`.

## The server_tool_use Block

When a server tool runs, Claude's response contains a `server_tool_use` block with an `id` prefixed `srvtoolu_`:

```json
{
  "type": "server_tool_use",
  "id": "srvtoolu_01A2B3C4D5E6F7G8H9",
  "name": "web_search",
  "input": { "query": "latest quantum computing breakthroughs" }
}
```

The result block follows immediately in the same assistant turn. Unlike client `tool_use` blocks, no further action from your application is required — execution is already complete by the time you see the response.

## The pause_turn Continuation Pattern

Server tools run their own inner loop on Anthropic's infrastructure. If Claude is still iterating when the server-side iteration cap is hit, the response arrives with `stop_reason: "pause_turn"` rather than `"end_turn"`.

Resume by re-sending the full conversation including the paused response:

```python
if response.stop_reason == "pause_turn":
    messages = [
        {"role": "user", "content": original_content},
        {"role": "assistant", "content": response.content},
    ]
    continuation = client.messages.create(
        model="claude-opus-4-7",
        max_tokens=1024,
        messages=messages,
        tools=[{"type": "web_search_20260209", "name": "web_search"}],
    )
```

Include the same tools in the continuation to maintain functionality. You may modify the content before re-sending if you need to redirect or interrupt the agent.

## ZDR Eligibility

The basic versions of web search (`web_search_20250305`) and web fetch (`web_fetch_20250910`) are eligible for Zero Data Retention (ZDR).

The `_20260209` versioned tools with dynamic filtering are **not** ZDR-eligible by default because dynamic filtering relies on internal code execution. To use a `_20260209` tool with ZDR, disable dynamic filtering:

```json
{
  "type": "web_search_20260209",
  "name": "web_search",
  "allowed_callers": ["direct"]
}
```

`"allowed_callers": ["direct"]` restricts the tool to direct invocation only, bypassing the internal code execution step.

## Domain Filtering

Server tools that access the web accept `allowed_domains` and `blocked_domains` to control which domains Claude can reach. Use one or the other — never both in the same request.

Domain filter rules:
- No HTTP/HTTPS scheme in entries (`example.com` not `https://example.com`)
- Subdomains are automatically included (`example.com` covers `docs.example.com`)
- Specific subdomains restrict to only that subdomain
- Subpaths are supported and match everything below the path
- One wildcard per entry, after the domain part only (`example.com/*`, `example.com/*/articles`)
- Invalid: `*.example.com`, `ex*.com`, `example.com/*/news/*`

Organization-level domain restrictions in the Console override request-level settings. Request-level domains can only further restrict, not expand, beyond the organization list. Mismatches return a validation error.

Unicode homograph attacks are a real risk: `аmazon.com` (Cyrillic ‹а›) looks identical to `amazon.com`. Use ASCII-only domain entries where possible.

## Dynamic Filtering (_20260209 Versions)

The `_20260209` tool versions use code execution internally to apply dynamic filters against results. Running a standalone `code_execution` tool alongside `_20260209` web tools creates two separate execution environments, which confuses the model. Use one or the other, or pin both to the same version.

## Streaming

Server-tool events stream as part of the normal SSE flow. The `server_tool_use` block and its result arrive as `content_block_start` / `content_block_delta` events, the same way text and client tool calls stream. All server tools support batch processing.

## See also

- [[anthropic-agentic-loop]]
- [[anthropic-tool-use]]
- [[anthropic-mcp-connector]]
- [[lit-anthropic-tool-use-depth]]
