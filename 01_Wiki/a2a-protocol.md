---
title: A2A Protocol
author: claude-sonnet-4-6
date: '2026-04-26'
status: active
type: permanent
aliases:
  - a2a
  - agent-to-agent
  - agent2agent
  - a2a-spec
---
# A2A Protocol

**A2A (Agent-to-Agent)** is an open protocol for peer-to-peer communication between autonomous AI agents. Originally developed by Google and now governed by the `a2aproject` organization, it handles the layer [[mcp-moc|MCP]] does not: agent-to-agent delegation and multi-turn collaboration between opaque, stateful peers.

Where MCP standardizes how an agent accesses tools and resources (agent ↔ tool), A2A standardizes how agents communicate with each other as peers (agent ↔ agent). Together they cover the full communication surface of a multi-agent system. See [[a2a-mcp-contrast]].

---

## Agent Card

The **Agent Card** is the A2A structural equivalent of an MCP server manifest. It is a JSON document discoverable at `https://{domain}/.well-known/agent-card.json` that advertises an agent's identity, capabilities, skills, and authentication requirements to prospective client agents.

Core fields:

| Field | Type | Purpose |
|---|---|---|
| `name` | string | Human-readable agent name |
| `description` | string | What the agent does |
| `version` | string | Agent version |
| `provider` | object | Organization / service provider details |
| `supported_interfaces` | array | Protocol bindings and endpoint URLs |
| `capabilities` | object | Boolean flags: `streaming`, `pushNotifications`, `extendedAgentCard` |
| `security_schemes` | map | OAuth2 flows, API Key, mTLS, OIDC declarations |
| `security` | array | Which schemes are required to call this agent |
| `default_input_modes` | array | Accepted MIME types for input Parts |
| `default_output_modes` | array | Produced MIME types for output Parts |
| `skills` | array | `AgentSkill` objects (see below) |

Minimal example:
```json
{
  "name": "ResearchAgent",
  "description": "Retrieves and summarizes documents from the web.",
  "version": "1.0.0",
  "capabilities": { "streaming": true, "pushNotifications": false },
  "security_schemes": {
    "oauth2": {
      "type": "oauth2",
      "flows": { "clientCredentials": { "tokenUrl": "https://auth.example.com/token" } }
    }
  },
  "security": [{ "oauth2": ["research:read"] }],
  "default_input_modes": ["text/plain"],
  "default_output_modes": ["text/plain", "application/json"],
  "skills": [
    {
      "id": "summarize_url",
      "name": "Summarize URL",
      "description": "Fetches a URL and returns a structured summary.",
      "tags": ["research", "web"],
      "input_modes": ["text/plain"],
      "output_modes": ["application/json"]
    }
  ]
}
```

Cards may be digitally signed (JWS / RFC 7515 with RFC 8785 canonicalization) for authenticity verification. An **extended Agent Card** — with additional private details not suitable for public exposure — can be retrieved via the `GetExtendedAgentCard` RPC after authentication.

---

## Skill

A **Skill** is a discrete advertised capability within an Agent Card. It is the A2A structural equivalent of a Tool in an MCP manifest.

| Field | Type | Purpose |
|---|---|---|
| `id` | string | Unique identifier within the agent |
| `name` | string | Human-readable name |
| `description` | string | What the skill does and when to invoke it |
| `tags` | array | Keywords for capability discovery |
| `examples` | array | Usage scenario strings |
| `input_modes` | array | Skill-specific input MIME type overrides |
| `output_modes` | array | Skill-specific output MIME type overrides |

Unlike MCP Tools, Skills do not carry explicit JSON Schema for inputs and outputs. Discovery is semantic — the `description` and `tags` guide the orchestrator; the actual message content is passed as typed `Part` objects (see below). The formal lattice treatment is in [[a2a-capability-lattice]].

---

## Task Lifecycle

