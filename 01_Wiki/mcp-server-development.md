---
title: [[mcp-moc|MCP]] Development
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-sdk, mcp-server-build, mcp-best-practices]
---
# MCP Server Development

Developing an **[[mcp-architecture|MCP Server]]** involves exposing tools, resources, and prompts via a standardized transport (Stdio or HTTP).

## Supported SDKs & Implementation
MCP provides official SDKs to simplify development. The **[[mcp-sdks|SDKs]]** handle JSON-RPC serialization and lifecycle management.

### 1. [[python]] (FastMCP)
The `FastMCP` class is the recommended high-level API for Python.
*   **Initialization**: `mcp = FastMCP("server-name")`
*   **Tools**: Uses `@mcp.tool()` decorators. Docstrings and type hints are automatically converted to JSON Schema.
*   **Running**: `mcp.run(transport="stdio")`

### 2. [[typescript|TypeScript]] / Node.js
The TypeScript SDK provides the most fine-grained control for web and desktop hosts.
*   **Initialization**: `const server = new McpServer({ name: "server", version: "1.0.0" });`
*   **Tools**: Registered via `server.registerTool(name, schema, handler)`. Uses **Zod** for schema definition.
*   **Running**: `const transport = new StdioServerTransport(); await server.connect(transport);`

### 3. Java (Spring AI)
Ideal for enterprise integration and performance-critical systems.
*   **Mechanism**: Uses `@Tool` and `@ToolParam` annotations on Spring `@Service` classes.
*   **Auto-Registration**: The `spring-ai-starter-mcp-server` automatically discovers and registers beans as tools.

## Critical Lifecycle Rules
### The Stdio Logging Hazard
When using **[[mcp-transport|Stdio transport]]**, the server communicates via `stdout`. 
*   **❌ NEVER** log to `stdout` (e.g., `print()`, `console.log()`, `System.out.println()`). This corrupts the JSON-RPC stream.
*   **✅ ALWAYS** log to `stderr` (e.g., `sys.stderr`, `console.error()`).

## Server Building Workflow
1.  **Define Capabilities**: Decide which [[mcp-server-features|Tools, Resources, and Prompts]] to expose.
2.  **Schema Design**: Define input parameters using JSON Schema or language-native primitives (Zod, Type Hints).
3.  **Implement Logic**: Write the underlying service logic (e.g., API calls, DB queries).
4.  **Connect Transport**: Choose between `StdioServerTransport` (local) or `SSEServerTransport` (remote).
5.  **Test**: Use the **[[mcp-inspector|MCP Inspector]]** to verify schemas and results.

## Security & Trust
*   **User Consent**: Servers should assume that sensitive tool calls (Write/Delete) will trigger a "Human-in-the-loop" approval dialog in the host.
*   **Validation**: Always validate inputs on the server side; do not trust the LLM's adherence to the schema.

---
## Related
* [[mcp-best-practices]]
* [[mcp-debugging]]
* [[rust-mcp-patterns]]
* [[mcp-example-servers]]
- [[csharp-mcp-sdk]]

- [[lit-mcp-architecture]]