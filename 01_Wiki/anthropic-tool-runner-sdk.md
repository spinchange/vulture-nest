---
title: Anthropic Tool Runner SDK
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-tool-runner
  - anthropic-sdk-tool-loop
source: "[[lit-anthropic-tool-use-depth]]"
---

# Anthropic Tool Runner SDK

The **Tool Runner** is an SDK-provided abstraction over the manual tool call loop. It handles request/response cycling, tool execution, conversation state management, and error wrapping. Available in Python, TypeScript, and Ruby SDKs (beta).

## When to Use

**Use Tool Runner when:** you want Claude to call tools and receive results automatically — the common case.

**Use the manual loop when:** you need human-in-the-loop approval between tool calls, custom logging of intermediate states, or conditional execution based on tool results before continuing.

## Basic Pattern (Python)

```python
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

runner = client.beta.messages.tool_runner(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[get_weather],
    messages=[{"role": "user", "content": "What's the weather in Paris?"}],
)

# Iterate to get intermediate messages, or:
final = runner.until_done()
```

The `@beta_tool` decorator introspects the function signature and docstring to generate a JSON schema. Tool functions must return a string, content block, or content block array — non-string primitives must be stringified.

## The Tool Call Loop

`runner` is an iterable that yields messages from Claude. Each iteration:
1. If the previous message contained `stop_reason: "tool_use"`, the runner executes the requested tools and sends results back automatically.
2. The next Claude message is yielded.
3. The loop ends when Claude returns a message without tool use.

`runner.until_done()` skips intermediate yields and returns only the final message.

## Compaction for Long-Running Agents

Tool Runner supports automatic context compaction: when token usage exceeds a threshold, the runner generates a summary of the conversation and continues, allowing agentic tasks to run beyond the context window limit. This is critical for long-horizon workflows.

## Advanced: Intercepting and Modifying Results

```python
for message in runner:
    tool_response = runner.generate_tool_call_response()

    if tool_response is not None:
        # Check for errors before Claude sees them
        for block in tool_response["content"]:
            if block.get("is_error"):
                raise RuntimeError(f"Tool failed: {block['content']}")
            # Add cache_control to large tool results
            if block["type"] == "tool_result":
                block["cache_control"] = {"type": "ephemeral"}

        # Append modified response (prevents auto-append of original)
        runner.append_messages(message, tool_response)
```

`generate_tool_call_response()` returns the tool result dict that would be sent back. Appending it manually (with modifications) prevents the runner from auto-appending the original. See [[anthropic-prompt-caching]] for the caching benefit of this pattern with large tool results.

## Error Behavior

By default, exceptions thrown by tools are caught and returned to Claude as `is_error: true` tool results — Claude can then decide how to respond. The full stack trace is logged (not sent to the model) when `ANTHROPIC_LOG=debug` is set.

To stop the loop on error rather than letting Claude handle it, intercept via `generate_tool_call_response()` and raise before the runner proceeds.

## Streaming

```python
runner = client.beta.messages.tool_runner(
    model="claude-opus-4-7",
    max_tokens=1024,
    tools=[get_weather],
    messages=[{"role": "user", "content": "What's the weather?"}],
    stream=True,
)

for message_stream in runner:
    for event in message_stream:
        print("event:", event)
    print("final:", message_stream.get_final_message())
```

With `stream=True`, each iteration yields a stream object rather than a complete message.

## Architectural Note

Tool Runner is a convenience layer, not a protocol change. It uses the same Messages API with the same tool call loop described in [[anthropic-tool-use]] — it just eliminates the boilerplate. The same constraints apply: tool results must follow tool use turns, `tool_choice` limitations still exist, and thinking block preservation rules still apply when using adaptive thinking.

## See also

- [[anthropic-tool-use]]
- [[anthropic-messages-api]]
- [[anthropic-mcp-connector]]
- [[anthropic-adaptive-thinking]]
- [[lit-anthropic-tool-use-depth]]
