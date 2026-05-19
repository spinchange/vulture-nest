---
title: OpenAI Agents SDK
author: claude-sonnet-4-6
date: '2026-05-01'
status: active
aliases:
  - agents-sdk
  - openai-agents
  - production-agents
type: permanent
provenance:
  source_page_ids:
    - 3a9e720e-9d2c-4340-84bb-898ed4148d7e  # Handoffs
    - 8169608c-5ceb-4b43-9e60-5042988705df  # Agents
    - 52f5b1ff-5079-4f4f-9fac-a5b1435d3aa0  # Running agents
    - 40bb4262-f89a-4768-84b5-2cc8fcf35ae8  # MCP
    - d2557d19-837a-4408-9b25-8bd11f2c03a0  # Guardrails
    - 18b578a6-5671-43b2-bcb3-2a4411a443cd  # Tracing
  chunk_ids:
    - 19af9586-eb71-4c73-a0c9-5b983be0ddb2
    - 4622eb7a-eccc-48ff-939f-a619d2451b96
    - 3e4f66c4-d51f-4c08-a9fc-615e23868c12
    - 63bf1601-6680-45a9-8093-5078e9378648
    - 9de911ab-0fc4-4ac9-9e86-f964eb27d98a
    - 786abf89-a710-4f3c-a479-39813adf4db8
    - f31a9b90-0f0a-45cb-b6c2-6f53d6201234
    - f7607f8d-0b0f-439a-bc63-42a561510f87
    - fc6d5c4f-1585-4d2d-b23d-89c651beb287
    - 36cc67ec-b206-4a1c-b08f-20161863e569
    - d0f95d70-f0f0-400e-8ecb-6eaa341e3bee
    - 5e6373fe-e453-4100-9575-097d64538e7d
    - 5051110f-3ad0-4201-8dd0-65844c045a17
    - c093fc06-7d7e-44b9-8328-22fa0a74cca2
  retrieved_at: '2026-05-01'
  acting_agent: claude-sonnet-4-6
---

# OpenAI Agents SDK

The **OpenAI Agents SDK** is the production-grade Python framework for building, running, and scaling AI agents. It supersedes the experimental [[openai-swarm]] with a focus on durability, safety, and multi-agent orchestration. The developer retains explicit ownership of orchestration, tool execution, and state management.

## Running Agents

The `Runner` class is the primary entry point for agent execution. Three run modes are available:

- **`Runner.run()`** — async, returns a `RunResult`
- **`Runner.run_sync()`** — synchronous wrapper
- **`Runner.run_streamed()`** — returns a `RunResultStreaming` for incremental output

Input can be a plain string (treated as a user message), a list of OpenAI Responses API items, or a `RunState` object to resume an interrupted run.

### The Agent Loop

When `Runner.run()` is called, it executes a loop:
1. Call the current agent's LLM with the accumulated conversation
2. Execute any tool calls returned by the LLM
3. If a handoff tool is invoked, switch the active agent
4. Repeat until the LLM returns a final output (no more tool calls)

## Agent Definition

An `Agent` is defined with:
- **`instructions`** — system prompt, either a static string or a dynamic function `(RunContextWrapper, Agent) -> str` that allows per-request context injection
- **`tools`** — list of callable functions the LLM can invoke
- **`handoffs`** — list of `Agent` instances or `Handoff` objects the agent can delegate to
- **`model`** — the underlying LLM; supports multiple providers

Dynamic instructions pattern:
```python
def dynamic_instructions(context: RunContextWrapper[UserContext], agent: Agent) -> str:
    return f"The user's name is {context.context.name}."
```

## Handoffs

Handoffs allow an agent to delegate the conversation to a specialist sub-agent. When a handoff is invoked, the delegated agent receives the full conversation history and becomes the active agent. Handoffs are represented as tools on the agent — the LLM invokes a handoff exactly as it invokes any other tool.

### Two Multi-Agent Patterns

**Manager (agents as tools):** A central orchestrator invokes specialist agents as tools and retains control of the conversation at all times. The manager synthesizes results.

**Peer handoffs:** Agents pass control laterally to a specialist that takes over the reply. The new agent drives the conversation until it completes or hands off again.

### Customizing Handoffs

The `handoff()` function provides fine-grained control:
- `agent` — target agent
- `tool_name_override` — custom tool name (default: `transfer_to_<agent_name>`)
- `on_handoff` — callback invoked when the handoff fires

Prompt discipline matters: include the `RECOMMENDED_PROMPT_PREFIX` from `agents.extensions.handoff_prompt` to ensure the LLM understands handoff semantics.

## Guardrails

Guardrails attach to agents and run validations at defined workflow boundaries:

| Type | When it runs |
|:---|:---|
| **Input guardrails** | First agent in the chain only |
| **Output guardrails** | Final agent producing the terminal output |
| **Tool guardrails** | Every invocation of a custom function-tool |

Input guardrails run in three steps: receive the same input as the agent → execute the guardrail function → return a `GuardrailFunctionOutput`. A `tripwire` flag signals immediate abort. This design lets you use a cheap/fast model as a safety filter before the expensive primary model runs.

## Lifecycle Hooks

Two hook scopes give observability into agent execution:
- **`RunHooks`** — module-level, fires for any agent in the run
- **`AgentHooks`** — agent-level, fires only for that specific agent

Hooks support pre/post-tool, pre/post-handoff, and agent-start/end events. Primary use cases: logging, pre-fetching, usage recording.

## MCP Integration

The SDK provides native support for the [[mcp-architecture|Model Context Protocol]]. MCP standardizes how applications expose tools and context to LLMs — "MCP is like USB-C for AI." Agents connect to `MCPServer` instances to access any MCP-compliant tool or resource, enabling a wide ecosystem of pre-built integrations. See [[mcp-moc]].

## Tracing

Built-in tracing records agent runs as structured traces. Multiple `Runner.run()` calls can be grouped into a single trace using the `trace()` context manager:

```python
with trace("Workflow name"):
    result1 = await Runner.run(agent, "...")
    result2 = await Runner.run(agent, "...")
```

Traces are visualizable for debugging agentic flows.

## Resumable State

Interrupted runs (e.g., human-in-the-loop pauses) are resumed by passing a `RunState` object back to `Runner.run()`. This preserves the full conversation and tool-execution history across the interruption boundary.

## Comparison: Swarm vs. Agents SDK

| Feature | [[openai-swarm\|Swarm]] | Agents SDK |
|:---|:---|:---|
| **Status** | Experimental / Educational | Production-Ready |
| **State** | Stateless (caller manages) | Resumable via `RunState` |
| **Orchestration** | Lightweight function-based | `Runner` loop + typed hooks |
| **Safety** | Minimal | Input/output/tool guardrails |
| **Observability** | None | Built-in tracing |
| **MCP** | No | Native |

---
*Source: [[lit-openai-agents-sdk]]*

## See Also
- [[openai-symphony]]
- [[hermes-vs-openai-symphony]]
