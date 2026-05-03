<!--
source_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/parallel-tool-use
requested_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/parallel-tool-use
fetch_date: 2026-05-01T09:12:01.540Z
crawl_job_id: 019deac4-8fc1-755e-9b17-128c12dca8fe
source_page_id: 2295f704-fff7-48ee-bd41-9035b0e16c85
chunk_ids: 84da7635-3e27-4a02-8e3f-8984790fc2b7, b73b4eef-410f-4534-bb44-72765e26836a, 22aa2dfe-a14c-4660-a9e3-46178bee9d26, af342cf7-7990-4956-a0ab-478d17fb8f54, 1ff52c4e-10de-4e07-aafd-eaa107380cc1, 02a396fc-cade-43f2-864b-14c3e0206080
-->

# Parallel tool use - Claude API Docs
Tools

Parallel tool use

Copy page

This page covers parallel tool calls: when Claude calls multiple tools in one turn, how to format the message history so parallelism keeps working, and how to disable it. For the single-call flow, see [Handle tool calls](https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls).

By default, Claude may use multiple tools to answer a user query. You can disable this behavior by:

- Setting `disable_parallel_tool_use=true` when tool\_choice type is `auto`, which ensures that Claude uses **at most one** tool
- Setting `disable_parallel_tool_use=true` when tool\_choice type is `any` or `tool`, which ensures that Claude uses **exactly one** tool

## Worked example

**Simpler with Tool Runner**: The example below shows manual parallel tool handling. For most use cases, [Tool Runner](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner) automatically handles parallel tool execution with much less code.

Here's a complete, runnable script to test and verify parallel tool calls are working correctly:

PythonTypeScriptC#GoJavaPHPRuby

```
# Define tools
tools = [\
    {\
        "name": "get_weather",\
        "description": "Get the current weather in a given location",\
        "input_schema": {\
            "type": "object",\
            "properties": {\
                "location": {\
                    "type": "string",\
                    "description": "The city and state, e.g. San Francisco, CA",\
                }\
            },\
            "required": ["location"],\
        },\
    },\
    {\
        "name": "get_time",\
        "description": "Get the current time in a given timezone",\
        "input_schema": {\
            "type": "object",\
            "properties": {\
                "timezone": {\
                    "type": "string",\
                    "description": "The timezone, e.g. America/New_York",\
                }\
            },\
            "required": ["timezone"],\
        },\
    },\
]

# Test conversation with parallel tool calls
messages = [\
    {\
        "role": "user",\
        "content": "What's the weather in SF and NYC, and what time is it there?",\
    }\
]

# Make initial request
print("Requesting parallel tool calls...")
response = client.messages.create(
    model="claude-opus-4-7", max_tokens=1024, messages=messages, tools=tools
)

# Check for parallel tool calls
tool_uses = [block for block in response.content if block.type == "tool_use"]
print(f"\n✓ Claude made {len(tool_uses)} tool calls")

if len(tool_uses) > 1:
    print("✓ Parallel tool calls detected!")
    for tool in tool_uses:
        print(f"  - {tool.name}: {tool.input}")
else:
    print("✗ No parallel tool calls detected")

# Simulate tool execution and format results correctly
tool_results = []
for tool_use in tool_uses:
    if tool_use.name == "get_weather":
        if "San Francisco" in str(tool_use.input):
            result = "San Francisco: 68°F, partly cloudy"
        else:
            result = "New York: 45°F, clear skies"
    else:  # get_time
        if "Los_Angeles" in str(tool_use.input):
            result = "2:30 PM PST"
        else:
            result = "5:30 PM EST"

    tool_results.append(
        {"type": "tool_result", "tool_use_id": tool_use.id, "content": result}
    )

# Continue conversation with tool results
messages.extend(
    [\
        {"role": "assistant", "content": response.content},\
        {"role": "user", "content": tool_results},  # All results in one message!\
    ]
)

# Get final response
print("\nGetting final response...")
final_response = client.messages.create(
    model="claude-opus-4-7", max_tokens=1024, messages=messages, tools=tools
)

print(f"\nClaude's response:\n{final_response.content[0].text}")

# Verify formatting
print("\n--- Verification ---")
print(f"✓ Tool results sent in single user message: {len(tool_results)} results")
print("✓ No text before tool results in content array")
print("✓ Conversation formatted correctly for future parallel tool use")
```

This script demonstrates:

- How to properly format parallel tool calls and results
- How to verify that parallel calls are being made
- The correct message structure that encourages future parallel tool use
- Common mistakes to avoid (like text before tool results)

Run this script to test your implementation and ensure Claude is making parallel tool calls effectively.

## Maximizing parallel tool use

While Claude 4 models have excellent parallel tool use capabilities by default, you can increase the likelihood of parallel tool execution across all models with targeted prompting:

### System prompts for parallel tool use

### User message prompting

## Troubleshooting

If Claude isn't making parallel tool calls when expected, check these common issues:

**1\. Incorrect tool result formatting**

The most common issue is formatting tool results incorrectly in the conversation history. This "teaches" Claude to avoid parallel calls.

Specifically for parallel tool use:

- ❌ **Wrong**: Sending separate user messages for each tool result
- ✅ **Correct**: All tool results must be in a single user message

```
// ❌ This reduces parallel tool use
[\
  {"role": "assistant", "content": [tool_use_1, tool_use_2]},\
  {"role": "user", "content": [tool_result_1]},\
  {"role": "user", "content": [tool_result_2]}  // Separate message\
]

// ✅ This maintains parallel tool use
[\
  {"role": "assistant", "content": [tool_use_1, tool_use_2]},\
  {"role": "user", "content": [tool_result_1, tool_result_2]}  // Single message\
]
```

See [Handle tool calls](https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls) for other formatting rules.

**2\. Weak prompting**

Default prompting may not be sufficient. Use the stronger system prompt from the [Maximizing parallel tool use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/parallel-tool-use#maximizing-parallel-tool-use) section above.

**3\. Measuring parallel tool usage**

To verify parallel tool calls are working:

```
# Calculate average tools per tool-calling message
tool_call_messages = [\
    msg for msg in messages if any(block.type == "tool_use" for block in msg.content)\
]
total_tool_calls = sum(
    len([b for b in msg.content if b.type == "tool_use"]) for msg in tool_call_messages
)
avg_tools_per_message = (
    total_tool_calls / len(tool_call_messages) if tool_call_messages else 0.0
)
print(f"Average tools per message: {avg_tools_per_message}")
# Should be > 1.0 if parallel calls are working
```

## Next steps

- For the single-tool-call flow and `tool_result` formatting rules, see [Handle tool calls](https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls).
- For the SDK abstraction that handles parallel execution automatically, see [Tool Runner](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner).
- For the full tool-use workflow, see [Define tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools).

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
