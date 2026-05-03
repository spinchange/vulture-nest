<!--
source_url: https://platform.claude.com/docs/en/agents-and-tools/mcp-connector
requested_url: https://platform.claude.com/docs/en/agents-and-tools/mcp-connector
fetch_date: 2026-05-02T01:27:34.686Z
crawl_job_id: 019deac5-a684-74df-a794-e04a837b4478
source_page_id: 63879e20-e7b4-4188-af1d-091a0a2bb1aa
chunk_ids: 49e650ef-4f37-4a66-bc14-927fd2db825b, dce6d54e-a2ad-4630-99e0-aac3794f676f, e52a5a9f-3093-4471-92d5-6c4426888140, 0d2167f0-5418-4dad-b82e-0cd27ab7b9f5, 6284b7ce-fd29-44d5-b161-04d1eec0c3fa, a8427963-39d4-467b-a7b9-0bff4236b858, a988d8c5-b06d-4757-b402-4b068fe369dc, 40868b11-6a1e-4b9c-ac3c-4be650408205, c4f94423-d32a-41b7-a432-6882dc55c14d, afa59fda-cd83-47fe-973e-caddc119808a, cfc2398d-c645-48ee-8f41-e6406ee357fe, 216ee99f-7d5a-4ec9-bd76-dfcf5bbfe933, 909a5843-226c-4fb5-b0b5-b045ec8d564b, 4abf4205-008f-4f21-9d80-f5250ea4d258, bb64d47f-c95b-4cc7-89b2-9d811a32575f, ccbfc5cd-85fe-4a20-bcb7-6fa2f779b9c1, 1de6a05d-6207-4e5b-aae1-2dac4b812bf5, 188c8a5e-4162-4a9f-b77e-7a2cb056897e, 57076d5b-dd83-4b11-822f-0311dcc85fce, a2a548ea-ac02-4655-a71c-45c539344d5c, d207ba1d-a59f-4fdf-9d5b-a71b547f97bf, cbcebf1d-bf34-4fa0-9974-9498f7492ed8
-->

# MCP connector - Claude API Docs
MCP

MCP connector

Copy page

Claude's Model Context Protocol (MCP) connector feature enables you to connect to remote MCP servers directly from the Messages API without a separate MCP client.

**Current version**: This feature requires the beta header: `"anthropic-beta": "mcp-client-2025-11-20"`

