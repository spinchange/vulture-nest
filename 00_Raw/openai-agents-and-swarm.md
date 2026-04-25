---
tags:
  - agents
  - openai
  - swarm
  - documentation
source: gemini
machine: VEGA
date: 2026-04-24
status: draft
---
# OpenAI Swarm (Experimental)

![Swarm Logo](assets/logo.png)

# Swarm (experimental, educational)

> [!IMPORTANT]
> Swarm is now replaced by the [OpenAI Agents SDK](https://github.com/openai/openai-agents-python), which is a production-ready evolution of Swarm. The Agents SDK features key improvements and will be actively maintained by the OpenAI team.
>
> We recommend migrating to the Agents SDK for all production use cases.

## Install

Requires Python 3.10+

```shell
pip install git+ssh://git@github.com/openai/swarm.git
```

or

```shell
pip install git+https://github.com/openai/swarm.git
```

## Usage

```python
from swarm import Swarm, Agent

client = Swarm()

def transfer_to_agent_b():
    return agent_b


agent_a = Agent(
    name="Agent A",
    instructions="You are a helpful agent.",
    functions=[transfer_to_agent_b],
)

agent_b = Agent(
    name="Agent B",
    instructions="Only speak in Haikus.",
)

response = client.run(
    agent=agent_a,
    messages=[{"role": "user", "content": "I want to talk to agent B."}],
)

print(response.messages[-1]["content"])
```

```
Hope glimmers brightly,
New paths converge gracefully,
What can I assist?
```

## Table of Contents

- [Overview](#overview)
- [Examples](#examples)
- [Documentation](#documentation)
  - [Running Swarm](#running-swarm)
  - [Agents](#agents)
  - [Functions](#functions)
  - [Streaming](#streaming)
- [Evaluations](#evaluations)
- [Utils](#utils)

# Overview

Swarm focuses on making agent **coordination** and **execution** lightweight, highly controllable, and easily testable.

It accomplishes this through two primitive abstractions: `Agent`s and **handoffs**. An `Agent` encompasses `instructions` and `tools`, and can at any point choose to hand off a conversation to another `Agent`.

These primitives are powerful enough to express rich dynamics between tools and networks of agents, allowing you to build scalable, real-world solutions while avoiding a steep learning curve.

> [!NOTE]
> Swarm Agents are not related to Assistants in the Assistants API. They are named similarly for convenience, but are otherwise completely unrelated. Swarm is entirely powered by the Chat Completions API and is hence stateless between calls.

## Why Swarm

Swarm explores patterns that are lightweight, scalable, and highly customizable by design. Approaches similar to Swarm are best suited for situations dealing with a large number of independent capabilities and instructions that are difficult to encode into a single prompt.

The Assistants API is a great option for developers looking for fully-hosted threads and built in memory management and retrieval. However, Swarm is an educational resource for developers curious to learn about multi-agent orchestration. Swarm runs (almost) entirely on the client and, much like the Chat Completions API, does not store state between calls.

# Examples

Check out `/examples` for inspiration! Learn more about each one in its README.

- [`basic`](examples/basic): Simple examples of fundamentals like setup, function calling, handoffs, and context variables
- [`triage_agent`](examples/triage_agent): Simple example of setting up a basic triage step to hand off to the right agent
- [`weather_agent`](examples/weather_agent): Simple example of function calling
- [`airline`](examples/airline): A multi-agent setup for handling different customer service requests in an airline context.
- [`support_bot`](examples/support_bot): A customer service bot which includes a user interface agent and a help center agent with several tools
- [`personal_shopper`](examples/personal_shopper): A personal shopping agent that can help with making sales and refunding orders

# Documentation

![Swarm Diagram](assets/swarm_diagram.png)

## Running Swarm

Start by instantiating a Swarm client (which internally just instantiates an `OpenAI` client).

```python
from swarm import Swarm

client = Swarm()
```

### `client.run()`

Swarm's `run()` function is analogous to the `chat.completions.create()` function in the Chat Completions API – it takes `messages` and returns `messages` and saves no state between calls. Importantly, however, it also handles Agent function execution, hand-offs, context variable references, and can take multiple turns before returning to the user.

At its core, Swarm's `client.run()` implements the following loop:

1. Get a completion from the current Agent
2. Execute tool calls and append results
3. Switch Agent if necessary
4. Update context variables, if necessary
5. If no new function calls, return

#### Arguments

| Argument              | Type    | Description                                                                                                                                            | Default        |
| --------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------- |
| **agent**             | `Agent` | The (initial) agent to be called.                                                                                                                      | (required)     |
| **messages**          | `List`  | A list of message objects, identical to [Chat Completions `messages`](https://platform.openai.com/docs/api-reference/chat/create#chat-create-messages) | (required)     |
| **context_variables** | `dict`  | A dictionary of additional context variables, available to functions and Agent instructions                                                            | `{}`           |
| **max_turns**         | `int`   | The maximum number of conversational turns allowed                                                                                                     | `float("inf")` |
| **model_override**    | `str`   | An optional string to override the model being used by an Agent                                                                                        | `None`         |
| **execute_tools**     | `bool`  | If `False`, interrupt execution and immediately returns `tool_calls` message when an Agent tries to call a function                                    | `True`         |
| **stream**            | `bool`  | If `True`, enables streaming responses                                                                                                                 | `False`        |
| **debug**             | `bool`  | If `True`, enables debug logging                                                                                                                       | `False`        |

Once `client.run()` is finished (after potentially multiple calls to agents and tools) it will return a `Response` containing all the relevant updated state. Specifically, the new `messages`, the last `Agent` to be called, and the most up-to-date `context_variables`. You can pass these values (plus new user messages) in to your next execution of `client.run()` to continue the interaction where it left off – much like `chat.completions.create()`. (The `run_demo_loop` function implements an example of a full execution loop in `/swarm/repl/repl.py`.)

#### `Response` Fields

| Field                 | Type    | Description                                                                                                                                                                                                                                                                  |
| --------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **messages**          | `List`  | A list of message objects generated during the conversation. Very similar to [Chat Completions `messages`](https://platform.openai.com/docs/api-reference/chat/create#chat-create-messages), but with a `sender` field indicating which `Agent` the message originated from. |
| **agent**             | `Agent` | The last agent to handle a message.                                                                                                                                                                                                                                          |
| **context_variables** | `dict`  | The same as the input variables, plus any changes.                                                                                                                                                                                                                           |

## Agents

An `Agent` simply encapsulates a set of `instructions` with a set of `functions` (plus some additional settings below), and has the capability to hand off execution to another `Agent`.

While it's tempting to personify an `Agent` as "someone who does X", it can also be used to represent a very specific workflow or step defined by a set of `instructions` and `functions` (e.g. a set of steps, a complex retrieval, single step of data transformation, etc). This allows `Agent`s to be composed into a network of "agents", "workflows", and "tasks", all represented by the same primitive.

## `Agent` Fields

| Field            | Type                     | Description                                                                   | Default                      |
| ---------------- | ------------------------ | ----------------------------------------------------------------------------- | ---------------------------- |
| **name**         | `str`                    | The name of the agent.                                                        | `"Agent"`                    |
| **model**        | `str`                    | The model to be used by the agent.                                            | `"gpt-4o"`                   |
| **instructions** | `str` or `func() -> str` | Instructions for the agent, can be a string or a callable returning a string. | `"You are a helpful agent."` |
| **functions**    | `List`                   | A list of functions that the agent can call.                                  | `[]`                         |
| **tool_choice**  | `str`                    | The tool choice for the agent, if any.                                        | `None`                       |

### Instructions

`Agent` `instructions` are directly converted into the `system` prompt of a conversation (as the first message). Only the `instructions` of the active `Agent` will be present at any given time (e.g. if there is an `Agent` handoff, the `system` prompt will change, but the chat history will not.)

```python
agent = Agent(
   instructions="You are a helpful agent."
)
```

The `instructions` can either be a regular `str`, or a function that returns a `str`. The function can optionally receive a `context_variables` parameter, which will be populated by the `context_variables` passed into `client.run()`.

```python
def instructions(context_variables):
   user_name = context_variables["user_name"]
   return f"Help the user, {user_name}, do whatever they want."

agent = Agent(
   instructions=instructions
)
response = client.run(
   agent=agent,
   messages=[{"role":"user", "content": "Hi!"}],
   context_variables={"user_name":"John"}
)
print(response.messages[-1]["content"])
```

```
Hi John, how can I assist you today?
```

## Functions

- Swarm `Agent`s can call python functions directly.
- Function should usually return a `str` (values will be attempted to be cast as a `str`).
- If a function returns an `Agent`, execution will be transferred to that `Agent`.
- If a function defines a `context_variables` parameter, it will be populated by the `context_variables` passed into `client.run()`.

```python
def greet(context_variables, language):
   user_name = context_variables["user_name"]
   greeting = "Hola" if language.lower() == "spanish" else "Hello"
   print(f"{greeting}, {user_name}!")
   return "Done"

agent = Agent(
   functions=[greet]
)

client.run(
   agent=agent,
   messages=[{"role": "user", "content": "Usa greet() por favor."}],
   context_variables={"user_name": "John"}
)
```

```
Hola, John!
```

- If an `Agent` function call has an error (missing function, wrong argument, error) an error response will be appended to the chat so the `Agent` can recover gracefully.
- If multiple functions are called by the `Agent`, they will be executed in that order.

### Handoffs and Updating Context Variables

An `Agent` can hand off to another `Agent` by returning it in a `function`.

```python
sales_agent = Agent(name="Sales Agent")

def transfer_to_sales():
   return sales_agent

agent = Agent(functions=[transfer_to_sales])

response = client.run(agent, [{"role":"user", "content":"Transfer me to sales."}])
print(response.agent.name)
```

```
Sales Agent
```

It can also update the `context_variables` by returning a more complete `Result` object. This can also contain a `value` and an `agent`, in case you want a single function to return a value, update the agent, and update the context variables (or any subset of the three).

```python
sales_agent = Agent(name="Sales Agent")

def talk_to_sales():
   print("Hello, World!")
   return Result(
       value="Done",
       agent=sales_agent,
       context_variables={"department": "sales"}
   )

agent = Agent(functions=[talk_to_sales])

response = client.run(
   agent=agent,
   messages=[{"role": "user", "content": "Transfer me to sales"}],
   context_variables={"user_name": "John"}
)
print(response.agent.name)
print(response.context_variables)
```

```
Sales Agent
{'department': 'sales', 'user_name': 'John'}
```

> [!NOTE]
> If an `Agent` calls multiple functions to hand-off to an `Agent`, only the last handoff function will be used.

### Function Schemas

Swarm automatically converts functions into a JSON Schema that is passed into Chat Completions `tools`.

- Docstrings are turned into the function `description`.
- Parameters without default values are set to `required`.
- Type hints are mapped to the parameter's `type` (and default to `string`).
- Per-parameter descriptions are not explicitly supported, but should work similarly if just added in the docstring. (In the future docstring argument parsing may be added.)

```python
def greet(name, age: int, location: str = "New York"):
   """Greets the user. Make sure to get their name and age before calling.

   Args:
      name: Name of the user.
      age: Age of the user.
      location: Best place on earth.
   """
   print(f"Hello {name}, glad you are {age} in {location}!")
```

```javascript
{
   "type": "function",
   "function": {
      "name": "greet",
      "description": "Greets the user. Make sure to get their name and age before calling.\n\nArgs:\n   name: Name of the user.\n   age: Age of the user.\n   location: Best place on earth.",
      "parameters": {
         "type": "object",
         "properties": {
            "name": {"type": "string"},
            "age": {"type": "integer"},
            "location": {"type": "string"}
         },
         "required": ["name", "age"]
      }
   }
}
```

## Streaming

```python
stream = client.run(agent, messages, stream=True)
for chunk in stream:
   print(chunk)
```

Uses the same events as [Chat Completions API streaming](https://platform.openai.com/docs/api-reference/streaming). See `process_and_print_streaming_response` in `/swarm/repl/repl.py` as an example.

Two new event types have been added:

- `{"delim":"start"}` and `{"delim":"end"}`, to signal each time an `Agent` handles a single message (response or function call). This helps identify switches between `Agent`s.
- `{"response": Response}` will return a `Response` object at the end of a stream with the aggregated (complete) response, for convenience.

# Evaluations

Evaluations are crucial to any project, and we encourage developers to bring their own eval suites to test the performance of their swarms. For reference, we have some examples for how to eval swarm in the `airline`, `weather_agent` and `triage_agent` quickstart examples. See the READMEs for more details.

# Utils

Use the `run_demo_loop` to test out your swarm! This will run a REPL on your command line. Supports streaming.

```python
from swarm.repl import run_demo_loop
...
run_demo_loop(agent, stream=True)
```

# Core Contributors

- Ilan Bigio - [ibigio](https://github.com/ibigio)
- James Hills - [jhills20](https://github.com/jhills20)
- Shyamal Anadkat - [shyamal-anadkat](https://github.com/shyamal-anadkat)
- Charu Jaiswal - [charuj](https://github.com/charuj)
- Colin Jarvis - [colin-openai](https://github.com/colin-openai)
- Katia Gil Guzman - [katia-openai](https://github.com/katia-openai)


---

# OpenAI Agents SDK (Production)

Title: Agents SDK | OpenAI API

URL Source: https://platform.openai.com/docs/guides/agents

Published Time: Fri, 24 Apr 2026 15:47:43 GMT

Markdown Content:
# Agents SDK | OpenAI API

[![Image 1: OpenAI Developers](https://platform.openai.com/OpenAI_Developers.svg)](https://platform.openai.com/)

[Home](https://platform.openai.com/)

[API](https://platform.openai.com/api)

[Docs Guides and concepts for the OpenAI API](https://platform.openai.com/api/docs)[API reference Endpoints, parameters, and responses](https://platform.openai.com/api/reference/overview)

[Codex](https://platform.openai.com/codex)

[Docs Guides, concepts, and product docs for Codex](https://platform.openai.com/codex)[Use cases Example workflows and tasks teams hand to Codex](https://platform.openai.com/codex/use-cases)

[ChatGPT](https://platform.openai.com/chatgpt)

[Apps SDK Build apps to extend ChatGPT](https://platform.openai.com/apps-sdk)[Commerce Build commerce flows in ChatGPT](https://platform.openai.com/commerce)

[Resources](https://platform.openai.com/learn)

[Showcase Demo apps to get inspired](https://platform.openai.com/showcase)[Blog Learnings and experiences from developers](https://platform.openai.com/blog)[Cookbook Notebook examples for building with OpenAI models](https://platform.openai.com/cookbook)[Learn Docs, videos, and demo apps for building with OpenAI](https://platform.openai.com/learn)[Community Programs, meetups, and support for builders](https://platform.openai.com/community)

Start searching

[API Dashboard](https://platform.openai.com/login)

## Search the API docs

Search docs 

### Suggested

responses create reasoning_effort realtime prompt caching

Primary navigation

 API  API Reference  Codex  ChatGPT  Resources 

Search docs 

### Suggested

responses create reasoning_effort realtime prompt caching

### Get started

*   [Overview](https://platform.openai.com/api/docs)
*   [Quickstart](https://platform.openai.com/api/docs/quickstart)
*   [Models](https://platform.openai.com/api/docs/models)
*   [Pricing](https://platform.openai.com/api/docs/pricing)
*   [Libraries](https://platform.openai.com/api/docs/libraries)
*   [Latest: GPT-5.4](https://platform.openai.com/api/docs/guides/latest-model)
*   [Prompt guidance](https://platform.openai.com/api/docs/guides/prompt-guidance)

### Core concepts

*   [Text generation](https://platform.openai.com/api/docs/guides/text)
*   [Code generation](https://platform.openai.com/api/docs/guides/code-generation)
*   [Images and vision](https://platform.openai.com/api/docs/guides/images-vision)
*   [Audio and speech](https://platform.openai.com/api/docs/guides/audio)
*   [Structured output](https://platform.openai.com/api/docs/guides/structured-outputs)
*   [Function calling](https://platform.openai.com/api/docs/guides/function-calling)
*   [Responses API](https://platform.openai.com/api/docs/guides/migrate-to-responses)
*   [Using tools](https://platform.openai.com/api/docs/guides/tools)

### Agents SDK

*   [Overview](https://platform.openai.com/api/docs/guides/agents)
*   [Quickstart](https://platform.openai.com/api/docs/guides/agents/quickstart)
*   [Agent definitions](https://platform.openai.com/api/docs/guides/agents/define-agents)
*   [Models and providers](https://platform.openai.com/api/docs/guides/agents/models)
*   [Running agents](https://platform.openai.com/api/docs/guides/agents/running-agents)
*   [Sandbox agents](https://platform.openai.com/api/docs/guides/agents/sandboxes)
*   [Orchestration](https://platform.openai.com/api/docs/guides/agents/orchestration)
*   [Guardrails](https://platform.openai.com/api/docs/guides/agents/guardrails-approvals)
*   [Results and state](https://platform.openai.com/api/docs/guides/agents/results)
*   [Integrations and observability](https://platform.openai.com/api/docs/guides/agents/integrations-observability)
*   [Evaluate agent workflows](https://platform.openai.com/api/docs/guides/agent-evals)
*   [Voice agents](https://platform.openai.com/api/docs/guides/voice-agents)
*   
Agent Builder
    *   [Overview](https://platform.openai.com/api/docs/guides/agent-builder)
    *   [Node reference](https://platform.openai.com/api/docs/guides/node-reference)
    *   [Safety in building agents](https://platform.openai.com/api/docs/guides/agent-builder-safety)
    *   
ChatKit
        *   [Overview](https://platform.openai.com/api/docs/guides/chatkit)
        *   [Customize](https://platform.openai.com/api/docs/guides/chatkit-themes)
        *   [Widgets](https://platform.openai.com/api/docs/guides/chatkit-widgets)
        *   [Actions](https://platform.openai.com/api/docs/guides/chatkit-actions)
        *   [Advanced integrations](https://platform.openai.com/api/docs/guides/custom-chatkit)

### Tools

*   [Web search](https://platform.openai.com/api/docs/guides/tools-web-search)
*   [MCP and Connectors](https://platform.openai.com/api/docs/guides/tools-connectors-mcp)
*   [Skills](https://platform.openai.com/api/docs/guides/tools-skills)
*   [Shell](https://platform.openai.com/api/docs/guides/tools-shell)
*   [Computer use](https://platform.openai.com/api/docs/guides/tools-computer-use)
*   
File search and retrieval
    *   [File search](https://platform.openai.com/api/docs/guides/tools-file-search)
    *   [Retrieval](https://platform.openai.com/api/docs/guides/retrieval)

*   [Tool search](https://platform.openai.com/api/docs/guides/tools-tool-search)
*   
More tools
    *   [Apply Patch](https://platform.openai.com/api/docs/guides/tools-apply-patch)
    *   [Local shell](https://platform.openai.com/api/docs/guides/tools-local-shell)
    *   [Image generation](https://platform.openai.com/api/docs/guides/tools-image-generation)
    *   [Code interpreter](https://platform.openai.com/api/docs/guides/tools-code-interpreter)

### Run and scale

*   [Conversation state](https://platform.openai.com/api/docs/guides/conversation-state)
*   [Background mode](https://platform.openai.com/api/docs/guides/background)
*   [Streaming](https://platform.openai.com/api/docs/guides/streaming-responses)
*   [WebSocket mode](https://platform.openai.com/api/docs/guides/websocket-mode)
*   [Webhooks](https://platform.openai.com/api/docs/guides/webhooks)
*   [File inputs](https://platform.openai.com/api/docs/guides/file-inputs)
*   
Context management
    *   [Compaction](https://platform.openai.com/api/docs/guides/compaction)
    *   [Counting tokens](https://platform.openai.com/api/docs/guides/token-counting)
    *   [Prompt caching](https://platform.openai.com/api/docs/guides/prompt-caching)

*   
Prompting
    *   [Overview](https://platform.openai.com/api/docs/guides/prompting)
    *   [Prompt engineering](https://platform.openai.com/api/docs/guides/prompt-engineering)
    *   [Citation formatting](https://platform.openai.com/api/docs/guides/citation-formatting)

*   
Reasoning
    *   [Reasoning models](https://platform.openai.com/api/docs/guides/reasoning)
    *   [Reasoning best practices](https://platform.openai.com/api/docs/guides/reasoning-best-practices)

### Evaluation

*   [Getting started](https://platform.openai.com/api/docs/guides/evaluation-getting-started)
*   [Working with evals](https://platform.openai.com/api/docs/guides/evals)
*   [Prompt optimizer](https://platform.openai.com/api/docs/guides/prompt-optimizer)
*   [External models](https://platform.openai.com/api/docs/guides/external-models)
*   [Best practices](https://platform.openai.com/api/docs/guides/evaluation-best-practices)

### Realtime API

*   [Overview](https://platform.openai.com/api/docs/guides/realtime)
*   
Connect
    *   [WebRTC](https://platform.openai.com/api/docs/guides/realtime-webrtc)
    *   [WebSocket](https://platform.openai.com/api/docs/guides/realtime-websocket)
    *   [SIP](https://platform.openai.com/api/docs/guides/realtime-sip)

*   
Usage
    *   [Using realtime models](https://platform.openai.com/api/docs/guides/realtime-models-prompting)
    *   [Managing conversations](https://platform.openai.com/api/docs/guides/realtime-conversations)
    *   [MCP servers](https://platform.openai.com/api/docs/guides/realtime-mcp)
    *   [Webhooks and server-side controls](https://platform.openai.com/api/docs/guides/realtime-server-controls)
    *   [Managing costs](https://platform.openai.com/api/docs/guides/realtime-costs)
    *   [Realtime transcription](https://platform.openai.com/api/docs/guides/realtime-transcription)
    *   [Voice agents](https://platform.openai.com/api/docs/guides/voice-agents)

### Model optimization

*   [Optimization cycle](https://platform.openai.com/api/docs/guides/model-optimization)
*   
Fine-tuning
    *   [Supervised fine-tuning](https://platform.openai.com/api/docs/guides/supervised-fine-tuning)
    *   [Vision fine-tuning](https://platform.openai.com/api/docs/guides/vision-fine-tuning)
    *   [Direct preference optimization](https://platform.openai.com/api/docs/guides/direct-preference-optimization)
    *   [Reinforcement fine-tuning](https://platform.openai.com/api/docs/guides/reinforcement-fine-tuning)
    *   [RFT use cases](https://platform.openai.com/api/docs/guides/rft-use-cases)
    *   [Best practices](https://platform.openai.com/api/docs/guides/fine-tuning-best-practices)

*   [Graders](https://platform.openai.com/api/docs/guides/graders)

### Specialized models

*   [Image generation](https://platform.openai.com/api/docs/guides/image-generation)
*   [Video generation](https://platform.openai.com/api/docs/guides/video-generation)
*   [Text to speech](https://platform.openai.com/api/docs/guides/text-to-speech)
*   [Speech to text](https://platform.openai.com/api/docs/guides/speech-to-text)
*   [Deep research](https://platform.openai.com/api/docs/guides/deep-research)
*   [Embeddings](https://platform.openai.com/api/docs/guides/embeddings)
*   [Moderation](https://platform.openai.com/api/docs/guides/moderation)

### Going live

*   [Production best practices](https://platform.openai.com/api/docs/guides/production-best-practices)
*   
Latency optimization
    *   [Overview](https://platform.openai.com/api/docs/guides/latency-optimization)
    *   [Predicted Outputs](https://platform.openai.com/api/docs/guides/predicted-outputs)
    *   [Priority processing](https://platform.openai.com/api/docs/guides/priority-processing)

*   
Cost optimization
    *   [Overview](https://platform.openai.com/api/docs/guides/cost-optimization)
    *   [Batch](https://platform.openai.com/api/docs/guides/batch)
    *   [Flex processing](https://platform.openai.com/api/docs/guides/flex-processing)

*   [Accuracy optimization](https://platform.openai.com/api/docs/guides/optimizing-llm-accuracy)
*   
Safety
    *   [Safety best practices](https://platform.openai.com/api/docs/guides/safety-best-practices)
    *   [Safety checks](https://platform.openai.com/api/docs/guides/safety-checks)
    *   [Cybersecurity checks](https://platform.openai.com/api/docs/guides/safety-checks/cybersecurity)
    *   [Under 18 API Guidance](https://platform.openai.com/api/docs/guides/safety-checks/under-18-api-guidance)

### Legacy APIs

*   
Assistants API
    *   [Migration guide](https://platform.openai.com/api/docs/assistants/migration)
    *   [Deep dive](https://platform.openai.com/api/docs/assistants/deep-dive)
    *   [Tools](https://platform.openai.com/api/docs/assistants/tools)

### Resources

*   [Terms and policies](https://openai.com/policies)
*   [Changelog](https://platform.openai.com/api/docs/changelog)
*   [Your data](https://platform.openai.com/api/docs/guides/your-data)
*   [Permissions](https://platform.openai.com/api/docs/guides/rbac)
*   [Rate limits](https://platform.openai.com/api/docs/guides/rate-limits)
*   [Deprecations](https://platform.openai.com/api/docs/deprecations)
*   [MCP for deep research](https://platform.openai.com/api/docs/mcp)
*   [Developer mode](https://platform.openai.com/api/docs/guides/developer-mode)
*   
ChatGPT Actions
    *   [Introduction](https://platform.openai.com/api/docs/actions/introduction)
    *   [Getting started](https://platform.openai.com/api/docs/actions/getting-started)
    *   [Actions library](https://platform.openai.com/api/docs/actions/actions-library)
    *   [Authentication](https://platform.openai.com/api/docs/actions/authentication)
    *   [Production](https://platform.openai.com/api/docs/actions/production)
    *   [Data retrieval](https://platform.openai.com/api/docs/actions/data-retrieval)
    *   [Sending files](https://platform.openai.com/api/docs/actions/sending-files)

 Docs  Use cases 

### Getting Started

*   [Overview](https://platform.openai.com/codex)
*   [Quickstart](https://platform.openai.com/codex/quickstart)
*   [Explore use cases](https://platform.openai.com/codex/use-cases)
*   [Pricing](https://platform.openai.com/codex/pricing)
*   
Concepts
    *   [Prompting](https://platform.openai.com/codex/prompting)
    *   [Customization](https://platform.openai.com/codex/concepts/customization)
    *   
[Memories](https://platform.openai.com/codex/memories)
        *   [Chronicle](https://platform.openai.com/codex/memories/chronicle)

    *   [Sandboxing](https://platform.openai.com/codex/concepts/sandboxing)
    *   [Subagents](https://platform.openai.com/codex/concepts/subagents)
    *   [Workflows](https://platform.openai.com/codex/workflows)
    *   [Models](https://platform.openai.com/codex/models)
    *   [Cyber Safety](https://platform.openai.com/codex/concepts/cyber-safety)

### Using Codex

*   
App
    *   [Overview](https://platform.openai.com/codex/app)
    *   [Features](https://platform.openai.com/codex/app/features)
    *   [Settings](https://platform.openai.com/codex/app/settings)
    *   [Review](https://platform.openai.com/codex/app/review)
    *   [Automations](https://platform.openai.com/codex/app/automations)
    *   [Worktrees](https://platform.openai.com/codex/app/worktrees)
    *   [Local Environments](https://platform.openai.com/codex/app/local-environments)
    *   [In-app browser](https://platform.openai.com/codex/app/browser)
    *   [Computer Use](https://platform.openai.com/codex/app/computer-use)
    *   [Commands](https://platform.openai.com/codex/app/commands)
    *   [Windows](https://platform.openai.com/codex/app/windows)
    *   [Troubleshooting](https://platform.openai.com/codex/app/troubleshooting)

*   
IDE Extension
    *   [Overview](https://platform.openai.com/codex/ide)
    *   [Features](https://platform.openai.com/codex/ide/features)
    *   [Settings](https://platform.openai.com/codex/ide/settings)
    *   [IDE Commands](https://platform.openai.com/codex/ide/commands)
    *   [Slash commands](https://platform.openai.com/codex/ide/slash-commands)

*   
CLI
    *   [Overview](https://platform.openai.com/codex/cli)
    *   [Features](https://platform.openai.com/codex/cli/features)
    *   [Command Line Options](https://platform.openai.com/codex/cli/reference)
    *   [Slash commands](https://platform.openai.com/codex/cli/slash-commands)

*   
Web
    *   [Overview](https://platform.openai.com/codex/cloud)
    *   [Environments](https://platform.openai.com/codex/cloud/environments)
    *   [Internet Access](https://platform.openai.com/codex/cloud/internet-access)

*   
Integrations
    *   [GitHub](https://platform.openai.com/codex/integrations/github)
    *   [Slack](https://platform.openai.com/codex/integrations/slack)
    *   [Linear](https://platform.openai.com/codex/integrations/linear)

*   
Codex Security
    *   [Overview](https://platform.openai.com/codex/security)
    *   [Setup](https://platform.openai.com/codex/security/setup)
    *   [Improving the threat model](https://platform.openai.com/codex/security/threat-model)
    *   [FAQ](https://platform.openai.com/codex/security/faq)

### Configuration

*   
Config File
    *   [Config Basics](https://platform.openai.com/codex/config-basic)
    *   [Advanced Config](https://platform.openai.com/codex/config-advanced)
    *   [Config Reference](https://platform.openai.com/codex/config-reference)
    *   [Sample Config](https://platform.openai.com/codex/config-sample)

*   [Speed](https://platform.openai.com/codex/speed)
*   [Rules](https://platform.openai.com/codex/rules)
*   [Hooks](https://platform.openai.com/codex/hooks)
*   [AGENTS.md](https://platform.openai.com/codex/guides/agents-md)
*   [MCP](https://platform.openai.com/codex/mcp)
*   
Plugins
    *   [Overview](https://platform.openai.com/codex/plugins)
    *   [Build plugins](https://platform.openai.com/codex/plugins/build)

*   [Skills](https://platform.openai.com/codex/skills)
*   [Subagents](https://platform.openai.com/codex/subagents)

### Administration

*   [Authentication](https://platform.openai.com/codex/auth)
*   [Agent approvals & security](https://platform.openai.com/codex/agent-approvals-security)
*   [Remote connections](https://platform.openai.com/codex/remote-connections)
*   
Enterprise
    *   [Admin Setup](https://platform.openai.com/codex/enterprise/admin-setup)
    *   [Governance](https://platform.openai.com/codex/enterprise/governance)
    *   [Managed configuration](https://platform.openai.com/codex/enterprise/managed-configuration)

*   [Windows](https://platform.openai.com/codex/windows)

### Automation

*   [Non-interactive Mode](https://platform.openai.com/codex/noninteractive)
*   [Codex SDK](https://platform.openai.com/codex/sdk)
*   [App Server](https://platform.openai.com/codex/app-server)
*   [MCP Server](https://platform.openai.com/codex/guides/agents-sdk)
*   [GitHub Action](https://platform.openai.com/codex/github-action)

### Learn

*   [Best practices](https://platform.openai.com/codex/learn/best-practices)
*   [Videos](https://platform.openai.com/codex/videos)
*   [Community](https://platform.openai.com/community)
*   
Blog
    *   [Using skills to accelerate OSS maintenance](https://platform.openai.com/blog/skills-agents-sdk)
    *   [Building frontend UIs with Codex and Figma](https://platform.openai.com/blog/building-frontend-uis-with-codex-and-figma)
    *   [View all](https://platform.openai.com/blog/topic/codex)

*   
Cookbooks
    *   [Codex Prompting Guide](https://platform.openai.com/cookbook/examples/gpt-5/codex_prompting_guide)
    *   [Modernizing your Codebase with Codex](https://platform.openai.com/cookbook/examples/codex/code_modernization)
    *   [View all](https://platform.openai.com/cookbook/topic/codex)

*   [Building AI Teams](https://platform.openai.com/codex/guides/build-ai-native-engineering-team)

### Releases

*   [Changelog](https://platform.openai.com/codex/changelog)
*   [Feature Maturity](https://platform.openai.com/codex/feature-maturity)
*   [Open Source](https://platform.openai.com/codex/open-source)

*   [Home](https://platform.openai.com/codex/use-cases)
*   [Collections](https://platform.openai.com/codex/use-cases/collections)

 Apps SDK  Commerce 

*   [Home](https://platform.openai.com/apps-sdk)
*   [Quickstart](https://platform.openai.com/apps-sdk/quickstart)

### Core Concepts

*   [MCP Apps in ChatGPT](https://platform.openai.com/apps-sdk/mcp-apps-in-chatgpt)
*   [MCP Server](https://platform.openai.com/apps-sdk/concepts/mcp-server)
*   [UX principles](https://platform.openai.com/apps-sdk/concepts/ux-principles)
*   [UI guidelines](https://platform.openai.com/apps-sdk/concepts/ui-guidelines)

### Plan

*   [Research use cases](https://platform.openai.com/apps-sdk/plan/use-case)
*   [Define tools](https://platform.openai.com/apps-sdk/plan/tools)
*   [Design components](https://platform.openai.com/apps-sdk/plan/components)

### Build

*   [Set up your server](https://platform.openai.com/apps-sdk/build/mcp-server)
*   [Build your ChatGPT UI](https://platform.openai.com/apps-sdk/build/chatgpt-ui)
*   [Authenticate users](https://platform.openai.com/apps-sdk/build/auth)
*   [Manage state](https://platform.openai.com/apps-sdk/build/state-management)
*   [Monetize your app](https://platform.openai.com/apps-sdk/build/monetization)
*   [Examples](https://platform.openai.com/apps-sdk/build/examples)

### Deploy

*   [Deploy your app](https://platform.openai.com/apps-sdk/deploy)
*   [Connect from ChatGPT](https://platform.openai.com/apps-sdk/deploy/connect-chatgpt)
*   [Test your integration](https://platform.openai.com/apps-sdk/deploy/testing)
*   [Submit your app](https://platform.openai.com/apps-sdk/deploy/submission)

### Guides

*   [Optimize Metadata](https://platform.openai.com/apps-sdk/guides/optimize-metadata)
*   [Security & Privacy](https://platform.openai.com/apps-sdk/guides/security-privacy)
*   [Troubleshooting](https://platform.openai.com/apps-sdk/deploy/troubleshooting)

### Resources

*   [Changelog](https://platform.openai.com/apps-sdk/changelog)
*   [App submission guidelines](https://platform.openai.com/apps-sdk/app-submission-guidelines)
*   [Reference](https://platform.openai.com/apps-sdk/reference)

*   [Home](https://platform.openai.com/commerce)

### Guides

*   [Get started](https://platform.openai.com/commerce/guides/get-started)
*   [Best practices](https://platform.openai.com/commerce/guides/best-practices)

### File Upload

*   [Overview](https://platform.openai.com/commerce/specs/file-upload/overview)
*   [Products](https://platform.openai.com/commerce/specs/file-upload/products)

### API

*   [Overview](https://platform.openai.com/commerce/specs/api/overview)
*   [Feeds](https://platform.openai.com/commerce/specs/api/feeds)
*   [Products](https://platform.openai.com/commerce/specs/api/products)
*   [Promotions](https://platform.openai.com/commerce/specs/api/promotions)

 Showcase  Blog  Cookbook  Learn  Community 

*   [Home](https://platform.openai.com/showcase)
*   [API examples](https://platform.openai.com/showcase/api-examples)

*   [All posts](https://platform.openai.com/blog)

### Recent

*   [How Perplexity Brought Voice Search to Millions Using the Realtime API](https://platform.openai.com/blog/realtime-perplexity-computer)
*   [Designing delightful frontends with GPT-5.4](https://platform.openai.com/blog/designing-delightful-frontends-with-gpt-5-4)
*   [From prompts to products: One year of Responses](https://platform.openai.com/blog/one-year-of-responses)
*   [Using skills to accelerate OSS maintenance](https://platform.openai.com/blog/skills-agents-sdk)
*   [Building frontend UIs with Codex and Figma](https://platform.openai.com/blog/building-frontend-uis-with-codex-and-figma)

### Topics

*   [General](https://platform.openai.com/blog/topic/general)
*   [API](https://platform.openai.com/blog/topic/api)
*   [Apps SDK](https://platform.openai.com/blog/topic/apps-sdk)
*   [Audio](https://platform.openai.com/blog/topic/audio)
*   [Codex](https://platform.openai.com/blog/topic/codex)

*   [Home](https://platform.openai.com/cookbook)

### Topics

*   [Agents](https://platform.openai.com/cookbook/topic/agents)
*   [Evals](https://platform.openai.com/cookbook/topic/evals)
*   [Multimodal](https://platform.openai.com/cookbook/topic/multimodal)
*   [Text](https://platform.openai.com/cookbook/topic/text)
*   [Guardrails](https://platform.openai.com/cookbook/topic/guardrails)
*   [Optimization](https://platform.openai.com/cookbook/topic/optimization)
*   [ChatGPT](https://platform.openai.com/cookbook/topic/chatgpt)
*   [Codex](https://platform.openai.com/cookbook/topic/codex)
*   [gpt-oss](https://platform.openai.com/cookbook/topic/gpt-oss)

### Contribute

*   [Cookbook on GitHub](https://github.com/openai/openai-cookbook)

*   [Home](https://platform.openai.com/learn)
*   [Docs MCP](https://platform.openai.com/learn/docs-mcp)

### Categories

*   [Demo apps](https://platform.openai.com/learn/code)
*   [Videos](https://platform.openai.com/learn/videos)

### Topics

*   [Agents](https://platform.openai.com/learn/agents)
*   [Audio & Voice](https://platform.openai.com/learn/audio)
*   [Computer Use](https://platform.openai.com/learn/cua)
*   [Codex](https://platform.openai.com/learn/codex)
*   [Evals](https://platform.openai.com/learn/evals)
*   [gpt-oss](https://platform.openai.com/learn/gpt-oss)
*   [Fine-tuning](https://platform.openai.com/learn/fine-tuning)
*   [Image generation](https://platform.openai.com/learn/imagegen)
*   [Scaling](https://platform.openai.com/learn/scaling)
*   [Tools](https://platform.openai.com/learn/tools)
*   [Video generation](https://platform.openai.com/learn/videogen)

*   [Community](https://platform.openai.com/community)

### Programs

*   [Codex Ambassadors](https://platform.openai.com/community/codex-ambassadors)
*   [Codex for Students](https://platform.openai.com/community/students)
*   [Codex for Open Source](https://platform.openai.com/community/codex-for-oss)

### Events

*   [Meetups](https://platform.openai.com/community/meetups)
*   [Hackathon Support](https://platform.openai.com/community/hackathons)

*   [Forum](https://community.openai.com/)
*   [Discord](https://discord.com/invite/openai)

[API Dashboard](https://platform.openai.com/login)

### Get started

*   [Overview](https://platform.openai.com/api/docs)
*   [Quickstart](https://platform.openai.com/api/docs/quickstart)
*   [Models](https://platform.openai.com/api/docs/models)
*   [Pricing](https://platform.openai.com/api/docs/pricing)
*   [Libraries](https://platform.openai.com/api/docs/libraries)
*   [Latest: GPT-5.4](https://platform.openai.com/api/docs/guides/latest-model)
*   [Prompt guidance](https://platform.openai.com/api/docs/guides/prompt-guidance)

### Core concepts

*   [Text generation](https://platform.openai.com/api/docs/guides/text)
*   [Code generation](https://platform.openai.com/api/docs/guides/code-generation)
*   [Images and vision](https://platform.openai.com/api/docs/guides/images-vision)
*   [Audio and speech](https://platform.openai.com/api/docs/guides/audio)
*   [Structured output](https://platform.openai.com/api/docs/guides/structured-outputs)
*   [Function calling](https://platform.openai.com/api/docs/guides/function-calling)
*   [Responses API](https://platform.openai.com/api/docs/guides/migrate-to-responses)
*   [Using tools](https://platform.openai.com/api/docs/guides/tools)

### Agents SDK

*   [Overview](https://platform.openai.com/api/docs/guides/agents)
*   [Quickstart](https://platform.openai.com/api/docs/guides/agents/quickstart)
*   [Agent definitions](https://platform.openai.com/api/docs/guides/agents/define-agents)
*   [Models and providers](https://platform.openai.com/api/docs/guides/agents/models)
*   [Running agents](https://platform.openai.com/api/docs/guides/agents/running-agents)
*   [Sandbox agents](https://platform.openai.com/api/docs/guides/agents/sandboxes)
*   [Orchestration](https://platform.openai.com/api/docs/guides/agents/orchestration)
*   [Guardrails](https://platform.openai.com/api/docs/guides/agents/guardrails-approvals)
*   [Results and state](https://platform.openai.com/api/docs/guides/agents/results)
*   [Integrations and observability](https://platform.openai.com/api/docs/guides/agents/integrations-observability)
*   [Evaluate agent workflows](https://platform.openai.com/api/docs/guides/agent-evals)
*   [Voice agents](https://platform.openai.com/api/docs/guides/voice-agents)
*   
Agent Builder
    *   [Overview](https://platform.openai.com/api/docs/guides/agent-builder)
    *   [Node reference](https://platform.openai.com/api/docs/guides/node-reference)
    *   [Safety in building agents](https://platform.openai.com/api/docs/guides/agent-builder-safety)
    *   
ChatKit
        *   [Overview](https://platform.openai.com/api/docs/guides/chatkit)
        *   [Customize](https://platform.openai.com/api/docs/guides/chatkit-themes)
        *   [Widgets](https://platform.openai.com/api/docs/guides/chatkit-widgets)
        *   [Actions](https://platform.openai.com/api/docs/guides/chatkit-actions)
        *   [Advanced integrations](https://platform.openai.com/api/docs/guides/custom-chatkit)

### Tools

*   [Web search](https://platform.openai.com/api/docs/guides/tools-web-search)
*   [MCP and Connectors](https://platform.openai.com/api/docs/guides/tools-connectors-mcp)
*   [Skills](https://platform.openai.com/api/docs/guides/tools-skills)
*   [Shell](https://platform.openai.com/api/docs/guides/tools-shell)
*   [Computer use](https://platform.openai.com/api/docs/guides/tools-computer-use)
*   
File search and retrieval
    *   [File search](https://platform.openai.com/api/docs/guides/tools-file-search)
    *   [Retrieval](https://platform.openai.com/api/docs/guides/retrieval)

*   [Tool search](https://platform.openai.com/api/docs/guides/tools-tool-search)
*   
More tools
    *   [Apply Patch](https://platform.openai.com/api/docs/guides/tools-apply-patch)
    *   [Local shell](https://platform.openai.com/api/docs/guides/tools-local-shell)
    *   [Image generation](https://platform.openai.com/api/docs/guides/tools-image-generation)
    *   [Code interpreter](https://platform.openai.com/api/docs/guides/tools-code-interpreter)

### Run and scale

*   [Conversation state](https://platform.openai.com/api/docs/guides/conversation-state)
*   [Background mode](https://platform.openai.com/api/docs/guides/background)
*   [Streaming](https://platform.openai.com/api/docs/guides/streaming-responses)
*   [WebSocket mode](https://platform.openai.com/api/docs/guides/websocket-mode)
*   [Webhooks](https://platform.openai.com/api/docs/guides/webhooks)
*   [File inputs](https://platform.openai.com/api/docs/guides/file-inputs)
*   
Context management
    *   [Compaction](https://platform.openai.com/api/docs/guides/compaction)
    *   [Counting tokens](https://platform.openai.com/api/docs/guides/token-counting)
    *   [Prompt caching](https://platform.openai.com/api/docs/guides/prompt-caching)

*   
Prompting
    *   [Overview](https://platform.openai.com/api/docs/guides/prompting)
    *   [Prompt engineering](https://platform.openai.com/api/docs/guides/prompt-engineering)
    *   [Citation formatting](https://platform.openai.com/api/docs/guides/citation-formatting)

*   
Reasoning
    *   [Reasoning models](https://platform.openai.com/api/docs/guides/reasoning)
    *   [Reasoning best practices](https://platform.openai.com/api/docs/guides/reasoning-best-practices)

### Evaluation

*   [Getting started](https://platform.openai.com/api/docs/guides/evaluation-getting-started)
*   [Working with evals](https://platform.openai.com/api/docs/guides/evals)
*   [Prompt optimizer](https://platform.openai.com/api/docs/guides/prompt-optimizer)
*   [External models](https://platform.openai.com/api/docs/guides/external-models)
*   [Best practices](https://platform.openai.com/api/docs/guides/evaluation-best-practices)

### Realtime API

*   [Overview](https://platform.openai.com/api/docs/guides/realtime)
*   
Connect
    *   [WebRTC](https://platform.openai.com/api/docs/guides/realtime-webrtc)
    *   [WebSocket](https://platform.openai.com/api/docs/guides/realtime-websocket)
    *   [SIP](https://platform.openai.com/api/docs/guides/realtime-sip)

*   
Usage
    *   [Using realtime models](https://platform.openai.com/api/docs/guides/realtime-models-prompting)
    *   [Managing conversations](https://platform.openai.com/api/docs/guides/realtime-conversations)
    *   [MCP servers](https://platform.openai.com/api/docs/guides/realtime-mcp)
    *   [Webhooks and server-side controls](https://platform.openai.com/api/docs/guides/realtime-server-controls)
    *   [Managing costs](https://platform.openai.com/api/docs/guides/realtime-costs)
    *   [Realtime transcription](https://platform.openai.com/api/docs/guides/realtime-transcription)
    *   [Voice agents](https://platform.openai.com/api/docs/guides/voice-agents)

### Model optimization

*   [Optimization cycle](https://platform.openai.com/api/docs/guides/model-optimization)
*   
Fine-tuning
    *   [Supervised fine-tuning](https://platform.openai.com/api/docs/guides/supervised-fine-tuning)
    *   [Vision fine-tuning](https://platform.openai.com/api/docs/guides/vision-fine-tuning)
    *   [Direct preference optimization](https://platform.openai.com/api/docs/guides/direct-preference-optimization)
    *   [Reinforcement fine-tuning](https://platform.openai.com/api/docs/guides/reinforcement-fine-tuning)
    *   [RFT use cases](https://platform.openai.com/api/docs/guides/rft-use-cases)
    *   [Best practices](https://platform.openai.com/api/docs/guides/fine-tuning-best-practices)

*   [Graders](https://platform.openai.com/api/docs/guides/graders)

### Specialized models

*   [Image generation](https://platform.openai.com/api/docs/guides/image-generation)
*   [Video generation](https://platform.openai.com/api/docs/guides/video-generation)
*   [Text to speech](https://platform.openai.com/api/docs/guides/text-to-speech)
*   [Speech to text](https://platform.openai.com/api/docs/guides/speech-to-text)
*   [Deep research](https://platform.openai.com/api/docs/guides/deep-research)
*   [Embeddings](https://platform.openai.com/api/docs/guides/embeddings)
*   [Moderation](https://platform.openai.com/api/docs/guides/moderation)

### Going live

*   [Production best practices](https://platform.openai.com/api/docs/guides/production-best-practices)
*   
Latency optimization
    *   [Overview](https://platform.openai.com/api/docs/guides/latency-optimization)
    *   [Predicted Outputs](https://platform.openai.com/api/docs/guides/predicted-outputs)
    *   [Priority processing](https://platform.openai.com/api/docs/guides/priority-processing)

*   
Cost optimization
    *   [Overview](https://platform.openai.com/api/docs/guides/cost-optimization)
    *   [Batch](https://platform.openai.com/api/docs/guides/batch)
    *   [Flex processing](https://platform.openai.com/api/docs/guides/flex-processing)

*   [Accuracy optimization](https://platform.openai.com/api/docs/guides/optimizing-llm-accuracy)
*   
Safety
    *   [Safety best practices](https://platform.openai.com/api/docs/guides/safety-best-practices)
    *   [Safety checks](https://platform.openai.com/api/docs/guides/safety-checks)
    *   [Cybersecurity checks](https://platform.openai.com/api/docs/guides/safety-checks/cybersecurity)
    *   [Under 18 API Guidance](https://platform.openai.com/api/docs/guides/safety-checks/under-18-api-guidance)

### Legacy APIs

*   
Assistants API
    *   [Migration guide](https://platform.openai.com/api/docs/assistants/migration)
    *   [Deep dive](https://platform.openai.com/api/docs/assistants/deep-dive)
    *   [Tools](https://platform.openai.com/api/docs/assistants/tools)

### Resources

*   [Terms and policies](https://openai.com/policies)
*   [Changelog](https://platform.openai.com/api/docs/changelog)
*   [Your data](https://platform.openai.com/api/docs/guides/your-data)
*   [Permissions](https://platform.openai.com/api/docs/guides/rbac)
*   [Rate limits](https://platform.openai.com/api/docs/guides/rate-limits)
*   [Deprecations](https://platform.openai.com/api/docs/deprecations)
*   [MCP for deep research](https://platform.openai.com/api/docs/mcp)
*   [Developer mode](https://platform.openai.com/api/docs/guides/developer-mode)
*   
ChatGPT Actions
    *   [Introduction](https://platform.openai.com/api/docs/actions/introduction)
    *   [Getting started](https://platform.openai.com/api/docs/actions/getting-started)
    *   [Actions library](https://platform.openai.com/api/docs/actions/actions-library)
    *   [Authentication](https://platform.openai.com/api/docs/actions/authentication)
    *   [Production](https://platform.openai.com/api/docs/actions/production)
    *   [Data retrieval](https://platform.openai.com/api/docs/actions/data-retrieval)
    *   [Sending files](https://platform.openai.com/api/docs/actions/sending-files)

Copy Page

# Agents SDK

Build agents in code with the OpenAI Agents SDK and grow into more advanced runtime patterns as needed.

Copy Page

Sandbox agents are now available in the Python Agents SDK. Use them when your agent needs a container-based environment with files, commands, packages, ports, snapshots, and memory. [Read the Sandbox agents guide](https://platform.openai.com/api/docs/guides/agents/sandboxes).

Agents are applications that plan, call tools, collaborate across specialists, and keep enough state to complete multi-step work.

*   Use the **OpenAI client libraries** when you want direct API clients for model requests.
*   Use the **Agents SDK** pages when your application owns orchestration, tool execution, approvals, and state.
*   Use **Agent Builder** only when you specifically want the hosted workflow editor and ChatKit path.

## Get the Agents SDK

Use the GitHub repositories for installation, issues, examples, and language-specific reference details.

[TypeScript SDK Open the TypeScript SDK repository on GitHub.](https://github.com/openai/openai-agents-js)[Python SDK Open the Python SDK repository on GitHub.](https://github.com/openai/openai-agents-python)

## Choose your starting point

| If you want to | Start here | Why |
| --- | --- | --- |
| Build a code-first agent app | [Quickstart](https://platform.openai.com/api/docs/guides/agents/quickstart) | This is the shortest path to a working SDK integration. |
| Define one specialist cleanly | [Agent definitions](https://platform.openai.com/api/docs/guides/agents/define-agents) | Start here when you are still shaping the contract for a single agent. |
| Choose models, defaults, and transport | [Models and providers](https://platform.openai.com/api/docs/guides/agents/models) | Use this when model choice, provider setup, or transport strategy affects the workflow. |
| Understand the runtime loop and state | [Running agents](https://platform.openai.com/api/docs/guides/agents/running-agents) | This is where the agent loop, streaming, and continuation strategies live. |
| Run work in a container-based environment | [Sandbox agents](https://platform.openai.com/api/docs/guides/agents/sandboxes) | Use this when the agent needs files, commands, packages, snapshots, mounts, or provider links. |
| Design specialist ownership | [Orchestration and handoffs](https://platform.openai.com/api/docs/guides/agents/orchestration) | Use this when you need more than one agent and must decide who owns the reply. |
| Add validation or human review | [Guardrails and human review](https://platform.openai.com/api/docs/guides/agents/guardrails-approvals) | Use this when the workflow should block or pause before risky work continues. |
| Understand what a run returns | [Results and state](https://platform.openai.com/api/docs/guides/agents/results) | This page explains final output, resumable state, and next-turn surfaces. |
| Add hosted tools, function tools, or MCP | [Using tools](https://platform.openai.com/api/docs/guides/tools#usage-in-the-agents-sdk) and [Integrations and observability](https://platform.openai.com/api/docs/guides/agents/integrations-observability) | Tool semantics live in the platform tools docs; SDK-specific MCP and tracing live here. |
| Inspect and improve runs | [Integrations and observability](https://platform.openai.com/api/docs/guides/agents/integrations-observability) and [evaluate agent workflows](https://platform.openai.com/api/docs/guides/agent-evals) | Use traces for debugging first, then move into evaluation loops. |
| Build a voice-first workflow | [Voice agents](https://platform.openai.com/api/docs/guides/voice-agents) | Voice is still an SDK-first path because Agent Builder doesn’t support it. |

## Build with the SDK

Use the SDK track when your server owns orchestration, tool execution, state, and approvals. That path is the best fit when you want:

*   typed application code in TypeScript or Python
*   direct control over tools, MCP servers, and runtime behavior
*   custom storage or server-managed conversation strategies
*   tight integration with existing product logic or infrastructure

A typical SDK reading order is:

*   Start with [Quickstart](https://platform.openai.com/api/docs/guides/agents/quickstart) to get one working run on screen.
*   Use [Agent definitions](https://platform.openai.com/api/docs/guides/agents/define-agents) and [Models and providers](https://platform.openai.com/api/docs/guides/agents/models) to shape one specialist cleanly.
*   Continue to [Running agents](https://platform.openai.com/api/docs/guides/agents/running-agents), [Orchestration and handoffs](https://platform.openai.com/api/docs/guides/agents/orchestration), and [Guardrails and human review](https://platform.openai.com/api/docs/guides/agents/guardrails-approvals) as the workflow grows more complex.
*   Use [Results and state](https://platform.openai.com/api/docs/guides/agents/results) and [Integrations and observability](https://platform.openai.com/api/docs/guides/agents/integrations-observability) when application logic depends on the run object or deeper visibility into behavior.

## Use Agent Builder for the hosted workflow path

Use Agent Builder when you want OpenAI-hosted workflow creation, publishing, and ChatKit deployment. Those pages stay grouped together because they describe one product surface: building a workflow in the visual editor, publishing versions, embedding them, customizing the UI, and evaluating the results.

Voice agents are an exception: they live in the SDK track because Agent Builder doesn’t currently support voice workflows. Use [Voice agents](https://platform.openai.com/api/docs/guides/voice-agents) when you need speech-to-speech or chained voice pipelines.

