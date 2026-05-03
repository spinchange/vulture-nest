<!--
source_url: https://platform.claude.com/docs/en/managed-agents/tools
requested_url: https://platform.claude.com/docs/en/managed-agents/tools
fetch_date: 2026-05-01T09:11:33.874Z
crawl_job_id: 019dec07-04da-77fe-9f1b-6ef055012dd1
source_page_id: e2f7a678-6e5a-43e9-872c-9f19f455e7a0
chunk_ids: 5f9352f8-2d96-4e21-b78c-9828709d1c14, 2ec803f8-0036-4e84-9b5e-0bc6ec852e31, fbb8ca4e-361f-4e70-a07a-c0d354e32d28, cb9636ee-f2a1-48ad-a901-ba37bcb16dbb
-->

# Tools - Claude API Docs
|
|

|
|

|
|

|
|

|
|

|
|

|
|

Define your agent

Tools

Copy page

Claude Managed Agents provides a set of built-in tools that Claude can use autonomously within a session. You control which tools are available by specifying them in the agent configuration.

Custom, user-defined tools are also supported. Your application executes these tools separately and sends the tool results back to Claude; Claude can use the results to continue the task at hand.

All Managed Agents API requests require the `managed-agents-2026-04-01` beta header. The SDK sets the beta header automatically.

## Available tools

The agent toolset includes the following tools. All are enabled by default when you include the toolset in your agent configuration.

| Tool | Name | Description |
| --- | --- | --- |
| Bash | `bash` | Execute bash commands in a shell session |
| Read | `read` | Read a file from the local filesystem |
| Write | `write` | Write a file to the local filesystem |
| Edit | `edit` | Perform string replacement in a file |
| Glob | `glob` | Fast file pattern matching using glob patterns |
| Grep | `grep` | Text search using regex patterns |
| Web fetch | `web_fetch` | Fetch content from a URL |
| Web search | `web_search` | Search the web for information |

## Configuring the toolset

Enable the full toolset with `agent_toolset_20260401` when creating an agent. Use the `configs` array to disable specific tools or override their settings.

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
ant beta:agents create <<'YAML'
name: Coding Assistant
model: claude-opus-4-7
tools:
  - type: agent_toolset_20260401
    configs:
      - name: web_fetch
        enabled: false
YAML
```

### Disabling specific tools

To disable a tool, set `enabled: false` in its config entry:

```
{
  "type": "agent_toolset_20260401",
  "configs": [\
    { "name": "web_fetch", "enabled": false },\
    { "name": "web_search", "enabled": false }\
  ]
}
```

### Enabling only specific tools

To start with everything off and enable only what you need, set `default_config.enabled` to `false`:

```
{
  "type": "agent_toolset_20260401",
  "default_config": { "enabled": false },
  "configs": [\
    { "name": "bash", "enabled": true },\
    { "name": "read", "enabled": true },\
    { "name": "write", "enabled": true }\
  ]
}
```

## Custom tools

In addition to built-in tools, you can define custom tools. Custom tools are analogous to [user-defined client tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/how-tool-use-works#user-defined-tools-client-executed) in the Messages API.

Custom tools allow you to extend Claude's capabilities to perform a wider variety of tasks. Each tool defines a contract: you specify what operations are available and what they return; Claude decides when and how to call them. The model never executes anything on its own. It emits a structured request, your code runs the operation, and the result flows back into the conversation.

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
ant beta:agents create <<'YAML'
name: Weather Agent
model: claude-opus-4-7
tools:
  - type: agent_toolset_20260401
  - type: custom
    name: get_weather
    description: Get current weather for a location
    input_schema:
      type: object
      properties:
        location:
          type: string
          description: City name
      required:
        - location
YAML
```

Once you've defined the tool at the agent level, the agent will invoke the tools through the course of a session. See [Session event stream](https://platform.claude.com/docs/en/managed-agents/events-and-streaming#handling-custom-tool-calls) for the full flow.

### Best practices for custom tool definitions

- **Provide extremely detailed descriptions.** This is by far the most important factor in tool performance. Your descriptions should explain what the tool does, when it should be used (and when it shouldn't), what each parameter means and how it affects the tool's behavior, and any important caveats or limitations. The more context you can give Claude about your tools, the better it will be at deciding when and how to use them. Aim for at least 3-4 sentences per tool description, more if the tool is complex.
- **Consolidate related operations into fewer tools.** Rather than creating a separate tool for every action (`create_pr`, `review_pr`, `merge_pr`), group them into a single tool with an `action` parameter. Fewer, more capable tools reduce selection ambiguity and make your tool surface easier for Claude to navigate.
- **Use meaningful namespacing in tool names.** When your tools span multiple services or resources, prefix names with the resource (e.g., `db_query`, `storage_read`). This makes tool selection unambiguous as your library grows.
- **Design tool responses to return only high-signal information.** Return semantic, stable identifiers (e.g., slugs or UUIDs) rather than opaque internal references, and include only the fields Claude needs to reason about its next step. Bloated responses waste context and make it harder for Claude to extract what matters.

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
