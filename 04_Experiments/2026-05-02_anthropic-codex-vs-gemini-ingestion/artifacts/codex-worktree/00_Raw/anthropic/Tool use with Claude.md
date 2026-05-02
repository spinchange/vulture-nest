# Tool use with Claude

- Captured: 2026-05-02
- Canonical URL: https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview
- Scope: Anthropic tool-use model and request/response loop

## Key captured points

- Tools are passed in the top-level `tools` field using JSON-schema-like definitions.
- Anthropic distinguishes `client tools` from `server tools` by where execution happens.
- For client tools, Claude returns `stop_reason: "tool_use"` plus one or more `tool_use` blocks.
- The caller executes the client tool and returns a `tool_result` block in a follow-up `user` message.
- Anthropic also supports `strict: true` tool definitions for schema-conformant calls.
- Server tools run on Anthropic infrastructure and surface results directly in the response.

## Why this matters

- Anthropic does not model tool execution exactly like providers that use a dedicated `tool` role.
- This page is the core source for provider-specific tool-loop semantics.