A **Task** is the stateful unit of work in A2A. The client creates a task by sending a `Message`; the server returns a Task object with a server-generated `id` and a `TaskStatus`.

### Task Object Fields

| Field | Type | Purpose |
|---|---|---|
| `id` | string | Server-generated unique identifier |
| `context_id` | string | Groups related tasks into a logical context |
| `status` | TaskStatus | Current state + optional status message + timestamp |
| `artifacts` | array | Concrete outputs produced by the agent |
| `history` | array | Message transcript for multi-turn tasks |
| `metadata` | object | Custom task metadata |

### Task States

```
SUBMITTED → WORKING → COMPLETED
                    ↘ FAILED
                    ↘ CANCELED
                    ↘ REJECTED
                    ↘ INPUT_REQUIRED → (client sends follow-up) → WORKING
                    ↘ AUTH_REQUIRED  → (client provides credential) → WORKING
                    ↘ TRANSFERRED    (terminal for A; task continues on B)
```

`INPUT_REQUIRED`, `AUTH_REQUIRED`, and `TRANSFERRED` are the multi-turn hooks.

### Task States & Transitions
*   **TRANSFERRED**: terminal for the originating agent's task. The orchestrator reads the `transfer` field in `TaskStatus` and routes the conversation to the target agent. The originating agent must pre-create the receiving task before transitioning to prevent races.

### RPC Methods

| Method | Interaction mode | Purpose |
|---|---|---|
| `SendMessage` | Request / Response | Initiate a task or send a follow-up turn |
| `SendStreamingMessage` | Server-streaming SSE | Initiate a task and receive incremental updates |
| `SubscribeToTask` | Server-streaming SSE | Attach to an existing non-terminal task |
| `GetTask` | Request / Response | Poll current task state |
| `ListTasks` | Request / Response | Filter and enumerate tasks |
| `CancelTask` | Request / Response | Request cancellation of an in-progress task |
| `CreateTaskPushNotificationConfig` | Request / Response | Register webhook for async delivery |
| `GetTaskPushNotificationConfig` | Request / Response | Retrieve current webhook config |
| `ListTaskPushNotificationConfigs` | Request / Response | Enumerate registered webhooks |
| `DeleteTaskPushNotificationConfig` | Request / Response | Deactivate a webhook |
| `GetExtendedAgentCard` | Request / Response | Fetch authenticated extended Agent Card |

**Streaming** uses SSE over HTTP. The server emits `TaskStatusUpdateEvent` and `TaskArtifactUpdateEvent` frames as processing progresses — each event carries the current task state or a newly completed artifact.

**Push notifications** serve clients that cannot hold open connections. The client registers a webhook URL via `CreateTaskPushNotificationConfig`; the server POSTs `StreamResponse` payloads to that URL as updates occur. The client acknowledges with HTTP 2xx; the server retries on failure. The push notification config includes an optional `token` (session-unique) and `authentication` block so the server can prove its identity to the webhook endpoint.

---

## Parts

The **Part** is the fundamental content unit inside Messages and Artifacts. All message content and all agent output is expressed as a list of Parts — a discriminated union supporting multiple modalities in a single turn.

| Part type | Key field | Content |
|---|---|---|
| Text | `text: string` | Plain text or formatted text content |
| File (URL) | `url: string` | Reference to a remote file resource |
| File (inline) | `raw: bytes` | Base64-encoded binary file content |
| Structured data | `data: object` | Structured JSON payload |

Every Part carries:
- `media_type` (MIME type) for content negotiation
- `filename` (optional) for file identification
- `metadata` (optional map) for extensible attributes

The Part model is the A2A equivalent of MCP's typed content blocks — both protocols use a discriminated union to support text, binary, and structured data within a single message envelope.

---

## Authentication

A2A delegates authentication entirely to standard enterprise identity protocols. The A2A protocol messages themselves carry no credentials.

