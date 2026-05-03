<!--
source_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview
requested_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview
fetch_date: 2026-05-02T01:27:35.641Z
crawl_job_id: 019deac1-71c6-7329-82ba-f7740c58e6e4
source_page_id: 6a36fedf-9a53-4bf7-bd1a-c919fde3fab6
chunk_ids: 570ded23-eae9-4ce9-8658-0985e575a1ae, 0412202f-ee07-4836-955a-7de57cc24153, e10f433f-d4e9-4541-a6d4-5e50c6e9931e
-->

# Tool use with Claude - Claude API Docs
Tools

Overview

Copy page

Tool use lets Claude call functions you define or that Anthropic provides. Claude decides when to call a tool based on the user's request and the tool's description, then returns a structured call that your application executes (client tools) or that Anthropic executes (server tools).

Here's the simplest example using a server tool, where Anthropic handles execution:

cURLCLIPythonTypeScript

```
import anthropic

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[{"type": "web_search_20260209", "name": "web_search"}],
    messages=[{"role": "user", "content": "What's the latest on the Mars rover?"}],
)
print(response.content)
```

* * *

## How tool use works

Tools differ primarily by where the code executes. **Client tools** (including user-defined tools and Anthropic-schema tools like bash and text\_editor) run in your application: Claude responds with `stop_reason: "tool_use"` and one or more `tool_use` blocks, your code executes the operation, and you send back a `tool_result`. **Server tools** (web\_search, code\_execution, web\_fetch, tool\_search) run on Anthropic's infrastructure: you see the results directly without handling execution.

For the full conceptual model including the agentic loop and when to choose each approach, see [How tool use works](https://platform.claude.com/docs/en/agents-and-tools/tool-use/how-tool-use-works).

For connecting to MCP servers, see the [MCP connector](https://platform.claude.com/docs/en/agents-and-tools/mcp-connector). For building your own MCP client, see [modelcontextprotocol.io](https://modelcontextprotocol.io/docs/develop/build-client).

**Guarantee schema conformance with strict tool use**

Add `strict: true` to your tool definitions to ensure Claude's tool calls always match your schema exactly. See [Strict tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/strict-tool-use).

Tool access is one of the highest-leverage primitives you can give an agent. On benchmarks like [LAB-Bench FigQA](https://lab-bench.org/) (scientific figure interpretation) and [SWE-bench](https://www.swebench.com/) (real-world software engineering), adding even basic tools produces outsized capability gains, often surpassing human expert baselines.

* * *

## Tool use examples

For a complete hands-on walkthrough, see the [tutorial](https://platform.claude.com/docs/en/agents-and-tools/tool-use/build-a-tool-using-agent). For reference examples of individual concepts, see [Define tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools) and [Handle tool calls](https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls).

### What happens when Claude needs more information

* * *

## Pricing

Tool use requests are priced based on:

1. The total number of input tokens sent to the model (including in the `tools` parameter)
2. The number of output tokens generated
3. For server-side tools, additional usage-based pricing (e.g., web search charges per search performed)

Client-side tools are priced the same as any other Claude API request, while server-side tools may incur additional charges based on their specific usage.

The additional tokens from tool use come from:

- The `tools` parameter in API requests (tool names, descriptions, and schemas)
- `tool_use` content blocks in API requests and responses
- `tool_result` content blocks in API requests

When you use `tools`, we also automatically include a special system prompt for the model which enables tool use. The number of tool use tokens required for each model are listed below (excluding the additional tokens listed above). Note that the table assumes at least 1 tool is provided. If no `tools` are provided, then a tool choice of `none` uses 0 additional system prompt tokens.

| Model | Tool choice | Tool use system prompt token count |
| --- | --- | --- |
| Claude Opus 4.7 | `auto`, `none`<br>* * *<br>`any`, `tool` | 346 tokens<br>* * *<br>313 tokens |
| Claude Opus 4.6 | `auto`, `none`<br>* * *<br>`any`, `tool` | 346 tokens<br>* * *<br>313 tokens |
| Claude Opus 4.5 | `auto`, `none`<br>* * *<br>`any`, `tool` | 346 tokens<br>* * *<br>313 tokens |
| Claude Opus 4.1 | `auto`, `none`<br>* * *<br>`any`, `tool` | 346 tokens<br>* * *<br>313 tokens |
| Claude Opus 4 | `auto`, `none`<br>* * *<br>`any`, `tool` | 346 tokens<br>* * *<br>313 tokens |
| Claude Sonnet 4.6 | `auto`, `none`<br>* * *<br>`any`, `tool` | 346 tokens<br>* * *<br>313 tokens |
| Claude Sonnet 4.5 | `auto`, `none`<br>* * *<br>`any`, `tool` | 346 tokens<br>* * *<br>313 tokens |
| Claude Sonnet 4 | `auto`, `none`<br>* * *<br>`any`, `tool` | 346 tokens<br>* * *<br>313 tokens |
| Claude Sonnet 3.7 ( [deprecated](https://platform.claude.com/docs/en/about-claude/model-deprecations)) | `auto`, `none`<br>* * *<br>`any`, `tool` | 346 tokens<br>* * *<br>313 tokens |
| Claude Haiku 4.5 | `auto`, `none`<br>* * *<br>`any`, `tool` | 346 tokens<br>* * *<br>313 tokens |
| Claude Haiku 3.5 | `auto`, `none`<br>* * *<br>`any`, `tool` | 264 tokens<br>* * *<br>340 tokens |
| Claude Opus 3 ( [deprecated](https://platform.claude.com/docs/en/about-claude/model-deprecations)) | `auto`, `none`<br>* * *<br>`any`, `tool` | 530 tokens<br>* * *<br>281 tokens |
| Claude Sonnet 3 | `auto`, `none`<br>* * *<br>`any`, `tool` | 159 tokens<br>* * *<br>235 tokens |
| Claude Haiku 3 | `auto`, `none`<br>* * *<br>`any`, `tool` | 264 tokens<br>* * *<br>340 tokens |

These token counts are added to your normal input and output tokens to calculate the total cost of a request.

Refer to the [models overview table](https://platform.claude.com/docs/en/about-claude/models/overview#latest-models-comparison) for current per-model prices.

When you send a tool use prompt, just like any other API request, the response will output both input and output token counts as part of the reported `usage` metrics.

* * *

## Next steps

### Choose your path

[Understand the concepts\\
\\
Where tools run, how the loop works, and when to use tools.](https://platform.claude.com/docs/en/agents-and-tools/tool-use/how-tool-use-works) [Build step by step\\
\\
The tutorial: from a single tool call to production.](https://platform.claude.com/docs/en/agents-and-tools/tool-use/build-a-tool-using-agent) [Browse all tools\\
\\
Directory of Anthropic-provided tools and properties.](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-reference)

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
