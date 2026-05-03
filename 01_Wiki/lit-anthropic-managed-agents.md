---
title: "Literature: Anthropic Managed Agents (Batch 2, Sub-batch D)"
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: literature
aliases:
  - lit-anthropic-managed-agents
  - anthropic-managed-agents-lit
source: "00_Raw/anthropic/ (sub-batch D: managed-agents-quickstart, managed-agents-agent-setup, managed-agents-sessions, managed-agents-environments, managed-agents-tools, managed-agents-events-streaming)"
---

# Literature: Anthropic Managed Agents (Batch 2, Sub-batch D)

Synthesis of six Anthropic documentation pages covering the Managed Agents product: quickstart, agent setup, sessions, environments, tools, and events/streaming. Crawled 2026-05-01 to 2026-05-02 as part of Batch 2 ingestion.

---

## What Managed Agents Is

Claude Managed Agents is a separate product surface from the Messages API. It is not a Messages API tool loop. It provides managed execution infrastructure — containers, persistent sessions, event streaming, and versioned agent configurations — for running Claude as a long-horizon autonomous agent.

**Beta header:** `managed-agents-2026-04-01` (required for all Managed Agents endpoints: `/v1/agents`, `/v1/sessions`, `/v1/environments`). The SDK sets this header automatically.

**Invariant:** Managed Agents is a distinct product from the Messages API tool loop. Do not conflate the two. The Messages API tool loop requires the application to drive the agentic loop; Managed Agents provides server-managed execution and container infrastructure.

---

## Core Concepts

| Concept | Description |
|---|---|
| **Agent** | Versioned configuration: model, system prompt, tools, MCP servers, skills, callable agents |
| **Environment** | Container template: packages, networking. Created once; referenced by multiple sessions |
| **Session** | A running agent instance within an environment; maintains conversation history |
| **Events** | Bidirectional: user messages sent in; agent messages, tool-use notifications, status updates streamed out |

The lifecycle: create an agent → create an environment → create a session (combining agent + environment) → send events → stream results.

---

## Agents

Agents are reusable, versioned configurations. Create once; reference by ID across many sessions.

**Configuration fields:**
- `name` (required), `model` (required; Claude 4.5+ supported), `system` (system prompt), `tools`, `mcp_servers`, `skills`, `callable_agents`, `description`, `metadata`

**`agent_toolset_20260401`** is the shorthand to enable the full built-in tool set. Individual tools within it can be disabled via `configs`:

```json
{
  "type": "agent_toolset_20260401",
  "configs": [
    { "name": "web_fetch", "enabled": false }
  ]
}
```

To enable only specific tools, set `default_config.enabled: false` and selectively enable by name.

**Versioning semantics:**
- Every update generates a new version (`version` starts at 1, increments with each update).
- Passing the current `version` in an update call ensures you're updating from a known state.
- Scalar fields are replaced; array fields are fully replaced; metadata is merged at key level.
- No-op updates do not create a new version.
- Archived agents are read-only; new sessions cannot reference them; existing sessions continue.

**Fast mode:** On Claude Opus 4.6, pass `{"id": "claude-opus-4-6", "speed": "fast"}` as the `model` object.

---

## Environments

Environments define the container configuration where agents run. Create once; reference by ID in sessions. Multiple sessions can share an environment but each session gets its own isolated container instance.

**Configuration:**
- `packages`: Pre-installs packages (apt, cargo, gem, go, npm, pip). Packages are cached across sessions sharing the same environment.
- `networking`: Controls outbound access.
  - `unrestricted`: Full outbound (minus safety blocklist). Default.
  - `limited`: Restricts to `allowed_hosts` list, with opt-in flags for `allow_package_managers` and `allow_mcp_servers`.

**Security guidance:** Use `limited` networking in production with an explicit `allowed_hosts` allowlist. Follow least privilege. The `web_search` and `web_fetch` tools' domain filtering is separate from the container networking policy.

Environments are not versioned. If you need to track environment state, log changes externally.

---

## Sessions

A session is a running agent instance. Creating a session provisions the container but does not start execution — work begins when you send a user event.

**Creating a session:**
```python
session = client.beta.sessions.create(
    agent=agent.id,           # latest version
    environment_id=environment.id,
)
```

To pin to a specific agent version: pass an object `{"type": "agent", "id": agent_id, "version": 1}`.

**Session statuses:**
- `idle` — waiting for input (sessions start here)
- `running` — actively executing
- `rescheduling` — transient error, retrying automatically
- `terminated` — unrecoverable error

