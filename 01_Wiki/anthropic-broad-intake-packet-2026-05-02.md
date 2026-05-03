---
title: Anthropic Broad Intake Packet (2026-05-02)
author: codex
date: '2026-05-02'
status: active
type: fleeting
targets:
  - gemini
aliases:
  - anthropic-broad-intake-packet
  - gemini-anthropic-broad-intake
  - anthropic-batch-2-intake
---

# Anthropic Broad Intake Packet

## Role

You are **Scout**, not the canonical author for this run.

Your job is to prepare a **broad, execution-ready intake packet** for a new Anthropic / Claude documentation-ingestion run based on **current official Anthropic documentation**.

Do **not** write the final vault notes.
Do **not** stage raw corpus files.
Do **not** perform graph integration.

## Context

The vault now has a first bounded Anthropic batch centered on:

- authentication and request model
- Messages API structure
- streaming
- tool use
- errors and rate limits
- prompt caching

That batch is useful, but it is still mostly **API basics**.

What is needed now is a **broader official-doc intake plan** that moves the vault beyond introductory coverage into a stronger practical Claude reference lane.

## Objective

Produce a **broad but still operationally coherent** intake packet for Codex to execute through the proper ingestion pipeline.

For this run, optimize for **breadth more than usual**, while still avoiding open-ended sprawl.

## Source Policy

1. Use **official Anthropic / Claude documentation only**.
2. Verify from the **current live docs**, not memory.
3. Record **exact canonical URLs**.
4. If a page redirects, record the **resolved canonical target**.
5. Prefer implementation-facing documentation over marketing or product positioning.

## Coverage Areas

Include the most important current Anthropic documentation surfaces across:

### 1. Core API Foundations

- API overview
- authentication / headers / versioning
- Messages API
- streaming
- errors
- rate limits

### 2. Tool Use Depth

- define tools
- handle tool calls
- strict tool use
- parallel tool use
- tool-use conceptual model
- stop reasons if tightly connected

### 3. Context and Output Management

- prompt caching
- token counting
- context windows
- context editing / compaction if the current docs support it
- structured outputs / output formatting if the current docs support it

### 4. Model-Operational Guidance

- model selection / model list / model capabilities where practically relevant
- request-shaping details that affect real integrations
- provider-specific caveats that differ from generic LLM APIs

### 5. Optional but Include if Clearly First-Party and Practically Important

- server tools
- Tool Runner / SDK abstractions
- files / vision only if they clearly belong in the same practical direct-Claude lane

## Out of Scope Unless Tightly Necessary

- marketing / product overview pages
- consumer Claude app UX pages
- safety / policy pages not needed to explain API behavior
- partner-platform docs unless needed only as a contrast note
- speculative model-comparison content
- enterprise sales content

## Constraints

1. Do not write the canonical notes.
2. Do not synthesize the final literature/permanent note set.
3. Do not create or edit vault files.
4. Do not broaden into “everything Anthropic has published.”
5. Keep the batch broad, but organize it into sensible sub-batches that Codex can execute cleanly.
6. Distinguish documented behavior from your inference or recommendation.
7. Prefer practical implementation value over conceptual fluff.

## Required Output

Return **one structured intake packet** with these exact sections:

### 1. Gap

A short paragraph explaining what is missing in the current Anthropic coverage and why a broader batch is justified now.

### 2. Recommended Batch Structure

Break the broader intake into **3–6 sub-batches**.

For each sub-batch give:

- name
- why it belongs
- priority: `high`, `medium`, or `low`

### 3. Source Set

A flat bullet list of exact official URLs.

For each source include:

- exact title
- why it is included
- which sub-batch it belongs to

### 4. Canonical Raw Corpus Plan

A flat bullet list of the exact files that should be created under `00_Raw/anthropic/`.

Name them in a way that is:

- stable
- attributable
- easy to map back to source pages

### 5. Note Plan

A flat bullet list of:

- literature note paths
- permanent note paths
- one-line purpose for each

You may propose **more than one literature note** if the broader batch justifies it.

### 6. Graph Plan

A flat bullet list of the existing vault notes, MOCs, indexes, or bridge notes that should likely be updated.

### 7. Out of Scope

A flat bullet list of what should explicitly not be included in this run.

### 8. Risks and Drift Points

A flat bullet list of:

- places the docs are likely to change quickly
- places where a synthesizer might overgeneralize
- places where provider-specific details are likely to be flattened incorrectly

### 9. Recommended Execution Order

Give the order Codex should ingest the sub-batches in, and explain why.

## Final Reminder

This is an **intake-planning pass only**.

Do not:

- write the vault notes
- write the raw corpus
- perform graph integration

Your job is to hand Codex a **broad, current, official-source, execution-ready packet**.
