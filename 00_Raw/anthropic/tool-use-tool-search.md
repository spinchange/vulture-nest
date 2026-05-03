<!--
source_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool
requested_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool
fetch_date: 2026-05-02T01:27:37.973Z
crawl_job_id: 019deac6-4d27-7271-8a81-945746e6f061
source_page_id: f05652f7-40e2-43b1-a54f-6edeed870853
chunk_ids: 34483ea4-4efb-4091-b621-31140249cb2c, 51a6fc94-9ec3-49c9-92a3-93e856f91619, 3249e589-327e-4bc6-8920-eeaf5b5a17e7, 4b7e3bc5-d7fd-49b6-a1f7-4aff72303265, e63ee0a0-810a-45d4-8b9c-e3d4eb623540, a2062d32-4c5c-4920-bed6-89dcb959e49d, c2a5e531-1905-4c34-ba74-4afede053bcb, d10e8e6f-f6f2-495a-ba25-28d7e791d015, 90e29679-5380-4e7d-bb26-5a9c307548d3, 91a1f1e2-6fac-4e0d-8086-f16e81285fe9, 8ef3255e-3fc5-496e-91a2-d863115632e7, 29304b36-1ccd-4f6a-984e-4a428401ad33, 3af60663-142b-414b-8bb8-fa40101dc5a8
-->

# Tool search tool - Claude API Docs
Tool infrastructure

Tool search

Copy page

The tool search tool enables Claude to work with hundreds or thousands of tools by dynamically discovering and loading them on-demand. Instead of loading all tool definitions into the context window upfront, Claude searches your tool catalog (including tool names, descriptions, argument names, and argument descriptions) and loads only the tools it needs.

This approach solves two problems that compound quickly as tool libraries scale:

- **Context bloat:** Tool definitions eat into your context budget fast. A typical multi-server setup (GitHub, Slack, Sentry, Grafana, Splunk) can consume ~55k tokens in definitions before Claude does any actual work. Tool search typically reduces this by over 85%, loading only the 3–5 tools Claude actually needs for a given request.
- **Tool selection accuracy:** Claude's ability to correctly pick the right tool degrades significantly once you exceed 30–50 available tools. By surfacing a focused set of relevant tools on demand, tool search keeps selection accuracy high even across thousands of tools.

For background on the scaling challenges that tool search solves, see [Advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use). Tool search's on-demand loading is also an instance of the broader just-in-time retrieval principle described in [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).

