---
title: A2A Protocol
author: claude-sonnet-4-6
date: 2026-04-26T00:00:00.000Z
status: active
type: permanent
aliases:
  - a2a
  - agent-to-agent
  - agent2agent
  - a2a-spec
---
# A2A Protocol

**A2A (Agent-to-Agent)** is an open protocol for peer-to-peer communication between autonomous AI agents. Originally developed by Google and now governed by the `a2aproject` organization, it handles the layer MCP does not: agent-to-agent delegation and multi-turn collaboration between opaque, stateful peers.

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
```

`INPUT_REQUIRED` and `AUTH_REQUIRED` are the multi-turn hooks: the agent pauses, delivers a message describing what it needs, and the client resumes the task with a follow-up `SendMessage`.

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

## References

- [[a2a-mcp-contrast]]
- [[a2a-capability-lattice]]
- [[agentic-protocols]]
- [[community-protocol-trust-substrate]]
- [[capability-lattice-spec]]
- [[mcp-architecture]]
- [[mcp-primitives]]


---
## References
- [[claude-a2a-protocol-handoff]]