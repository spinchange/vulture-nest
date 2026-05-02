---
title: "Literature: MCP Advanced Patterns & Skills"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/mcp/Build with Agent Skills.md", "00_Raw/mcp/Client Best Practices.md"]
aliases: ["MCP Host Patterns", "Progressive Discovery", "Programmatic Tool Calling", "MCP Agent Skills"]
---

# Literature: MCP Advanced Patterns & Skills

This literature note synthesizes two distinct MCP-adjacent documents from May 2026:
- `Client Best Practices`, which discusses host-side runtime patterns for scaling tool-heavy MCP clients.
- `Build with Agent Skills`, which describes a reference skill/plugin workflow for scaffolding MCP servers.

These documents operate at different layers. Progressive discovery and programmatic tool calling are host runtime patterns. Agent skills are development-time scaffolding for coding assistants, not part of the core MCP wire protocol.

## Source Context
- **Runtime patterns source**: `Client Best Practices`
- **Development workflow source**: `Build with Agent Skills`
- **Scope caveat**: The deployment recommendations and skill names below describe the `mcp-server-dev` reference plugin discussed in the source material. They should not be read as protocol-level MCP requirements.

## Scaling Host Applications (Client Best Practices)
As tool counts grow, naive host behavior degrades: injecting every tool definition into the model wastes context, while routing every intermediate tool result back through the model increases token cost and latency. The source presents two mitigation patterns.

### 1. Progressive Tool Discovery
- **Pattern**: Delay loading full tool definitions into model context until needed.
- **Layers**:
    1.  **Catalog**: Model calls a lightweight `search_tools` meta-tool.
    2.  **Inspect**: Model fetches the full schema for a specific candidate tool.
    3.  **Execute**: Model invokes the tool.
- **Dynamic Management**: The same idea can extend to entire servers: keep a registry of available servers, connect only when relevant, and disconnect when context should be freed.
- **When to use it**: The source recommends switching once tool definitions consume a meaningful share of the context window rather than using progressive discovery unconditionally for every host.
- **Operational caveat**: This pattern is not free. Search quality, schema-inspection cost, cache invalidation, and prompt-caching behavior all affect whether the host actually benefits.

### 2. Programmatic Tool Calling (Code Mode)
- **Pattern**: Instead of direct one-tool-per-turn invocation, the model writes code that calls multiple tools through host-generated stubs; the client executes that script in a sandbox.
- **Primary benefit**: Intermediate results can stay inside the sandbox rather than flowing through the model context between every step.
- **Tradeoff**: This can reduce token churn for chained work (for example, read -> transform -> write), but it also introduces sandbox overhead, debugging complexity, and a larger execution-security surface.
- **Infrastructure**: Requires a sandboxed runtime plus a host-brokered API that maps sandbox calls back to MCP `tools/call` operations.
- **Security implication**: The source treats per-call authorization, resource limits, network isolation, and output filtering as mandatory concerns, not optional hardening.

## Development Scaffolding with Agent Skills
`Build with Agent Skills` is not describing a runtime MCP pattern. It is describing a skill-driven development workflow for coding assistants building MCP servers.

The source defines **agent skills** as portable instruction sets (`SKILL.md` plus references) that provide domain-specific guidance to coding assistants. In this note, that definition should be read as the vocabulary of the source document, not as an MCP specification term.

### Official MCP Skills (`mcp-server-dev`)
- **`build-mcp-server`**: Entry point. Interrogates the use case, selects a deployment model, and routes toward specialized follow-on skills.
- **`build-mcp-app`**: Used when the server needs interactive widgets rendered in chat.
- **`build-mcpb`**: Used when packaging a local stdio server plus its runtime as an MCP bundle.

### Deployment Path Selection
According to the source, the `mcp-server-dev` skill recommends one of four reference paths after its discovery phase:
1.  **Remote (Streamable HTTP)**: Default path for cloud APIs and hosted deployments.
2.  **MCP Apps**: Use when the server needs richer interactive widgets than flat elicitation forms.
3.  **MCP Bundles (MCPB)**: Use when local-machine access is required and the server should ship with its runtime.
4.  **Local (stdio)**: Keep available for prototyping, with an upgrade path to MCPB when distribution matters.

These four paths come from the referenced skill workflow, not from the MCP protocol as a canonical deployment taxonomy.

## Synthesis
Taken together, the two sources suggest a separation of responsibilities:
- **Host runtime optimization**: progressive discovery and programmatic tool calling help clients scale across many tools and servers.
- **Developer workflow guidance**: skill bundles help coding assistants choose a build path and scaffold an MCP server that fits the use case.

The important boundary is that the former changes how an MCP host operates at runtime, while the latter changes how an agent is instructed during server development.

---
## See Also
- [[mcp-moc]]
- [[mcp-agent-skills]]
- [[mcp-best-practices]]
- [[lit-mcp-architecture]]
- [[lit-mcp-server-development]]
- [[lit-mcp-client-development]]
- [[pattern-agent-as-tool]]