**Flow:**
1. **Declare** — The server lists required auth schemes in `AgentCard.security_schemes` (OAuth2 flows, OIDC, API Key, HTTP Bearer, mTLS).
2. **Acquire** — The client obtains credentials out-of-band via the appropriate protocol (e.g., OAuth2 client-credentials flow against the token endpoint declared in the Agent Card).
3. **Transmit** — Credentials are passed via HTTP headers (`Authorization: Bearer <token>`), separate from A2A protocol messages.
4. **Validate** — The server authenticates every inbound request against its declared schemes before processing.

For mid-task authorization needs, the agent transitions to `AUTH_REQUIRED` and delivers a message describing the required credential. The client supplies it and the task resumes — no task teardown or restart required.

**Contrast with MCP:** MCP trust is session-scoped and negotiated within the protocol at connection time. A2A trust is request-scoped and handled by external identity infrastructure (OAuth 2.0 / OIDC), making it more suitable for cross-organization agent federation where no shared session context exists.

---

---

## Delegation and Handoffs

The A2A task lifecycle covers the *within-agent* state machine. This section covers the *between-agent* transitions: how an agent passes work to a peer.

Two primitives are distinguished because their control semantics differ:

| Primitive | Description | Analogy |
|---|---|---|
| **Delegation** | Agent A calls Agent B, waits for `COMPLETED`, uses B's `Artifacts` as a result, then continues. A retains the active task. | [[agent-development-kit|ADK]] `AgentTool` |
| **Handoff** | Agent A transfers its active task to Agent B and terminates its own involvement. The task continues on B's endpoint. | ADK `transfer_to_agent` / Swarm return-based handoff |

### Delegation

Delegation requires no new primitives. Agent A creates a new task on Agent B via `SendMessage`, polls or streams until `COMPLETED`, extracts B's `Artifacts`, and incorporates them as input to its own ongoing task. The orchestrator's task on A remains `WORKING` throughout. Capability constraints follow the lattice meet: `Effective(A → B) = Caps(B) ∩ Scope(A)` — A cannot grant B a capability A does not itself hold (see [[capability-lattice-spec]] §4.3).

### Handoff — `TRANSFERRED` State

A handoff terminates the originating agent's task with a new quasi-terminal state:

```
SUBMITTED → WORKING → COMPLETED
                    ↘ FAILED
                    ↘ CANCELED
                    ↘ REJECTED
                    ↘ INPUT_REQUIRED → (client sends follow-up) → WORKING
                    ↘ AUTH_REQUIRED  → (client provides credential) → WORKING
                    ↘ TRANSFERRED    (terminal for A; task continues on B)
```

`TRANSFERRED` is terminal for the originating agent's task. The orchestrator reads the `transfer` field in `TaskStatus` and routes the conversation to the target agent.

#### `TaskStatus` when `state = TRANSFERRED`

```json
{
  "state": "TRANSFERRED",
  "timestamp": "2026-04-26T12:00:00Z",
  "transfer": {
    "agent_endpoint": "https://billing.example.com",
    "task_id": "task_xyz_billing",
    "reason": "User query identified as billing — routing to Billing specialist"
  }
}
```

| Field | Type | Purpose |
|---|---|---|
| `agent_endpoint` | URL | The A2A base URL of the receiving agent |
| `task_id` | string | The task ID already created on the receiving agent (pre-created by A during handoff) |
| `reason` | string (optional) | Human-readable explanation for audit logs |

The originating agent is expected to create the receiving task *before* transitioning to `TRANSFERRED` — atomically, these form the handoff. This prevents the orchestrator from receiving a `TRANSFERRED` status pointing at a task that does not yet exist.

### Context Transfer — `transfer_context`

A flat conversation history is too expensive to pass verbatim across a handoff. Instead, the originating agent serializes its working state into a `transfer_context` block, included in the `SendMessage` request when creating the receiving task on Agent B.

`transfer_context` is an optional field on the A2A `Message` object:

