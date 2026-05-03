<!--
source_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools
requested_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools
fetch_date: 2026-05-01T09:10:06.626Z
crawl_job_id: 019deac3-a814-708c-b642-2b673985c5d7
source_page_id: 4b439d67-b1e0-4c94-a6bb-93aa49662140
chunk_ids: b3499dad-9a11-498a-94c7-5f8f89bd87b0, b289abf2-4c05-48bc-8533-d681b3d69122, fa22bb95-8d96-4f32-a6d1-9bee1b391cd0, d0d2ac10-902a-44ba-9735-7f8be4ba9c10, 6a30d380-b231-4b4f-aef2-bfab31000cdf
-->

# Server tools - Claude API Docs
Tools

Server tools

Copy page

This page covers the shared mechanics of server-executed tools: the `server_tool_use` block, `pause_turn` continuation, ZDR considerations, and domain filtering. For individual tools, see the [tool reference](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-reference).

## The server\_tool\_use block

The `server_tool_use` block appears in Claude's response when a server-executed tool runs. Its `id` field uses the `srvtoolu_` prefix to distinguish it from client tool calls:

```
{
  "type": "server_tool_use",
  "id": "srvtoolu_01A2B3C4D5E6F7G8H9",
  "name": "web_search",
  "input": { "query": "latest quantum computing breakthroughs" }
}
```

The API executes the tool internally. You see the call and its result in the response, but you don't handle execution. Unlike client `tool_use` blocks, you don't need to respond with a `tool_result`. The result block appears immediately after the `server_tool_use` block in the same assistant turn.

## The server-side loop and pause\_turn

When using server tools like web search, the API may return a `pause_turn` stop reason, indicating that the API has paused a long-running turn.

Here's how to handle the `pause_turn` stop reason:

PythonTypeScriptC#GoJavaPHPRuby

```
# Initial request with web search
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[\
        {\
            "role": "user",\
            "content": "Search for comprehensive information about quantum computing breakthroughs in 2025",\
        }\
    ],
    tools=[{"type": "web_search_20250305", "name": "web_search", "max_uses": 10}],
)

# Check if the response has pause_turn stop reason
if response.stop_reason == "pause_turn":
    # Continue the conversation with the paused content
    messages = [\
        {\
            "role": "user",\
            "content": "Search for comprehensive information about quantum computing breakthroughs in 2025",\
        },\
        {"role": "assistant", "content": response.content},\
    ]

    # Send the continuation request
    continuation = client.messages.create(
        model="claude-opus-4-7",
        max_tokens=1024,
        messages=messages,
        tools=[{"type": "web_search_20250305", "name": "web_search", "max_uses": 10}],
    )

    print(continuation)
else:
    print(response)
```

When handling `pause_turn`:

- **Continue the conversation:** Pass the paused response back as-is in a subsequent request to let Claude continue its turn
- **Modify if needed:** You can optionally modify the content before continuing if you want to interrupt or redirect the conversation
- **Preserve tool state:** Include the same tools in the continuation request to maintain functionality

## ZDR and allowed\_callers

The basic versions of web search (`web_search_20250305`) and web fetch (`web_fetch_20250910`) are eligible for [Zero Data Retention (ZDR)](https://platform.claude.com/docs/en/build-with-claude/zero-data-retention).

The `_20260209` versions with dynamic filtering are **not** ZDR-eligible by default because dynamic filtering relies on code execution internally.

To use a `_20260209` server tool with ZDR, disable dynamic filtering by setting `"allowed_callers": ["direct"]` on the tool:

```
{
  "type": "web_search_20260209",
  "name": "web_search",
  "allowed_callers": ["direct"]
}
```

This restricts the tool to direct invocation only, bypassing the internal code execution step.

While the web fetch tool itself is ZDR-eligible, website publishers may retain any parameters passed to the URL if Claude fetches content from their site.

## Domain filtering

Server tools that access the web accept `allowed_domains` and `blocked_domains` parameters to control which domains Claude can reach.

When using domain filters:

- Domains should not include the HTTP/HTTPS scheme (use `example.com` instead of `https://example.com`)
- Subdomains are automatically included (`example.com` covers `docs.example.com`)
- Specific subdomains restrict results to only that subdomain (`docs.example.com` returns only results from that subdomain, not from `example.com` or `api.example.com`)
- Subpaths are supported and match anything after the path (`example.com/blog` matches `example.com/blog/post-1`)
- You can use either `allowed_domains` or `blocked_domains`, but not both in the same request

**Wildcard support:**

- Only one wildcard (`*`) is allowed per domain entry, and it must appear after the domain part (in the path)
- Valid: `example.com/*`, `example.com/*/articles`
- Invalid: `*.example.com`, `ex*.com`, `example.com/*/news/*`

Invalid domain formats return an `invalid_tool_input` tool error.

Request-level domain restrictions must be compatible with organization-level domain restrictions configured in the Console. Request-level domains can only further restrict domains, not override or expand beyond the organization-level list. If your request includes domains that conflict with organization settings, the API returns a validation error.

Be aware that Unicode characters in domain names can create security vulnerabilities through homograph attacks, where visually similar characters from different scripts can bypass domain filters. For example, `аmazon.com` (using Cyrillic 'а') may appear identical to `amazon.com` but represents a different domain.

When configuring domain allow/block lists:

- Use ASCII-only domain names when possible
- Consider that URL parsers may handle Unicode normalization differently
- Test your domain filters with potential homograph variations
- Regularly audit your domain configurations for suspicious Unicode characters

## Dynamic filtering with code execution

The `_20260209` versions of web search and web fetch use code execution internally to apply dynamic filters against search results.

Including a standalone `code_execution` tool alongside `_20260209` versions of web tools creates two execution environments, which can confuse the model. Use one or the other, or pin both to the same version.

## Streaming server-tool events

Server-tool events stream as part of the normal SSE flow. The `server_tool_use` block and its result arrive as `content_block_start` and `content_block_delta` events, the same way text and client tool calls stream.

See [Streaming](https://platform.claude.com/docs/en/build-with-claude/streaming) for the full event reference. Individual tool pages document tool-specific event names where they differ.

## Batch requests

All server tools support batch processing. See [Batch processing](https://platform.claude.com/docs/en/build-with-claude/batch-processing).

## Next steps

[Web search\\
\\
Search the web and cite results.](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool) [Web fetch\\
\\
Retrieve content from specific URLs.](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-fetch-tool) [Code execution\\
\\
Run Python in a sandboxed container.](https://platform.claude.com/docs/en/agents-and-tools/tool-use/code-execution-tool) [Tool search\\
\\
Discover and load tools on demand.](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool)

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
