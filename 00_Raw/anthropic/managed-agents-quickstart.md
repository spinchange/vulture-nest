<!--
source_url: https://platform.claude.com/docs/en/managed-agents/quickstart
requested_url: https://platform.claude.com/docs/en/managed-agents/quickstart
fetch_date: 2026-05-02T12:47:56.467Z
crawl_job_id: 019dec05-1672-7252-bc30-22646ae22e64
source_page_id: c917f805-271a-439c-b880-a32b618b4dc1
chunk_ids: fecf2de7-574c-4fb2-ab49-786d71f6d4e9, 21a7fd5c-be6c-4a25-aed8-cfcb7526eea0, b1f20dc8-b68a-4270-bec5-576b4f4ba059
-->

# Get started with Claude Managed Agents - Claude API Docs
Managed Agents

Quickstart

Copy page

This guide walks you through creating an agent, setting up an environment, starting a session, and streaming agent responses.

**Prefer an interactive walkthrough?** Run `/claude-api managed-agents-onboard` in the latest version of [Claude Code](https://claude.com/product/claude-code) for a guided setup and interactive question-answering.

## Core concepts

| Concept | Description |
| --- | --- |
| **Agent** | The model, system prompt, tools, MCP servers, and skills |
| **Environment** | A configured container template (packages, network access) |
| **Session** | A running agent instance within an environment, performing a specific task and generating outputs |
| **Events** | Messages exchanged between your application and the agent (user turns, tool results, status updates) |

## Prerequisites

- An Anthropic [Console account](https://platform.claude.com/)
- An [API key](https://platform.claude.com/settings/keys)

## Install the CLI

Homebrew (macOS)

Homebrew (macOS)

curl (Linux/WSL)

curl (Linux/WSL)

Go

Go

```
brew install anthropics/tap/ant
```

Check the installation:

```
ant --version
```

## Install the SDK

Python

Python

TypeScript

TypeScript

Java

Java

Go

Go

C#

C#

Ruby

Ruby

PHP

PHP

```
pip install anthropic
```

Set your API key as an environment variable:

```
export ANTHROPIC_API_KEY="your-api-key-here"
```

## Create your first session

All Managed Agents API requests require the `managed-agents-2026-04-01` beta header. The SDK sets the beta header automatically.

1. 1



Create an agent







Create an agent that defines the model, system prompt, and available tools.







curlCLIPythonTypeScriptC#GoJavaPHPRuby























```
ant beta:agents create \
     --name "Coding Assistant" \
     --model '{id: claude-opus-4-7}' \
     --system "You are a helpful coding assistant. Write clean, well-documented code." \
     --tool '{type: agent_toolset_20260401}'
```









The `agent_toolset_20260401` tool type enables the full set of pre-built agent tools (bash, file operations, web search, and more). See [Tools](https://platform.claude.com/docs/en/managed-agents/tools) for the complete list and per-tool configuration options.



Save the returned `agent.id`. You'll reference it in every session you create.

2. 2



Create an environment







An environment defines the container where your agent runs.







curlCLIPythonTypeScriptC#GoJavaPHPRuby























```
ant beta:environments create \
     --name "quickstart-env" \
     --config '{type: cloud, networking: {type: unrestricted}}'
```









Save the returned `environment.id`. You'll reference it in every session you create.

3. 3



Start a session







Create a session that references your agent and environment.







curlPythonTypeScriptC#GoJavaPHPRuby























```
session = client.beta.sessions.create(
       agent=agent.id,
       environment_id=environment.id,
       title="Quickstart session",
)

print(f"Session ID: {session.id}")
```

4. 4



Send a message and stream the response







Open a stream, send a user event, then process events as they arrive:







curlPythonTypeScriptC#GoJavaPHPRuby























```
with client.beta.sessions.events.stream(session.id) as stream:
       # Send the user message after the stream opens
       client.beta.sessions.events.send(
           session.id,
           events=[\
               {\
                   "type": "user.message",\
                   "content": [\
                       {\
                           "type": "text",\
                           "text": "Create a Python script that generates the first 20 Fibonacci numbers and saves them to fibonacci.txt",\
                       },\
                   ],\
               },\
           ],
       )

       # Process streaming events
       for event in stream:
           match event.type:
               case "agent.message":
                   for block in event.content:
                       print(block.text, end="")
               case "agent.tool_use":
                   print(f"\n[Using tool: {event.name}]")
               case "session.status_idle":
                   print("\n\nAgent finished.")
                   break
```









The agent will write a Python script, execute it in the container, and verify the output file was created. Your output will look similar to this:







```
I'll create a Python script that generates the first 20 Fibonacci numbers and saves them to a file.
[Using tool: write]
[Using tool: bash]
The script ran successfully. Let me verify the output file.
[Using tool: bash]
fibonacci.txt contains the first 20 Fibonacci numbers (0 through 4181).

Agent finished.
```


## What's happening

When you send a user event, Claude Managed Agents:

1. **Provisions a container:** Your environment configuration determines how it's built.
2. **Runs the agent loop:** Claude decides which tools to use based on your message
3. **Executes tools:** File writes, bash commands, and other tool calls run inside the container
4. **Streams events:** You receive real-time updates as the agent works
5. **Goes idle:** The agent emits a `session.status_idle` event when it has nothing more to do

## Next steps

[Define your agent\\
\\
Create reusable, versioned agent configurations](https://platform.claude.com/docs/en/managed-agents/agent-setup) [Configure environments\\
\\
Customize networking and container settings](https://platform.claude.com/docs/en/managed-agents/environments) [Agent tools\\
\\
Enable specific tools for your agent](https://platform.claude.com/docs/en/managed-agents/tools) [Events and streaming\\
\\
Handle events and steer the agent mid-execution](https://platform.claude.com/docs/en/managed-agents/events-and-streaming)

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
