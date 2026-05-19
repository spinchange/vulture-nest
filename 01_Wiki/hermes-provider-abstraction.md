---
title: Hermes Provider Abstraction
author: gpt-5.4
date: 2026-05-18
status: active
aliases:
  - hermes-provider-profiles
  - hermes-model-routing
  - hermes-provider-layer
type: permanent
---
# Hermes Provider Abstraction

[[hermes-provider-abstraction]] names the layer that lets Hermes swap models and inference backends without rewriting the rest of the agent loop. The key idea is to make providers **descriptive profiles plus runtime state**, not hardwired branches spread across every call site.

## Core idea

Hermes separates three concerns:
1. **Provider description** — what a provider is, how it authenticates, what API mode it speaks, and what request quirks it has.
2. **Runtime resolution** — which provider/model pair is active right now for the main conversation or for an auxiliary task.
3. **Live switching** — how a running agent updates clients, prompt-caching behavior, and compression metadata when the provider changes mid-session.

This is what makes [[hermes-agent]] meaningfully provider-agnostic rather than merely "OpenAI-compatible by default."

## Provider profiles as declarative metadata

The `ProviderProfile` base class in `providers/base.py` is the conceptual center of the abstraction.

A profile declares:
- provider identity and aliases
- `api_mode` such as `chat_completions`, `anthropic_messages`, or other transport contracts
- auth style and environment variables
- model-catalog endpoints
- client-level defaults such as headers
- request-level quirks such as fixed or omitted temperature
- provider hooks like `prepare_messages()`, `build_extra_body()`, and `build_api_kwargs_extras()`

The important architectural move is explicit in the source: profiles are **declarative**. They describe behavior, but they do not own client lifecycle, credential rotation, or streaming loops. Those remain in the live agent runtime.

## Runtime switching as a first-class operation

Hermes does not treat model changes as static startup configuration only. `agent_runtime_helpers.switch_model()` performs an in-place runtime swap.

When a model switch happens, Hermes updates:
- `agent.model`, `agent.provider`, `agent.base_url`, and `agent.api_mode`
- the active SDK client (`OpenAI`-style or Anthropic client path)
- prompt-caching flags
- the context compressor's model metadata and context length
- `_primary_runtime`, which persists the new runtime across future turns
- the fallback chain, pruning entries that point back to the provider the user just left

That means provider abstraction in Hermes is not just a configuration convenience. It is a **live-control surface**.

## Main runtime versus auxiliary runtimes

Hermes also separates the primary conversational runtime from side-task runtimes.

`agent/auxiliary_client.py` implements a shared router for auxiliary work such as:
- context compression
- session search
- web extraction
- vision analysis
- browser vision

Its resolution chain can use:
- the user's current main provider/model
- OpenRouter
- Nous Portal
- a custom OpenAI-compatible endpoint
- native Anthropic
- selected direct API-key providers

So Hermes has two related but distinct abstractions:
- the **main runtime**, which owns the conversation
- the **auxiliary runtime router**, which chooses cost-appropriate or capability-appropriate side models

This is a deeper abstraction than systems where every secondary task silently reuses the main model.

## API mode as the real transport contract

A subtle but important detail is that Hermes often reasons in terms of `api_mode`, not brand name.

Why this matters:
- multiple providers can speak an OpenAI-style chat interface
- some providers need Anthropic-style messages semantics
- provider names alone are not enough to determine request shape
- a custom endpoint may look like one ecosystem while being branded as another

So `api_mode` is the practical transport contract that the runtime uses to decide how requests are built and which client path is valid.

## Guardrails against provider leakage

The implementation contains several defensive checks that show what can go wrong in a multi-provider runtime:
- Anthropic fallback tokens are only used for the native Anthropic provider, so Hermes does not accidentally send Anthropic credentials to third-party Anthropic-compatible endpoints.
- When switching providers, stale `base_url` state is explicitly prevented from leaking forward.
- Kimi/Moonshot models can require temperature omission rather than a fixed float, so Hermes treats "don't send this field" as a first-class behavior.
- Context-compressor metadata is refreshed on model switch so the summarization threshold tracks the new context window.

These are the kinds of details that distinguish a true provider abstraction from a thin wrapper over one SDK.

## Architectural consequence

[[hermes-provider-abstraction]] turns the model layer into a **replaceable substrate** beneath a stable agent shell. The user-facing continuity of Hermes comes from memory, skills, tools, sessions, and gateways; the provider layer is designed so those higher layers survive model swaps.

That is why Hermes can be understood as "persistent context around interchangeable models" rather than "a chat app for one API."

## See Also
- [[hermes-agent]]
- [[hermes-profiles]]
- [[hermes-prompt-assembly]]
- [[hermes-context-compression]]
- [[lit-hermes-architecture]]
- [[spec-hermes-agent-loop]]
- [[anthropic-moc]]
- [[anthropic-prompt-caching]]

## References
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\providers\base.py`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\agent\auxiliary_client.py`
- Source: `C:\Users\executor\AppData\Local\hermes\hermes-agent\agent\agent_runtime_helpers.py`
