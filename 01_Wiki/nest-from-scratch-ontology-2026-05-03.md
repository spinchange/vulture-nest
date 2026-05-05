---
title: Nest From-Scratch Ontology
author: codex
date: 2026-05-03
status: active
type: fleeting
aliases:
  - vulture-nest-from-scratch
  - nest-continuity-ontology
  - persistent-cognitive-environment
---

# Nest From-Scratch Ontology

This note captures a from-scratch reframing of what Vulture Nest is trying to be at its most basic level.

The main shift is:

Vulture Nest should be understood less as a wiki that contains notes and more as a persistent cognitive environment for humans and agents.

That means notes are not the center of the system. They are one artifact class among several.

## Why This Reframe Matters

The current Nest already does more than store knowledge.

It also:

- coordinates work across sessions
- preserves seams and handoffs
- supports dialogue and iterative reasoning
- generates outputs through tools and execution
- turns interaction into durable state

That combination suggests the Nest is not just:

- a repository
- a workflow tracker
- a wiki

It is a continuity system for ongoing cognition and execution.

## The Core Modes

At minimum, the Nest appears to operate in three modes:

### 1. Artifact Mode

The system creates, edits, links, and preserves artifacts.

Examples:

- permanent notes
- literature notes
- fleeting notes
- handoffs
- logs
- generated files

### 2. Interaction Mode

The system hosts live inquiry through discussion, debate, prompting, and back-and-forth refinement.

Examples:

- human-agent conversations
- turn-based debate artifacts
- review loops
- synthesis passes

### 3. Execution Mode

The system runs actions that test, transform, or produce state.

Examples:

- scripts
- builds
- validation passes
- indexing
- REPL-like experimentation

## The Deeper Primitives

If the Nest were designed from scratch around what it actually does, the primitive entities would likely be:

- artifact
- interaction
- execution
- memory
- state
- transition
- provenance
- continuation

These are more fundamental than "note" alone.

## What The System Really Has To Answer

A from-scratch Nest would need to answer:

- what enters the system?
- what kinds of things can exist in it?
- what transformations are allowed?
- what becomes durable?
- what remains provisional?
- what expires?
- what can be resumed later?
- what is authored directly?
- what is computed or derived?

Those questions are more basic than note taxonomy by itself.

## Proposed Core Ontology

### Artifact

A durable or semi-durable unit of recorded state.

Examples:

- note
- handoff
- seam
- log entry
- generated report

### Interaction

A live exchange that produces interpretation, challenge, or decision.

Examples:

- conversation
- debate turn
- review
- synthesis pass

### Execution

An action taken against the environment that produces evidence or changes state.

Examples:

- script run
- validator pass
- crawl
- build
- REPL experiment

### Memory

The retained portion of system state that is meant to persist and be reused.

Examples:

- durable wiki notes
- indexed source records
- session traces worth preserving

### Transition

A rule or pathway by which one thing becomes another.

Examples:

- source intake -> literature note
- literature note -> permanent note
- active discussion -> RFC
- session seam -> resumed work
- experiment -> accepted result or discard

### Continuation

The ability for work, thought, or context to be resumed by a human or another agent without starting over.

This may be the Nest's deepest function.

## The Key Design Insight

The important thing is not just that artifacts exist.

The important thing is that:

- interactions generate artifacts
- artifacts constrain later interactions
- executions test or change the shared state
- memory preserves what should survive
- continuation lets work move across time, sessions, and agents

That loop is closer to the Nest's actual essence than "a wiki with notes."

## If Starting Over Entirely

The cleaner aim would be:

Build a persistent cognitive environment for humans and agents, where artifacts, interactions, and executions share one continuity layer.

From that aim, notes become one part of a larger system instead of the foundational assumption.

## Implications For Future Spec Work

This reframing suggests future specs should distinguish at least:

- artifact schema
- interaction protocol
- execution surfaces
- memory/promotion rules
- continuation and handoff rules

It also suggests that frontmatter and note taxonomy alone will never fully model the Nest, because some of its core behavior lives in interaction and execution, not only in documents.
