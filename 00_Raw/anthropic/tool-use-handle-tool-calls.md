<!--
source_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls
requested_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls
fetch_date: 2026-05-01T09:09:39.859Z
crawl_job_id: 019deac2-b760-7112-9b06-5e0da6c28c2b
source_page_id: 73627ce7-47ae-433b-ae28-4e6b22703fea
chunk_ids: fedbbf0e-82dd-4326-8a4f-bb15c9c77672, 9545cf20-6698-49c9-b6a1-1a68e58d5bce, 7e6b235c-d080-452a-bf75-317da2b952c4, 8929c927-3b15-4e6d-bd26-88554ccfee30
-->

# Handle tool calls - Claude API Docs
Tools

Handle tool calls

Copy page

This page covers the tool-call lifecycle: reading `tool_use` blocks from Claude's response, formatting `tool_result` blocks in your reply, and signaling errors. For the SDK abstraction that handles this automatically, see [Tool Runner](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner).

**Simpler with Tool Runner**: The manual tool handling described on this page is automatically managed by [Tool Runner](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner). Use this page when you need custom control over tool execution.

Claude's response differs based on whether it uses a client or server tool.

## Handling results from client tools

The response will have a `stop_reason` of `tool_use` and one or more `tool_use` content blocks that include:

- `id`: A unique identifier for this particular tool use block. This will be used to match up the tool results later.
- `name`: The name of the tool being used.
- `input`: An object containing the input being passed to the tool, conforming to the tool's `input_schema`.

### Example API response with a \`tool\_use\` content block

When you receive a tool use response for a client tool, you should:

1. Extract the `name`, `id`, and `input` from the `tool_use` block.
2. Run the actual tool in your codebase corresponding to that tool name, passing in the tool `input`.
3. Continue the conversation by sending a new message with the `role` of `user`, and a `content` block containing the `tool_result` type and the following information:

   - `tool_use_id`: The `id` of the tool use request this is a result for.
   - `content`: The result of the tool, as a string (for example, `"content": "15 degrees"`), a list of nested content blocks (for example, `"content": [{"type": "text", "text": "15 degrees"}]`), or a list of document blocks (for example, `"content": [{"type": "document", "source": {"type": "text", "media_type": "text/plain", "data": "15 degrees"}}]`). These content blocks can use the `text`, `image`, or `document` types.
   - `is_error` (optional): Set to `true` if the tool execution resulted in an error.

**Important formatting requirements**:

- Tool result blocks must immediately follow their corresponding tool use blocks in the message history. You cannot include any messages between the assistant's tool use message and the user's tool result message.
- In the user message containing tool results, the tool\_result blocks must come FIRST in the content array. Any text must come AFTER all tool results.

For example, this will cause a 400 error:

```
{
  "role": "user",
  "content": [\
    { "type": "text", "text": "Here are the results:" }, // ❌ Text before tool_result\
    { "type": "tool_result", "tool_use_id": "toolu_01" /* ... */ }\
  ]
}
```

This is correct:

```
{
  "role": "user",
  "content": [\
    { "type": "tool_result", "tool_use_id": "toolu_01" /* ... */ },\
    { "type": "text", "text": "What should I do next?" } // ✅ Text after tool_result\
  ]
}
```

If you receive an error like "tool\_use ids were found without tool\_result blocks immediately after", check that your tool results are formatted correctly.

### Example of successful tool result

### Example of tool result with images

### Example of empty tool result

### Example of tool result with documents

After receiving the tool result, Claude will use that information to continue generating a response to the original user prompt.

## Handling results from server tools

Claude executes the tool internally and incorporates the results directly into its response without requiring additional user interaction.

**Differences from other APIs**

Unlike APIs that separate tool use or use special roles like `tool` or `function`, the Claude API integrates tools directly into the `user` and `assistant` message structure.

Messages contain arrays of `text`, `image`, `tool_use`, and `tool_result` blocks. `user` messages include client content and `tool_result`, while `assistant` messages contain AI-generated content and `tool_use`.

## Handling errors with is\_error

There are a few different types of errors that can occur when using tools with Claude:

### Tool execution error

### Invalid tool name

### Server tool errors

## Next steps

- For running multiple tools in one turn, see [Parallel tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/parallel-tool-use).
- For the SDK abstraction that automates this loop, see [Tool Runner](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner).
- For the full tool-use workflow, see [Define tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools).

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
