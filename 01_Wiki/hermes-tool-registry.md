---
title: Hermes Tool Registry
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-tool-surface
  - hermes-mcp-tool-integration
  - hermes-dynamic-tools
type: permanent
---
# Hermes Tool Registry

[[hermes-tool-registry]] describes how Hermes turns built-in tools, dynamic schemas, toolsets, and MCP-discovered remote tools into one callable tool surface. The registry is the bridge between "tools implemented in Python modules" and "tools exposed to the model as schemas."

## Core idea

Hermes does not maintain one giant handwritten list of callable tools in the agent loop. Instead, it uses a central registry that collects:
- tool name
- toolset membership
- JSON schema
- execution handler
- availability checks
- optional dynamic schema overrides
- per-tool output budget metadata

That gives Hermes a single control point for both introspection and dispatch.

## Self-registration by module import

Built-in tools register themselves at module import time with `registry.register(...)`.

`tools/registry.py` includes an AST-based discovery pass that looks for top-level `registry.register(...)` calls before importing modules. This is an important design choice because Hermes can discover self-registering tool modules without hardcoding every file into a central manifest.

The registry also tracks a generation counter, so higher-level caches can invalidate when the registered tool surface changes.

## Toolsets are the policy layer above tools

`toolsets.py` defines named groups such as `web`, `browser`, `terminal`, `skills`, `delegation`, and many others. Some are simple lists; others compose other toolsets.

So the architecture has two layers:
- **registry** — what tools exist and how to call them
- **toolsets** — which subsets of those tools are exposed in a given session

That separation lets Hermes express capability policies without duplicating schemas.

## Availability is dynamic

A registered tool is not automatically exposed. `registry.get_definitions()` only returns tools whose `check_fn()` passes.

Hermes caches those availability probes with a short TTL because many checks hit real external state such as:
- installed binaries
- Docker or browser dependencies
- environment variables
- remote capability flags

This means the tool surface in prompt is a **live projection of the environment**, not a static catalog.

## model_tools.py turns registry state into model-facing schemas

`model_tools.get_tool_definitions()` resolves enabled and disabled toolsets, asks the registry for eligible schemas, then performs compatibility cleanup such as:
- memoizing tool-definition lists for hot call sites
- rebuilding dynamic schemas like `execute_code`
- removing schema references to tools that are not actually available
- sanitizing schemas for backends with stricter JSON-schema parsers

So the registry alone is not the whole story. There is a second translation layer that adapts registry state into a prompt-safe and backend-safe tool contract.

## MCP extends the registry rather than bypassing it

`tools/mcp_tool.py` shows how Hermes integrates external MCP servers.

Key design features:
- MCP servers can connect by stdio, Streamable HTTP, or SSE
- each server lives on a dedicated background asyncio loop/thread architecture
- discovered MCP tools are registered into the same central registry as built-ins
- dynamic notifications such as `tools/list_changed` can trigger registry refresh
- stdio MCP stderr is redirected into a per-profile log file instead of corrupting the TUI

This is architecturally elegant because MCP does not create a second-class tool world. Remote tools become ordinary registry entries with toolset membership and schemas like everything else.

## Why the registry matters for MCP

Without a registry, MCP integration often becomes ad hoc plumbing. In Hermes, the registry gives MCP four important benefits:
- uniform dispatch
- shared toolset filtering
- shared schema sanitization
- shared cache invalidation through the generation counter

That is what lets built-ins, plugins, and MCP servers coexist in one model-visible surface.

## Architectural consequence

[[hermes-tool-registry]] is the layer that makes Hermes's tool calling scalable. It separates discovery, policy, availability, schema shaping, and execution, while still allowing dynamic MCP servers to join the same surface. The result is a tool architecture that is extensible without becoming ungovernable.

## See Also
- [[hermes-agent]]
- [[hermes-gateway]]
- [[hermes-provider-abstraction]]
- [[hermes-prompt-assembly]]
- [[mcp-moc]]
- [[mcp-best-practices]]
- [[mcp-agent-skills]]
- [[ps-tool-registry-generator]]
- [[spec-hermes-agent-loop]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\tools\registry.py`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\model_tools.py`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\toolsets.py`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\tools\mcp_tool.py`
