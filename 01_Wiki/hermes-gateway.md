---
title: Hermes Gateway
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-messaging-gateway
  - multi-platform-agent-daemon
type: permanent
---
# Hermes Gateway

[[hermes-gateway]] is the daemon layer that projects a single Hermes agent into messaging platforms such as Telegram, Discord, Slack, Signal, Matrix, and email. It turns a terminal-native agent into a **persistent multi-platform service** without changing the underlying tool-using agent loop.

## Core idea

The gateway separates two concerns:
- **agent cognition** — the normal Hermes conversation loop, tools, memory, skills, and sessions
- **transport** — how user messages arrive and where responses are delivered

Because the transport layer is separate, the same Hermes substrate can operate through many chat surfaces while preserving the same long-term context and tool access.

## What the gateway does

1. receives inbound messages from a platform adapter
2. routes them into a Hermes session
3. runs the agent with its normal tools
4. returns the final response to the originating chat or configured home channel

This makes the gateway a kind of **protocol bridge from messaging ecosystems into an agent runtime**.

## Distinguish gateway from tool gateway

Hermes has two different "gateway" ideas:
- [[hermes-gateway]] — chat transport and daemonization
- the Nous Tool Gateway — managed execution backends for tools such as web search, browser automation, image generation, and TTS

The first moves messages. The second moves tool calls.

## Why it matters

Most assistants exposed on messaging platforms are reduced-capability bots. Hermes instead keeps the full agent intact:
- the Telegram or Discord surface is not a separate toy bot
- it is the same agent that could also run in the CLI
- memory, skills, cron, and tool use remain available

So the gateway is what turns Hermes from "an assistant you launch" into "an agent that stays reachable."

## Gateway as daemon substrate

The gateway is normally run as a background service. That matters because it also anchors other durable behaviors:
- scheduled cron execution
- long-lived platform authorization state
- home-channel delivery
- background messaging notifications

This makes [[hermes-gateway]] an instance of the [[daemon-design-pattern]] applied to an agent runtime.

## Session continuity across surfaces

The important invariant is not that every platform shares one giant transcript, but that they share one **context substrate**:
- common skills inventory
- common memory store
- common model/provider configuration
- common tool layer
- common durable state, unless isolated by profile

This means a Hermes gateway surface is best thought of as **another entry point into the same agent environment**, not as a separate bot implementation.

## Profiles and isolation

When Hermes uses [[hermes-gateway]] with [[hermes-agent]] profiles, each profile can run its own gateway process and bot identity. That allows multiple independent long-lived agents on one machine without mixing sessions, skills, or memory.

## See Also
- [[hermes-agent]]
- [[hermes-bounded-memory]]
- [[daemon-design-pattern]]
- [[agentic-protocols]]
- [[mcp-moc]]
- [[agent-knowledge-vault]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\skills\autonomous-ai-agents\hermes-agent\SKILL.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\features\tool-gateway.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\profiles.md`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\website\docs\user-guide\features\cron.md`