**MCP authentication:** Pass `vault_ids` at session creation to provide OAuth credentials for MCP tools. Anthropic manages token refresh.

**Session lifecycle:**
- Archive: makes session read-only; prevents new events; history preserved.
- Delete: permanently removes record, events, and container. Cannot delete a `running` session (send interrupt event first). Files, memory stores, environments, and agents are independent resources and are not deleted.

---

## Tools

Built-in agent tools (enabled via `agent_toolset_20260401`):

| Tool | Name | Description |
|---|---|---|
| Bash | `bash` | Execute bash commands |
| Read | `read` | Read file from filesystem |
| Write | `write` | Write file to filesystem |
| Edit | `edit` | String replacement in file |
| Glob | `glob` | File pattern matching |
| Grep | `grep` | Text search with regex |
| Web fetch | `web_fetch` | Fetch URL content |
| Web search | `web_search` | Search the web |

**Custom tools:** Define via `type: "custom"` with `name`, `description`, and `input_schema`. Claude emits a tool-call request; the application executes the tool and sends results back as an event. Custom tools in Managed Agents are analogous to user-defined client tools in the Messages API.

**Custom tool best practices:**
- Provide extremely detailed descriptions (3–4+ sentences, including when not to use the tool).
- Consolidate related operations into fewer tools with an `action` parameter.
- Use meaningful namespacing in tool names (`db_query`, `storage_read`).
- Return high-signal responses: semantic identifiers, not opaque references; only the fields Claude needs.

---

## Events and Streaming

Sessions are event-driven. The application opens a stream, sends user events, and receives agent events.

**Opening the stream:**
```python
with client.beta.sessions.events.stream(session.id) as stream:
    client.beta.sessions.events.send(
        session.id,
        events=[{"type": "user.message", "content": [{"type": "text", "text": "..."}]}],
    )
    for event in stream:
        match event.type:
            case "agent.message":
                print(event.content[0].text, end="")
            case "agent.tool_use":
                print(f"\n[Using tool: {event.name}]")
            case "session.status_idle":
                print("\nAgent finished.")
                break
```

**Key event types:**
- `user.message` — send user input
- `agent.message` — agent text response
- `agent.tool_use` — agent invoked a tool (informational)
- `session.status_idle` — agent has finished current task; ready for more input
- `session.status_terminated` — unrecoverable error

**What happens on `user.message`:**
1. Container is provisioned (if not already running).
2. Agent loop runs: Claude decides tool usage → tools execute in container → results flow back.
3. Events stream in real-time as the agent works.
4. `session.status_idle` emitted when the agent has nothing more to do.

**Handling custom tool calls:** When the agent invokes a custom tool, the application receives an event with the tool name and inputs. The application executes the tool and sends a `tool_result` event back. Claude continues the task from the result.

---

## Relationship to the Messages API

| Dimension | Messages API (tool loop) | Managed Agents |
|---|---|---|
| Who drives the loop | Application | Anthropic infrastructure |
| Execution environment | Application's infrastructure | Managed containers |
| State persistence | Application manages conversation history | Session maintains conversation history |
| Tool execution | Application executes client tools | Built-in tools execute in container; custom tools sent back to application |
| Versioning | None (per-request) | Versioned agents |
| Beta header | None required for base API | `managed-agents-2026-04-01` always required |

---

## Stable Patterns vs. Operational Details

**Stable (architecture):**
- Agent/Environment/Session as the three-resource model
- Events as the bidirectional communication primitive
- Custom tools as application-executed extension points
- `agent_toolset_20260401` as the managed tool surface identifier
- Session as a state machine progressing through idle/running/rescheduling/terminated
- Managed Agents ≠ Messages API tool loop

**Operational (likely to drift):**
- Beta header date (`managed-agents-2026-04-01`)
- Specific toolset version (`agent_toolset_20260401`)
- Available built-in tools (web_search, web_fetch etc. may be updated)
- Multi-agent orchestration (`callable_agents`) is a research preview; API shape may change
- Skills feature maturity

---

## Notes for Synthesis

This sub-batch is the primary source for [[anthropic-managed-agents-model]]. The existing permanent note from the advanced-capabilities batch covers the architectural model. This sub-batch provides detailed coverage of sessions, environments, and events that weren't available in the first batch. Key additions: environment networking configuration, session status machine, `session.status_idle` event, vault-based MCP authentication, and the multi-agent `callable_agents` research preview.
