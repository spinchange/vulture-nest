<!--
source_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/strict-tool-use
requested_url: https://platform.claude.com/docs/en/agents-and-tools/tool-use/strict-tool-use
fetch_date: 2026-05-01T09:11:37.978Z
crawl_job_id: 019deac4-5d5f-712e-8d1d-6086cbde05eb
source_page_id: 72e8d5d4-68f1-4403-9c39-774b051bb60c
chunk_ids: cd823fb5-a8f8-4b9e-87de-7f5aeb85c897, c21c365f-0ead-4f04-97a3-12a26dfd8027, f3579171-9477-43a4-94e6-5fef51aac84b, b7460f9d-c621-4ce7-9dab-2d78fb61e95d, 67033223-d195-4e74-b31c-b99ceb6e52b0
-->

# Strict tool use - Claude API Docs
Tools

Strict tool use

Copy page

Setting `strict: true` on a tool definition uses grammar-constrained sampling to guarantee Claude's tool inputs match your JSON Schema. This page covers why strict mode matters for agents, how to enable it, and common use cases. For the supported JSON Schema subset, see [JSON Schema limitations](https://platform.claude.com/docs/en/build-with-claude/structured-outputs#json-schema-limitations). For non-strict schema guidance, see [Define tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools).

Strict tool use validates tool parameters, ensuring Claude calls your functions with correctly-typed arguments. Use strict tool use when you need to:

- Validate tool parameters
- Build agentic workflows
- Ensure type-safe function calls
- Handle complex tools with nested properties

## Why strict tool use matters for agents

Building reliable agentic systems requires guaranteed schema conformance. Without strict mode, Claude might return incompatible types (`"2"` instead of `2`) or missing required fields, breaking your functions and causing runtime errors.

Strict tool use guarantees type-safe parameters:

- Functions receive correctly-typed arguments every time
- No need to validate and retry tool calls
- Production-ready agents that work consistently at scale

For example, suppose a booking system needs `passengers: int`. Without strict mode, Claude might provide `passengers: "two"` or `passengers: "2"`. With `strict: true`, the response will always contain `passengers: 2`.

## Quick start

cURLCLIPythonTypeScriptC#GoJavaPHPRuby

```
client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{"role": "user", "content": "What's the weather like in San Francisco?"}],
    tools=[\
        {\
            "name": "get_weather",\
            "description": "Get the current weather in a given location",\
            "strict": True,  # Enable strict mode\
            "input_schema": {\
                "type": "object",\
                "properties": {\
                    "location": {\
                        "type": "string",\
                        "description": "The city and state, e.g. San Francisco, CA",\
                    },\
                    "unit": {\
                        "type": "string",\
                        "enum": ["celsius", "fahrenheit"],\
                        "description": "The unit of temperature, either 'celsius' or 'fahrenheit'",\
                    },\
                },\
                "required": ["location"],\
                "additionalProperties": False,\
            },\
        }\
    ],
)
print(response.content)
```

**Response format:** Tool use blocks with validated inputs in `response.content[x].input`

Output

```
{
  "type": "tool_use",
  "name": "get_weather",
  "input": {
    "location": "San Francisco, CA"
  }
}
```

**Guarantees:**

- Tool `input` strictly follows the `input_schema`
- Tool `name` is always valid (from provided tools or server tools)

## How it works

1. 1



Define your tool schema







Create a JSON schema for your tool's `input_schema`. The schema uses standard JSON Schema format with some limitations (see [JSON Schema limitations](https://platform.claude.com/docs/en/build-with-claude/structured-outputs#json-schema-limitations)).

2. 2



Add strict: true







Set `"strict": true` as a top-level property in your tool definition, alongside `name`, `description`, and `input_schema`.

3. 3



Handle tool calls







When Claude uses the tool, the `input` field in the tool\_use block will strictly follow your `input_schema`, and the `name` will always be valid.


## Common use cases

### Validated tool inputs

### Agentic workflow with multiple validated tools

## Data retention

Strict tool use compiles tool `input_schema` definitions into grammars using the same pipeline as [structured outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs). Tool schemas are temporarily cached for up to 24 hours since last use. Prompts and responses are not retained beyond the API response.

Strict tool use is HIPAA eligible, but **PHI must not be included in tool schema definitions**. The API caches compiled schemas separately from message content, and these cached schemas do not receive the same PHI protections as prompts and responses. Do not include PHI in `input_schema` property names, `enum` values, `const` values, or `pattern` regular expressions. PHI should only appear in message content (prompts and responses), where it is protected under HIPAA safeguards.

For ZDR and HIPAA eligibility across all features, see [API and data retention](https://platform.claude.com/docs/en/build-with-claude/api-and-data-retention).

Was this page helpful?