```json
{
  "role": "user",
  "parts": [{ "kind": "text", "text": "The user needs a refund for order #88234." }],
  "transfer_context": {
    "originating_task_id": "task_abc_triage",
    "originating_agent": "https://triage.example.com",
    "state": {
      "user_intent":  "billing_refund",
      "account_id":   "ACC-12345",
      "order_id":     "ORD-88234"
    },
    "output_keys": {
      "triage_classification": "BILLING_REFUND",
      "sentiment":             "frustrated"
    }
  }
}
```

| Field | Type | Maps from | Purpose |
|---|---|---|---|
| `originating_task_id` | string | — | Audit trail; links B's task back to A's |
| `originating_agent` | URL | — | Source agent endpoint |
| `state` | object | Swarm `context_variables` | Flat key-value working memory; survives the handoff |
| `output_keys` | object | ADK `output_key` / `State` | Named outputs from completed pipeline steps |

The receiving agent bootstraps its own working memory from `transfer_context.state` and `output_keys`. It does not need the full message history to serve the user; the originating agent is responsible for summarizing relevant context before transferring.

### Lattice Compliance for Handoffs

A handoff is a constrained delegation: before transitioning to `TRANSFERRED`, the originating agent must verify that the target agent's required skills fall within the allowed workflow scope:

```
Allowed = Caps(TargetAgent) ∩ Scope(OriginatingAgent)
Required ⊆ Allowed   ← must hold; violation = refuse handoff, transition to FAILED
```

If `Required ⊄ Allowed`, the handoff must not proceed. The task should transition to `FAILED` (or `INPUT_REQUIRED` if human escalation is appropriate) rather than silently forwarding to an agent outside the authorized scope. This keeps every handoff path statically analyzable as a delegation edge in the workflow graph described in [[capability-lattice-spec]] §4.4.

---

## References

- [[a2a-mcp-contrast]]
- [[a2a-capability-lattice]]
- [[agentic-protocols]]
- [[community-protocol-trust-substrate]]
- [[capability-lattice-spec]]
- [[mcp-architecture]]
- [[mcp-primitives]]
- [[adk-multi-agent-orchestration]]
- [[openai-swarm]]


---
## References
- [[claude-a2a-protocol-handoff]]

---

## Delegation and Handoffs

The A2A task lifecycle covers the *within-agent* state machine. This section covers the *between-agent* transitions: how an agent passes work to a peer.

| Primitive | Description | Analogy |
|---|---|---|
| **Delegation** | Agent A calls Agent B, waits for `COMPLETED`, uses B's `Artifacts` as a result, then continues. A retains the active task. | ADK `AgentTool` |
| **Handoff** | Agent A transfers its active task to Agent B and terminates its own involvement. The task continues on B's endpoint. | ADK `transfer_to_agent` / Swarm return-based handoffs |

### Delegation (Agent as Tool)
Delegation is supported by existing A2A primitives. Agent A creates a new task on Agent B via `SendMessage`, polls or streams until `COMPLETED`, extracts B's `Artifacts`, and incorporates them as input to its own ongoing task. No new RPCs are required.

### Handoff (`TRANSFERRED` State)
A handoff terminates the originating agent's task with the `TRANSFERRED` state.

#### `TaskStatus` when `state = TRANSFERRED`
```json
{
  "state": "TRANSFERRED",
  "transfer": {
    "agent_endpoint": "https://billing.example.com",
    "task_id": "task_xyz_billing",
    "reason": "Routing to Billing specialist"
  }
}
```

### Context Transfer (`transfer_context`)
An optional `transfer_context` field on the `Message` object serializes the working memory:
- `state`: Maps to Swarm `context_variables`.
- `output_keys`: Maps to ADK `output_key`.
- `originating_task_id` / `originating_agent`: Audit trail.

### Lattice Compliance
Before any handoff, the originating agent must verify the required skills fall within `Caps(B) ∩ Scope(A)`. Violation leads to a `FAILED` state, not a silent forward.

