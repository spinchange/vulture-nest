---
title: Anthropic Managed Agents Model
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-managed-agents
  - anthropic-sessions-api
source: "[[lit-anthropic-advanced-capabilities]]"
---

# Anthropic Managed Agents Model

**Claude Managed Agents** is Anthropic's hosted agent execution surface. Unlike the Messages API where the caller manages conversation state and tool execution, Managed Agents provisions containers, runs the agent loop server-side, and streams real-time events back to the caller.

Requires beta header: `managed-agents-2026-04-01` (SDK sets this automatically).

## Three-Layer Architecture

| Resource | What it is | Lifecycle |
|---|---|---|
| **Agent** | Model + system prompt + tools + MCP servers | Long-lived, versioned config |
| **Environment** | Container template (packages, networking) | Reusable, parameterized |
| **Session** | Running agent instance within an environment | Tied to a task; maintains history |

Agent and environment are separate resources created once and reused. Sessions are created per task.

## Agent Configuration

```bash
ant beta:agents create \
  --name "Coding Assistant" \
  --model '{id: claude-opus-4-7}' \
  --system "You are a helpful coding assistant." \
  --tool '{type: agent_toolset_20260401}'
```

`agent_toolset_20260401` enables the full pre-built toolset: bash, file operations, web search, and more. Agents are versioned — sessions can pin to a specific version or always use latest.

## Session Lifecycle

Sessions are state machines:

| Status | Meaning |
|---|---|
| `idle` | Waiting for input (starts here) |
| `running` | Actively executing |
| `rescheduling` | Transient error; retrying automatically |
| `terminated` | Unrecoverable error; session is done |

Creating a session provisions the environment but does not start execution. Execution begins when a user event is sent.

```python
session = client.beta.sessions.create(
    agent=agent.id,
    environment_id=environment.id,
)
```

## Event-Driven Interaction

The caller sends events to the session and receives events from the agent via SSE streaming:

```python
with client.beta.sessions.events.stream(session.id) as stream:
    client.beta.sessions.events.send(
        session.id,
        events=[{
            "type": "user.message",
            "content": [{"type": "text", "text": "Generate the Fibonacci sequence"}],
        }],
    )
    for event in stream:
        match event.type:
            case "agent.message":
                for block in event.content:
                    print(block.text, end="")
            case "agent.tool_use":
                print(f"\n[Tool: {event.name}]")
            case "session.status_idle":
                print("\nAgent finished.")
                break
```

Opening the stream before sending the user event avoids a race condition where the agent's response starts before the stream is established.

## MCP Authentication via Vaults

When an agent uses MCP tools that require OAuth, pass `vault_ids` at session creation. Anthropic manages token refresh.

```python
session = client.beta.sessions.create(
    agent=agent.id,
    environment_id=environment.id,
    vault_ids=[vault.id],
)
```

## Architectural Position

Managed Agents sits above the Messages API in the abstraction stack. The tradeoff: simpler deployment (no client-side agent loop, no container management) at the cost of less control (execution happens server-side, less flexibility for custom tool logic, human-in-the-loop flows need event-level support).

For workloads that need full control over tool execution, use the Messages API with [[anthropic-tool-use]] or [[anthropic-tool-runner-sdk]] directly.

## See also

- [[anthropic-messages-api]]
- [[anthropic-tool-use]]
- [[anthropic-tool-runner-sdk]]
- [[anthropic-mcp-connector]]
- [[pattern-human-in-the-loop]]
- [[lit-anthropic-advanced-capabilities]]
