<!--
source_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner
requested_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner
fetch_date: 2026-05-01T09:10:06.016Z
crawl_job_id: 019deac5-53d6-75b4-8ed7-799163246897
source_page_id: d71df651-ba99-4e21-a268-7ab216860e86
chunk_ids: 0f31a5f9-0d1c-40d4-9a47-44665fc66c91, 9e24d8a5-599b-4ffe-8bc4-3b70b535a7e9, b6ae22ac-cfe6-404b-84d9-c68c56f9309f, a4c6d70b-36fc-41f8-a1b0-bfaafec93394, 437bc2ab-a697-4d1a-bf97-f8101437d792, 62702ca0-8168-44cd-a4a7-9d8619ca9657, 776b5b92-77ca-4743-bdc7-40794eb14c56, 7ef459ca-d62b-42e9-9729-bdf9434824e7
-->

# Tool Runner (SDK) - Claude API Docs
Tools

Tool Runner (SDK)

Copy page

Tool Runner handles the agentic loop, error wrapping, and type safety so you don't have to. Use the [manual loop](https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls) only when you need human-in-the-loop approval, custom logging, or conditional execution. Available in Python, TypeScript, and Ruby SDKs.

The tool runner provides an out-of-the-box solution for executing tools with Claude. Instead of manually handling tool calls, tool results, and conversation management, the tool runner automatically:

- Executes tools when Claude calls them
- Handles the request/response cycle
- Manages conversation state
- Provides type safety and validation

Use the tool runner for most tool use implementations.