Although this is provided as a server-side tool, you can also implement your own client-side tool search functionality. See [Custom tool search implementation](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool#custom-tool-search-implementation) for details.

Share feedback on this feature through the [feedback form](https://forms.gle/MhcGFFwLxuwnWTkYA).

This feature is eligible for [Zero Data Retention (ZDR)](https://platform.claude.com/docs/en/build-with-claude/api-and-data-retention). When your organization has a ZDR arrangement, data sent through this feature is not stored after the API response is returned.

On Amazon Bedrock, server-side tool search is available only via the [invoke\\
API](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-runtime_example_bedrock-runtime_InvokeModel_AnthropicClaude_section.html),
not the converse API.

You can also implement [client-side tool search](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool#custom-tool-search-implementation) by returning `tool_reference` blocks from your own search implementation.

## How tool search works

There are two tool search variants:

- **Regex** (`tool_search_tool_regex_20251119`): Claude constructs regex patterns to search for tools
- **BM25** (`tool_search_tool_bm25_20251119`): Claude uses natural language queries to search for tools

When you enable the tool search tool:

1. You include a tool search tool (e.g., `tool_search_tool_regex_20251119` or `tool_search_tool_bm25_20251119`) in your tools list
2. You provide all tool definitions with `defer_loading: true` for tools that shouldn't be loaded immediately
3. Claude sees only the tool search tool and any non-deferred tools initially
4. When Claude needs additional tools, it searches using a tool search tool
5. The API returns 3-5 most relevant `tool_reference` blocks
6. These references are automatically expanded into full tool definitions
7. Claude selects from the discovered tools and invokes them

This keeps your context window efficient while maintaining high tool selection accuracy.

## Quick start

Here's a simple example with deferred tools:

cURLCLIPythonTypeScriptC#GoJavaPHPRuby

```
client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=2048,
    messages=[{"role": "user", "content": "What is the weather in San Francisco?"}],
    tools=[\
        {"type": "tool_search_tool_regex_20251119", "name": "tool_search_tool_regex"},\
        {\
            "name": "get_weather",\
            "description": "Get the weather at a specific location",\
            "input_schema": {\
                "type": "object",\
                "properties": {\
                    "location": {"type": "string"},\
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},\
                },\
                "required": ["location"],\
            },\
            "defer_loading": True,\
        },\
        {\
            "name": "search_files",\
            "description": "Search through files in the workspace",\
            "input_schema": {\
                "type": "object",\
                "properties": {\
                    "query": {"type": "string"},\
                    "file_types": {"type": "array", "items": {"type": "string"}},\
                },\
                "required": ["query"],\
            },\
            "defer_loading": True,\
        },\
    ],
)

print(response)
```

## Tool definition

The tool search tool has two variants:

JSON

```
{
  "type": "tool_search_tool_regex_20251119",
  "name": "tool_search_tool_regex"
}
```

JSON

```
{
  "type": "tool_search_tool_bm25_20251119",
  "name": "tool_search_tool_bm25"
}
```

**Regex variant query format: Python regex, NOT natural language**

When using `tool_search_tool_regex_20251119`, Claude constructs regex patterns using Python's `re.search()` syntax, not natural language queries. Common patterns:

- `"weather"` \- matches tool names/descriptions containing "weather"
- `"get_.*_data"` \- matches tools like `get_user_data`, `get_weather_data`
- `"database.*query|query.*database"` \- OR patterns for flexibility
- `"(?i)slack"` \- case-insensitive search

Maximum query length: 200 characters

**BM25 variant query format: Natural language**

When using `tool_search_tool_bm25_20251119`, Claude uses natural language queries to search for tools.

### Deferred tool loading

Mark tools for on-demand loading by adding `defer_loading: true`:

JSON

```
{
  "name": "get_weather",
  "description": "Get current weather for a location",
  "input_schema": {
    "type": "object",
    "properties": {
      "location": { "type": "string" },
      "unit": { "type": "string", "enum": ["celsius", "fahrenheit"] }
    },
    "required": ["location"]
  },
  "defer_loading": true
}
```

**Key points:**

- Tools without `defer_loading` are loaded into context immediately
- Tools with `defer_loading: true` are only loaded when Claude discovers them via search
- The tool search tool itself should **never** have `defer_loading: true`
- Keep your 3-5 most frequently used tools as non-deferred for optimal performance

Both tool search variants (`regex` and `bm25`) search tool names, descriptions, argument names, and argument descriptions.

**How deferral works internally:** Deferred tools are not included in the system-prompt prefix. When the model discovers a deferred tool through tool search, the tool definition is appended inline as a `tool_reference` block in the conversation. The prefix is untouched, so prompt caching is preserved. The grammar for strict mode builds from the full toolset, so `defer_loading` and strict mode compose without grammar recompilation.

## Response format

When Claude uses the tool search tool, the response includes new block types:

JSON

```
{
  "role": "assistant",
  "content": [\
    {\
      "type": "text",\
      "text": "I'll search for tools to help with the weather information."\
    },\
    {\
      "type": "server_tool_use",\
      "id": "srvtoolu_01ABC123",\
      "name": "tool_search_tool_regex",\
      "input": {\
        "query": "weather"\
      }\
    },\
    {\
      "type": "tool_search_tool_result",\
      "tool_use_id": "srvtoolu_01ABC123",\
      "content": {\
        "type": "tool_search_tool_search_result",\
        "tool_references": [{ "type": "tool_reference", "tool_name": "get_weather" }]\
      }\
    },\
    {\
      "type": "text",\
      "text": "I found a weather tool. Let me get the weather for San Francisco."\
    },\
    {\
      "type": "tool_use",\
      "id": "toolu_01XYZ789",\
      "name": "get_weather",\
      "input": { "location": "San Francisco", "unit": "fahrenheit" }\
    }\
  ],
  "stop_reason": "tool_use"
}
```

### Understanding the response

- **`server_tool_use`:** Indicates Claude is invoking the tool search tool
- **`tool_search_tool_result`:** Contains the search results with a nested `tool_search_tool_search_result` object
- **`tool_references`:** Array of `tool_reference` objects pointing to discovered tools
- **`tool_use`:** Claude invoking the discovered tool

The `tool_reference` blocks are automatically expanded into full tool definitions before being shown to Claude. You don't need to handle this expansion yourself. It happens automatically in the API as long as you provide all matching tool definitions in the `tools` parameter.

## MCP integration

For configuring `mcp_toolset` with `defer_loading`, see [MCP connector](https://platform.claude.com/docs/en/agents-and-tools/mcp-connector).

## Custom tool search implementation

You can implement your own tool search logic (e.g., using embeddings or semantic search) by returning `tool_reference` blocks from a custom tool. When Claude calls your custom search tool, return a standard `tool_result` with `tool_reference` blocks in the content array:

JSON

```
{
  "type": "tool_result",
  "tool_use_id": "toolu_your_tool_id",
  "content": [{ "type": "tool_reference", "tool_name": "discovered_tool_name" }]
}
```

Every tool referenced must have a corresponding tool definition in the top-level `tools` parameter with `defer_loading: true`. This approach lets you use more sophisticated search algorithms while maintaining compatibility with the tool search system.

The `tool_search_tool_result` format shown in the [Response format](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool#response-format) section is the server-side format used internally by Anthropic's built-in tool search. For custom client-side implementations, always use the standard `tool_result` format with `tool_reference` content blocks as shown above.

For a complete example using embeddings, see the [tool search with embeddings cookbook](https://platform.claude.com/cookbooks/tool_use).

## Error handling

The tool search tool is not compatible with [tool use\\
examples](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools#providing-tool-use-examples).
If you need to provide examples of tool usage, use standard tool calling
without tool search.

### HTTP errors (400 status)

These errors prevent the request from being processed:

**All tools deferred:**

```
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "All tools have defer_loading set. At least one tool must be non-deferred."
  }
}
```

**Missing tool definition:**

```
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "Tool reference 'unknown_tool' has no corresponding tool definition"
  }
}
```

### Tool result errors (200 status)

Errors during tool execution return a 200 response with error information in the body:

JSON

```
{
  "type": "tool_result",
  "tool_use_id": "srvtoolu_01ABC123",
  "content": {
    "type": "tool_search_tool_result_error",
    "error_code": "invalid_pattern"
  }
}
```

**Error codes:**

- `too_many_requests`: Rate limit exceeded for tool search operations
- `invalid_pattern`: Malformed regex pattern
- `pattern_too_long`: Pattern exceeds 200 character limit
- `unavailable`: Tool search service temporarily unavailable

### Common mistakes

### 400 Error: All tools are deferred

### 400 Error: Missing tool definition

### Claude doesn't find expected tools

## Prompt caching

For how `defer_loading` preserves prompt caching, see [Tool use with prompt caching](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-use-with-prompt-caching).

The system automatically expands `tool_reference` blocks throughout the entire conversation history, so Claude can reuse discovered tools in subsequent turns without re-searching.

## Streaming

With streaming enabled, you'll receive tool search events as part of the stream:

```
event: content_block_start
data: {"type": "content_block_start", "index": 1, "content_block": {"type": "server_tool_use", "id": "srvtoolu_xyz789", "name": "tool_search_tool_regex"}}

// Search query streamed
event: content_block_delta
data: {"type": "content_block_delta", "index": 1, "delta": {"type": "input_json_delta", "partial_json": "{\"query\":\"weather\"}"}}

// Pause while search executes

// Search results streamed
event: content_block_start
data: {"type": "content_block_start", "index": 2, "content_block": {"type": "tool_search_tool_result", "tool_use_id": "srvtoolu_xyz789", "content": {"type": "tool_search_tool_search_result", "tool_references": [{"type": "tool_reference", "tool_name": "get_weather"}]}}}

// Claude continues with discovered tools
```

## Batch requests

You can include the tool search tool in the [Messages Batches API](https://platform.claude.com/docs/en/build-with-claude/batch-processing). Tool search operations through the Messages Batches API are priced the same as those in regular Messages API requests.

## Limits and best practices

### Limits

- **Maximum tools:** 10,000 tools in your catalog
- **Search results:** Returns 3-5 most relevant tools per search
- **Pattern length:** Maximum 200 characters for regex patterns
- **Model support:** [Claude Mythos Preview](https://anthropic.com/glasswing), Sonnet 4.0+, Opus 4.0+, Haiku 4.5+

### When to use tool search

**Good use cases:**

- 10+ tools available in your system
- Tool definitions consuming >10k tokens
- Experiencing tool selection accuracy issues with large tool sets
- Building MCP-powered systems with multiple servers (200+ tools)
- Tool library growing over time

**When traditional tool calling might be better:**

- Less than 10 tools total
- All tools are frequently used in every request
- Very small tool definitions (<100 tokens total)

### Optimization tips

- Keep 3-5 most frequently used tools as non-deferred
- Write clear, descriptive tool names and descriptions
- Use consistent namespacing in tool names: prefix by service or resource (e.g., `github_`, `slack_`) so that search queries naturally surface the right tool group
- Use semantic keywords in descriptions that match how users describe tasks
- Add a system prompt section describing available tool categories: "You can search for tools to interact with Slack, GitHub, and Jira"
- Monitor which tools Claude discovers to refine descriptions

## Usage

Tool search tool usage is tracked in the response usage object:

JSON

```
{
  "usage": {
    "input_tokens": 1024,
    "output_tokens": 256,
    "server_tool_use": {
      "tool_search_requests": 2
    }
  }
}
```

## Next steps

[Tool reference\\
\\
Full tool catalog with model compatibility and parameters.](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-reference) [MCP connector\\
\\
Configure MCP toolsets with deferred loading.](https://platform.claude.com/docs/en/agents-and-tools/mcp-connector) [Prompt caching\\
\\
Combine tool search with cached tool definitions.](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-use-with-prompt-caching) [Define tools\\
\\
Step-by-step guide for defining tools.](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools)

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
