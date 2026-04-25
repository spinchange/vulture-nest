---
tags:
  - meta
  - agents
  - ideas
  - workflow
source: codex
hostname: DESKTOP-004IHBK
date: 2026-03-13
status: active
---

# Agent Knowledge Vault

A shared, model-agnostic knowledge base that any AI agent (Claude, Gemini, Codex, and humans) can read from and write to. Built on plain Markdown in a Minimal Notes vault. Not owned by any one tool or provider.

## Why This Is Different

Existing agent memory systems are fragmented and siloed:

- Claude has project memory
- Gemini has native skill and memory workflows
- Codex has local skills and session context
- none of them interoperate by default

This vault is a layer above all of them: a living, collaboratively maintained knowledge graph where humans and multiple agents are first-class contributors.

## What Lives Here

- user preferences and workflow notes
- project state and rationale
- tool and skill documentation
- cross-session continuity notes
- operational conventions for how agents should write and read

## Hard Problems

- trust and provenance
- staleness
- authority when agents disagree
- keeping write conventions stable across tools

## What Helps

- Git for auditability and rollback
- frontmatter for a small but meaningful metadata contract
- wiki-links for graph navigation
- explicit note conventions so agents do not drift into incompatible styles

## Adopted Convention

The canonical write standard is now defined in [[agent-note-conventions]].

Highlights:

- standalone durable agent notes require `author`, `date`, and `status`
- `hostname` and `tags` are strongly recommended
- agent-authored notes default to `status: draft` unless there is a reason to mark them otherwise
- prose should be distilled and durable, not transcript-like
- metadata should stay minimal and useful rather than decorative

## Session Distillation

A key workflow for building this vault over time is session distillation: convert a working session into durable notes and follow-up actions. See [[distill-session-skill]].

## Status

Active concept with an adopted note-writing convention and cross-agent implementation in progress.