The tool runner is currently in beta and available in the [Python](https://github.com/anthropics/anthropic-sdk-python/blob/main/tools.md), [TypeScript](https://github.com/anthropics/anthropic-sdk-typescript/blob/main/helpers.md#tool-helpers), and [Ruby](https://github.com/anthropics/anthropic-sdk-ruby/blob/main/helpers.md#3-auto-looping-tool-runner-beta) SDKs.

**Automatic context management with compaction**

The tool runner supports automatic [compaction](https://platform.claude.com/docs/en/build-with-claude/context-editing#client-side-compaction-sdk), which generates summaries when token usage exceeds a threshold. This allows long-running agentic tasks to continue beyond context window limits.

## Basic usage

Define tools using the SDK helpers, then use the tool runner to execute them.

Python

Python

TypeScript

TypeScript

Ruby

Ruby

Use the `@beta_tool` decorator to define tools with type hints and docstrings.

If you're using the async client, replace `@beta_tool` with `@beta_async_tool` and define the function with `async def`.

```
import json
from anthropic import Anthropic, beta_tool

client = Anthropic()

@beta_tool
def get_weather(location: str, unit: str = "fahrenheit") -> str:
    """Get the current weather in a given location.

    Args:
        location: The city and state, e.g. San Francisco, CA
        unit: Temperature unit, either 'celsius' or 'fahrenheit'
    """
    return json.dumps({"temperature": "20°C", "condition": "Sunny"})

@beta_tool
def calculate_sum(a: int, b: int) -> str:
    """Add two numbers together.

    Args:
        a: First number
        b: Second number
    """
    return str(a + b)

runner = client.beta.messages.tool_runner(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[get_weather, calculate_sum],
    messages=[\
        {\
            "role": "user",\
            "content": "What's the weather like in Paris? Also, what's 15 + 27?",\
        }\
    ],
)
for message in runner:
    print(message)
```

The `@beta_tool` decorator inspects the function arguments and docstring to extract a JSON schema representation. For example, `calculate_sum` becomes:

```
{
  "name": "calculate_sum",
  "description": "Add two numbers together.",
  "input_schema": {
    "additionalProperties": false,
    "properties": {
      "a": {
        "description": "First number",
        "title": "A",
        "type": "integer"
      },
      "b": {
        "description": "Second number",
        "title": "B",
        "type": "integer"
      }
    },
    "required": ["a", "b"],
    "type": "object"
  }
}
```

The tool function must return a content block or content block array, including text, images, or document blocks. This allows tools to return rich, multimodal responses. Returned strings will be converted to a text content block. If you want to return a structured JSON object to Claude, encode it to a JSON string before returning it. Numbers, booleans, or other non-string primitives must also be converted to strings.

## Iterating over the tool runner

The tool runner is an iterable that yields messages from Claude. This is often referred to as a "tool call loop". Each iteration, the runner checks if Claude requested a tool use. If so, it calls the tool and sends the result back to Claude automatically, then yields the next message from Claude to continue your loop.

You can end the loop at any iteration with a `break` statement. The runner will loop until Claude returns a message without a tool use.

If you don't need intermediate messages, you can get the final message directly:

Python

Python

TypeScript

TypeScript

Ruby

Ruby

Use `runner.until_done()` to get the final message.

```

runner = client.beta.messages.tool_runner(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[get_weather, calculate_sum],
    messages=[\
        {\
            "role": "user",\
            "content": "What's the weather like in Paris? Also, what's 15 + 27?",\
        }\
    ],
)
final_message = runner.until_done()
print(final_message.content[0].text)
```

## Advanced usage

Within the loop, you can fully customize the tool runner's next request to the Messages API. The runner automatically appends tool results to the message history, so you don't need to manually manage them. You can optionally inspect the tool result for logging or debugging, and modify the request parameters before the next API call.

Python

Python

TypeScript

TypeScript

Ruby

Ruby

Use `generate_tool_call_response()` to optionally inspect the tool result (the runner appends it automatically). Use `set_messages_params()` and `append_messages()` to modify the request.

```
runner = client.beta.messages.tool_runner(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[get_weather],
    messages=[{"role": "user", "content": "What's the weather in San Francisco?"}],
)
for message in runner:
    # Optional: inspect the tool response (automatically appended by the runner)
    tool_response = runner.generate_tool_call_response()
    if tool_response:
        print(f"Tool result: {tool_response}")

    # Customize the next request
    runner.set_messages_params(
        lambda params: {
            **params,
            "max_tokens": 2048,  # Increase tokens for next request
        }
    )

    # Or add additional messages
    runner.append_messages(
        {"role": "user", "content": "Please be concise in your response."}
    )
```

### Debugging tool execution

When a tool throws an exception, the tool runner catches it and returns the error to Claude as a tool result with `is_error: true`. By default, only the exception message is included, not the full stack trace.

To view full stack traces and debug information, set the `ANTHROPIC_LOG` environment variable:

```
# View info-level logs including tool errors
export ANTHROPIC_LOG=info

# View debug-level logs for more verbose output
export ANTHROPIC_LOG=debug
```

When enabled, the SDK logs full exception details (using Python's `logging` module, the console in TypeScript, or Ruby's logger), including the complete stack trace when a tool fails.

### Intercepting tool errors

By default, tool errors are passed back to Claude, which can then respond appropriately. However, you may want to detect errors and handle them differently, for example, to stop execution early or implement custom error handling.

Use the tool response method to intercept tool results and check for errors before they're sent to Claude:

Python

Python

TypeScript

TypeScript

Ruby

Ruby

```

runner = client.beta.messages.tool_runner(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[my_tool],
    messages=[{"role": "user", "content": "Run the tool"}],
)

for message in runner:
    tool_response = runner.generate_tool_call_response()

    if tool_response is not None:
        # tool_response is a dict: {"role": "user", "content": [...]}
        # Check if any tool result has an error
        for block in tool_response["content"]:
            if block.get("is_error"):
                # Option 1: Raise an exception to stop the loop
                raise RuntimeError(f"Tool failed: {json.dumps(block['content'])}")

                # Option 2: Log and continue (let Claude handle it)
                # logger.error(f"Tool error: {json.dumps(block['content'])}")

    # Process the message normally
    print(message.content)
```

### Modifying tool results

You can modify tool results before they're sent back to Claude. This is useful for adding metadata like `cache_control` to enable [prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching) on tool results, or for transforming the tool output.

Use the tool response method to get the tool result, then modify it before the runner proceeds. Whether you explicitly append the modified result or mutate it in place depends on the SDK; see the code comments in each tab.

Python

Python

TypeScript

TypeScript

Ruby

Ruby

```

runner = client.beta.messages.tool_runner(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[search_documents],
    messages=[\
        {\
            "role": "user",\
            "content": "Search for information about the climate of San Francisco",\
        }\
    ],
)

for message in runner:
    tool_response = runner.generate_tool_call_response()

    if tool_response is not None:
        # tool_response is a dict: {"role": "user", "content": [...]}
        # Modify the tool result to add cache control
        for block in tool_response["content"]:
            if block["type"] == "tool_result":
                # Add cache_control to cache this tool result
                block["cache_control"] = {"type": "ephemeral"}

        # Append the modified response (this prevents auto-append of the original)
        runner.append_messages(message, tool_response)

    print(message.content)
```

Adding `cache_control` to tool results is particularly useful when tools return large amounts of data (like document search results) that you want to cache for subsequent API calls. See [Prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching) for more details on caching strategies.

## Streaming

Enable streaming to receive events as they arrive. Each iteration yields a stream object that you can iterate for events.

Python

Python

TypeScript

TypeScript

Ruby

Ruby

Set `stream=True` and use `get_final_message()` to get the accumulated message.

```

runner = client.beta.messages.tool_runner(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[calculate_sum],
    messages=[{"role": "user", "content": "What is 15 + 27?"}],
    stream=True,
)

# When streaming, the runner returns BetaMessageStream
for message_stream in runner:
    for event in message_stream:
        print("event:", event)
    print("message:", message_stream.get_final_message())

print(runner.until_done())
```

## Next steps

- For manual control over the tool-call loop, see [Handle tool calls](https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls).
- For running multiple tools concurrently, see [Parallel tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/parallel-tool-use).
- For the full tool-use workflow, see [Define tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools).

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
