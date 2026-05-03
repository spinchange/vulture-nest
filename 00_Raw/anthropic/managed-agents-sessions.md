<!--
source_url: https://platform.claude.com/docs/en/managed-agents/sessions
requested_url: https://platform.claude.com/docs/en/managed-agents/sessions
fetch_date: 2026-05-02T00:46:17.454Z
crawl_job_id: 019dec06-0e1d-75a4-90b0-b37006f58a66
source_page_id: a84c9043-de30-4082-807b-0f1c14ddc883
chunk_ids: 40da9706-342f-4b3e-a631-fab8cee48a09, d694925c-53a0-40ab-a9ec-1d6c3af1f217, 16c86e12-52f8-400f-a33d-8caaf6970bb1, 5398e7a0-5808-4392-b9e2-a293c7f377f5, 95406a66-85f9-4b47-9e87-eeeba86b1297, 69a36ebe-9ef1-4ef7-aef9-a04921aebb89
-->

# Start a session - Claude API Docs
Delegate work to your agent

Start a session

Copy page

A session is a running agent instance within an environment. Each session references an [agent](https://platform.claude.com/docs/en/managed-agents/agent-setup) and an [environment](https://platform.claude.com/docs/en/managed-agents/environments) (both created separately), and maintains conversation history across multiple interactions.

All Managed Agents API requests require the `managed-agents-2026-04-01` beta header. The SDK sets the beta header automatically.

## Creating a session

A session requires an `agent` ID and an `environment` ID. Agents are versioned resources; passing in the `agent` ID as a string starts the session with the latest agent version.

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
session = client.beta.sessions.create(
    agent=agent.id,
    environment_id=environment.id,
)
```

To pin a session to a specific agent version, pass an object. This lets you control exactly which version runs and stage rollouts of new versions independently.

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
pinned_session = client.beta.sessions.create(
    agent={"type": "agent", "id": agent.id, "version": 1},
    environment_id=environment.id,
)
```

The agent defines how Claude behaves within the session, including the model, system prompt, tools, and MCP servers. See [Agent setup](https://platform.claude.com/docs/en/managed-agents/agent-setup) for details.

## MCP authentication through vaults

If your agent uses MCP tools that require authentication, pass `vault_ids` at session creation to reference a vault containing stored OAuth credentials. Anthropic manages token refresh on your behalf. See [Authenticate with vaults](https://platform.claude.com/docs/en/managed-agents/vaults) for how to create vaults and register credentials.

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
vault_session = client.beta.sessions.create(
    agent=agent.id,
    environment_id=environment.id,
    vault_ids=[vault.id],
)
```

## Starting the session

Creating a session provisions the environment and agent but does not start any work. To delegate a task, send events to the session using a [user event](https://platform.claude.com/docs/en/managed-agents/events-and-streaming#user-events). The session acts as a state machine that tracks progress while events drive the actual execution.

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
client.beta.sessions.events.send(
    session.id,
    events=[\
        {\
            "type": "user.message",\
            "content": [\
                {"type": "text", "text": "List the files in the working directory."}\
            ],\
        },\
    ],
)
```

See [Events and streaming](https://platform.claude.com/docs/en/managed-agents/events-and-streaming) for how to stream the agent's responses and handle tool confirmations.

## Session statuses

Sessions progress through these statuses:

| Status | Description |
| --- | --- |
| `idle` | Agent is waiting for input, including user messages or tool confirmations. Sessions start in `idle`. |
| `running` | Agent is actively executing |
| `rescheduling` | Transient error occurred, retrying automatically |
| `terminated` | Session has ended due to an unrecoverable error |

## Other session operations

### Retrieving a session

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
retrieved = client.beta.sessions.retrieve(session.id)
print(f"Status: {retrieved.status}")
```

### Listing sessions

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
for session in client.beta.sessions.list():
    print(f"{session.id}: {session.status}")
```

### Archiving a session

Archive a session to prevent new events from being sent while preserving its history:

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
client.beta.sessions.archive(session.id)
```

### Deleting a session

Delete a session to permanently remove its record, events, and associated container. A `running` session cannot be deleted; send an [interrupt event](https://platform.claude.com/docs/en/managed-agents/events-and-streaming#user-events) if you need to delete it immediately.

Files, memory stores, environments, and agents are independent resources and are not affected by session deletion.

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
client.beta.sessions.delete(session.id)
```

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