The previous version (`mcp-client-2025-04-04`) is deprecated. See the [deprecated version documentation](https://platform.claude.com/docs/en/agents-and-tools/mcp-connector#deprecated-version-mcp-client-2025-04-04) below.

This feature is **not** eligible for [Zero Data Retention (ZDR)](https://platform.claude.com/docs/en/build-with-claude/api-and-data-retention). Data is retained according to the feature's standard retention policy.

## Key features

- **Direct API integration**: Connect to MCP servers without implementing an MCP client
- **Tool calling support**: Access MCP tools through the Messages API
- **Flexible tool configuration**: Enable all tools, allowlist specific tools, or denylist unwanted tools
- **Per-tool configuration**: Configure individual tools with custom settings
- **OAuth authentication**: Support for OAuth Bearer tokens for authenticated servers
- **Multiple servers**: Connect to multiple MCP servers in a single request

## Limitations

- Of the feature set of the [MCP specification](https://modelcontextprotocol.io/introduction#explore-mcp), only [tool calls](https://modelcontextprotocol.io/docs/concepts/tools) are currently supported.
- The server must be publicly exposed through HTTP (supports both Streamable HTTP and SSE transports). Local STDIO servers cannot be connected directly.
- The MCP connector is currently not supported on Amazon Bedrock and Google Vertex.

## Using the MCP connector in the Messages API

The MCP connector uses two components:

1. **MCP Server Definition** (`mcp_servers` array): Defines server connection details (URL, authentication)
2. **MCP Toolset** (`tools` array): Configures which tools to enable and how to configure them

### Basic example

This example enables all tools from an MCP server with default configuration:

cURLCLIPythonTypeScriptC#GoJavaPHPRuby

```
client = anthropic.Anthropic()

response = client.beta.messages.create(
    model="claude-opus-4-7",
    max_tokens=1000,
    messages=[{"role": "user", "content": "What tools do you have available?"}],
    mcp_servers=[\
        {\
            "type": "url",\
            "url": "https://example-server.modelcontextprotocol.io/sse",\
            "name": "example-mcp",\
            "authorization_token": "YOUR_TOKEN",\
        }\
    ],
    tools=[{"type": "mcp_toolset", "mcp_server_name": "example-mcp"}],
    betas=["mcp-client-2025-11-20"],
)

print(response)
```

## MCP server configuration

Each MCP server in the `mcp_servers` array defines the connection details:

```
{
  "type": "url",
  "url": "https://example-server.modelcontextprotocol.io/sse",
  "name": "example-mcp",
  "authorization_token": "YOUR_TOKEN"
}
```

### Field descriptions

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `type` | string | Yes | Currently only "url" is supported |
| `url` | string | Yes | The URL of the MCP server. Must start with https:// |
| `name` | string | Yes | A unique identifier for this MCP server. Must be referenced by exactly one MCPToolset in the `tools` array. |
| `authorization_token` | string | No | OAuth authorization token if required by the MCP server. See [MCP specification](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization). |

## MCP toolset configuration

The MCPToolset lives in the `tools` array and configures which tools from the MCP server are enabled and how they should be configured.

### Basic structure

```
{
  "type": "mcp_toolset",
  "mcp_server_name": "example-mcp",
  "default_config": {
    "enabled": true,
    "defer_loading": false
  },
  "configs": {
    "specific_tool_name": {
      "enabled": true,
      "defer_loading": true
    }
  }
}
```

### Field descriptions

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `type` | string | Yes | Must be "mcp\_toolset" |
| `mcp_server_name` | string | Yes | Must match a server name defined in the `mcp_servers` array |
| `default_config` | object | No | Default configuration applied to all tools in this set. Individual tool configs in `configs` will override these defaults. |
| `configs` | object | No | Per-tool configuration overrides. Keys are tool names, values are configuration objects. |
| `cache_control` | object | No | Cache breakpoint configuration for this toolset |

### Tool configuration options

Each tool (whether configured in `default_config` or in `configs`) supports the following fields:

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | boolean | `true` | Whether this tool is enabled |
| `defer_loading` | boolean | `false` | If true, tool description is not sent to the model initially. Used with [Tool Search Tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool). |

For the full directory of Anthropic-provided tools and optional properties like `defer_loading`, see the [Tool reference](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-reference). For searching across large tool sets, see [Tool search tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool).

### Configuration merging

Configuration values merge with this precedence (highest to lowest):

1. Tool-specific settings in `configs`
2. Set-level `default_config`
3. System defaults

Example:

```
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-calendar-mcp",
  "default_config": {
    "defer_loading": true
  },
  "configs": {
    "search_events": {
      "enabled": false
    }
  }
}
```

Results in:

- `search_events`: `enabled: false` (from configs), `defer_loading: true` (from default\_config)
- All other tools: `enabled: true` (system default), `defer_loading: true` (from default\_config)

## Common configuration patterns

### Enable all tools with default configuration

The simplest pattern - enable all tools from a server:

```
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-calendar-mcp"
}
```

### Allowlist - Enable only specific tools

Set `enabled: false` as the default, then explicitly enable specific tools:

```
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-calendar-mcp",
  "default_config": {
    "enabled": false
  },
  "configs": {
    "search_events": {
      "enabled": true
    },
    "create_event": {
      "enabled": true
    }
  }
}
```

### Denylist - Disable specific tools

Enable all tools by default, then explicitly disable unwanted tools:

```
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-calendar-mcp",
  "configs": {
    "delete_all_events": {
      "enabled": false
    },
    "share_calendar_publicly": {
      "enabled": false
    }
  }
}
```

### Mixed - Allowlist with per-tool configuration

Combine allowlisting with custom configuration for each tool:

```
{
  "type": "mcp_toolset",
  "mcp_server_name": "google-calendar-mcp",
  "default_config": {
    "enabled": false,
    "defer_loading": true
  },
  "configs": {
    "search_events": {
      "enabled": true,
      "defer_loading": false
    },
    "list_events": {
      "enabled": true
    }
  }
}
```

In this example:

- `search_events` is enabled with `defer_loading: false`
- `list_events` is enabled with `defer_loading: true` (inherited from default\_config)
- All other tools are disabled

## Validation rules

The API enforces these validation rules:

- **Server must exist**: The `mcp_server_name` in an MCPToolset must match a server defined in the `mcp_servers` array
- **Server must be used**: Every MCP server defined in `mcp_servers` must be referenced by exactly one MCPToolset
- **Unique toolset per server**: Each MCP server can only be referenced by one MCPToolset
- **Unknown tool names**: If a tool name in `configs` doesn't exist on the MCP server, a backend warning is logged but no error is returned (MCP servers may have dynamic tool availability)

## Response content types

When Claude uses MCP tools, the response will include two new content block types:

### MCP Tool Use Block

```
{
  "type": "mcp_tool_use",
  "id": "mcptoolu_014Q35RayjACSWkSj4X2yov1",
  "name": "echo",
  "server_name": "example-mcp",
  "input": { "param1": "value1", "param2": "value2" }
}
```

### MCP Tool Result Block

```
{
  "type": "mcp_tool_result",
  "tool_use_id": "mcptoolu_014Q35RayjACSWkSj4X2yov1",
  "is_error": false,
  "content": [\
    {\
      "type": "text",\
      "text": "Hello"\
    }\
  ]
}
```

## Multiple MCP servers

You can connect to multiple MCP servers by including multiple server definitions in `mcp_servers` and a corresponding MCPToolset for each in the `tools` array:

```
{
  "model": "claude-opus-4-7",
  "max_tokens": 1000,
  "messages": [\
    {\
      "role": "user",\
      "content": "Use tools from both mcp-server-1 and mcp-server-2 to complete this task"\
    }\
  ],
  "mcp_servers": [\
    {\
      "type": "url",\
      "url": "https://mcp.example1.com/sse",\
      "name": "mcp-server-1",\
      "authorization_token": "TOKEN1"\
    },\
    {\
      "type": "url",\
      "url": "https://mcp.example2.com/sse",\
      "name": "mcp-server-2",\
      "authorization_token": "TOKEN2"\
    }\
  ],
  "tools": [\
    {\
      "type": "mcp_toolset",\
      "mcp_server_name": "mcp-server-1"\
    },\
    {\
      "type": "mcp_toolset",\
      "mcp_server_name": "mcp-server-2",\
      "default_config": {\
        "defer_loading": true\
      }\
    }\
  ]
}
```

## Authentication

For MCP servers that require OAuth authentication, you'll need to obtain an access token. The MCP connector beta supports passing an `authorization_token` parameter in the MCP server definition.
API consumers are expected to handle the OAuth flow and obtain the access token prior to making the API call, as well as refreshing the token as needed.

### Obtaining an access token for testing

The MCP inspector can guide you through the process of obtaining an access token for testing purposes.

1. Run the inspector with the following command. You need Node.js installed on your machine.







```
npx @modelcontextprotocol/inspector
```

2. In the sidebar on the left, for "Transport type", select either "SSE" or "Streamable HTTP".

3. Enter the URL of the MCP server.

4. In the right area, click on the "Open Auth Settings" button after "Need to configure authentication?".

5. Click "Quick OAuth Flow" and authorize on the OAuth screen.

6. Follow the steps in the "OAuth Flow Progress" section of the inspector and click "Continue" until you reach "Authentication complete".

7. Copy the `access_token` value.

8. Paste it into the `authorization_token` field in your MCP server configuration.


### Using the access token

Once you've obtained an access token using either OAuth flow above, you can use it in your MCP server configuration:

```
{
  "mcp_servers": [\
    {\
      "type": "url",\
      "url": "https://example-server.modelcontextprotocol.io/sse",\
      "name": "authenticated-server",\
      "authorization_token": "YOUR_ACCESS_TOKEN_HERE"\
    }\
  ]
}
```

For detailed explanations of the OAuth flow, refer to the [Authorization section](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization) in the MCP specification.

## Client-side MCP helpers (TypeScript)

If you manage your own MCP client connection (for example, with local stdio servers, MCP prompts, or MCP resources), the TypeScript SDK provides helper functions that convert between MCP types and Claude API types. This eliminates manual conversion code when using the [MCP SDK](https://github.com/modelcontextprotocol/typescript-sdk) alongside the Anthropic SDK.

These helpers are currently available in the TypeScript SDK only.

Use the [`mcp_servers` API parameter](https://platform.claude.com/docs/en/agents-and-tools/mcp-connector#using-the-mcp-connector-in-the-messages-api) when you have remote servers accessible via URL and only need tool support. Use the client-side helpers when you need local servers, prompts, resources, or more control over the connection with the base SDK.

### Installation

Install both the Anthropic SDK and the MCP SDK:

```
npm install @anthropic-ai/sdk @modelcontextprotocol/sdk
```

### Available helpers

Import the helpers from the beta namespace:

```
import {
  mcpTools,
  mcpMessages,
  mcpResourceToContent,
  mcpResourceToFile
} from "@anthropic-ai/sdk/helpers/beta/mcp";
```

| Helper | Description |
| --- | --- |
| `mcpTools(tools, mcpClient)` | Converts MCP tools to Claude API tools for use with `client.beta.messages.toolRunner()` |
| `mcpMessages(messages)` | Converts MCP prompt messages to Claude API message format |
| `mcpResourceToContent(resource)` | Converts an MCP resource to a Claude API content block |
| `mcpResourceToFile(resource)` | Converts an MCP resource to a file object for upload |

### Use MCP tools

Convert MCP tools for use with the SDK's [tool runner](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner), which handles tool execution automatically:

```
import { mcpTools } from "@anthropic-ai/sdk/helpers/beta/mcp";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const anthropic = new Anthropic();

// Connect to an MCP server
const transport = new StdioClientTransport({ command: "mcp-server", args: [] });
const mcpClient = new Client({ name: "my-client", version: "1.0.0" });
await mcpClient.connect(transport);

// List tools and convert them for the Claude API
const { tools } = await mcpClient.listTools();
const runner = await anthropic.beta.messages.toolRunner({
  model: "claude-opus-4-7",
  max_tokens: 1024,
  messages: [{ role: "user", content: "What tools do you have available?" }],
  tools: mcpTools(tools, mcpClient)
});
```

### Use MCP prompts

Convert MCP prompt messages into Claude API message format:

```
import { mcpMessages } from "@anthropic-ai/sdk/helpers/beta/mcp";

const { messages } = await mcpClient.getPrompt({ name: "my-prompt" });
const response = await anthropic.beta.messages.create({
  model: "claude-opus-4-7",
  max_tokens: 1024,
  messages: mcpMessages(messages)
});
```

### Use MCP resources

Convert MCP resources into content blocks to include in messages, or into file objects for upload:

```
import { mcpResourceToContent, mcpResourceToFile } from "@anthropic-ai/sdk/helpers/beta/mcp";

// As a content block in a message
const resource = await mcpClient.readResource({ uri: "file:///path/to/doc.txt" });
await anthropic.beta.messages.create({
  model: "claude-opus-4-7",
  max_tokens: 1024,
  messages: [\
    {\
      role: "user",\
      content: [\
        mcpResourceToContent(resource),\
        { type: "text", text: "Summarize this document" }\
      ]\
    }\
  ]
});

// As a file upload
const fileResource = await mcpClient.readResource({ uri: "file:///path/to/data.json" });
await anthropic.beta.files.upload({ file: mcpResourceToFile(fileResource) });
```

### Error handling

The conversion functions throw `UnsupportedMCPValueError` if an MCP value isn't supported by the Claude API. This can happen with unsupported content types, MIME types, or non-HTTP resource links.

## Data retention

The MCP Connector is not covered by ZDR arrangements. Data exchanged with MCP servers, including tool definitions and execution results, is retained according to Anthropic's standard data retention policy.

For ZDR eligibility across all features, see [API and data retention](https://platform.claude.com/docs/en/build-with-claude/api-and-data-retention).

## Migration guide

If you're using the deprecated `mcp-client-2025-04-04` beta header, follow this guide to migrate to the new version.

### Key changes

1. **New beta header**: Change from `mcp-client-2025-04-04` to `mcp-client-2025-11-20`
2. **Tool configuration moved**: Tool configuration now lives in the `tools` array as MCPToolset objects, not in the MCP server definition
3. **More flexible configuration**: New pattern supports allowlisting, denylisting, and per-tool configuration

### Migration steps

**Before (deprecated):**

```
{
  "model": "claude-opus-4-7",
  "max_tokens": 1000,
  "messages": [\
    // ...\
  ],
  "mcp_servers": [\
    {\
      "type": "url",\
      "url": "https://mcp.example.com/sse",\
      "name": "example-mcp",\
      "authorization_token": "YOUR_TOKEN",\
      "tool_configuration": {\
        "enabled": true,\
        "allowed_tools": ["tool1", "tool2"]\
      }\
    }\
  ]
}
```

**After (current):**

```
{
  "model": "claude-opus-4-7",
  "max_tokens": 1000,
  "messages": [\
    // ...\
  ],
  "mcp_servers": [\
    {\
      "type": "url",\
      "url": "https://mcp.example.com/sse",\
      "name": "example-mcp",\
      "authorization_token": "YOUR_TOKEN"\
    }\
  ],
  "tools": [\
    {\
      "type": "mcp_toolset",\
      "mcp_server_name": "example-mcp",\
      "default_config": {\
        "enabled": false\
      },\
      "configs": {\
        "tool1": {\
          "enabled": true\
        },\
        "tool2": {\
          "enabled": true\
        }\
      }\
    }\
  ]
}
```

### Common migration patterns

| Old pattern | New pattern |
| --- | --- |
| No `tool_configuration` (all tools enabled) | MCPToolset with no `default_config` or `configs` |
| `tool_configuration.enabled: false` | MCPToolset with `default_config.enabled: false` |
| `tool_configuration.allowed_tools: [...]` | MCPToolset with `default_config.enabled: false` and specific tools enabled in `configs` |

## Deprecated version: mcp-client-2025-04-04

This version is deprecated. Migrate to `mcp-client-2025-11-20` using the [migration guide](https://platform.claude.com/docs/en/agents-and-tools/mcp-connector#migration-guide) above.

The previous version of the MCP connector included tool configuration directly in the MCP server definition:

```
{
  "mcp_servers": [\
    {\
      "type": "url",\
      "url": "https://example-server.modelcontextprotocol.io/sse",\
      "name": "example-mcp",\
      "authorization_token": "YOUR_TOKEN",\
      "tool_configuration": {\
        "enabled": true,\
        "allowed_tools": ["example_tool_1", "example_tool_2"]\
      }\
    }\
  ]
}
```

### Deprecated field descriptions

| Property | Type | Description |
| --- | --- | --- |
| `tool_configuration` | object | **Deprecated**: Use MCPToolset in the `tools` array instead |
| `tool_configuration.enabled` | boolean | **Deprecated**: Use `default_config.enabled` in MCPToolset |
| `tool_configuration.allowed_tools` | array | **Deprecated**: Use allowlist pattern with `configs` in MCPToolset |

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
