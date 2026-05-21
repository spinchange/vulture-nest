---
title: Anthropic XML Tags Cheat Sheet
author: gpt-5.4
date: 2026-05-20
status: active
aliases:
  - claude-xml-tags-cheat-sheet
  - anthropic-xml-cheat-sheet
  - claude-prompt-tag-cheat-sheet
type: permanent
source: "[[lit-anthropic-prompt-engineering]]"
---

# Anthropic XML Tags Cheat Sheet

A compact reference for using **XML-style prompt tags** with Claude.

## Canonical skeleton

```text
<instructions>
State exactly what Claude should do.
</instructions>

<context>
Background facts, constraints, or domain assumptions.
</context>

<examples>
  <example>
    <input>Example input</input>
    <output>Example output</output>
  </example>
</examples>

<input>
The live task or source material.
</input>
```

## Recommended tag roles

- `<instructions>` — operative directions
- `<context>` — non-operative background
- `<examples>` — container for demonstrations
- `<example>` — one demonstration pair or case
- `<input>` — the live item Claude should process
- `<documents>` / `<document>` — repeated source documents

The exact names are flexible. Anthropic's stable recommendation is to use **descriptive tags consistently**.

## Good default patterns

### Single task

```text
<instructions>
Summarize the argument in 5 bullets.
</instructions>

<input>
...
</input>
```

### Task with background constraints

```text
<instructions>
Extract safety-relevant claims only.
</instructions>

<context>
Ignore marketing language and rhetorical flourishes.
</context>

<input>
...
</input>
```

### Few-shot prompting

```text
<instructions>
Rewrite each passage in plain language.
</instructions>

<examples>
  <example>
    <input>The physician commenced the procedure.</input>
    <output>The doctor began the procedure.</output>
  </example>
</examples>

<input>
The committee rendered its determination.
</input>
```

### Multi-document prompting

```text
<instructions>
Compare the documents and list disagreements.
</instructions>

<documents>
  <document index="1">
    ...
  </document>
  <document index="2">
    ...
  </document>
</documents>
```

## Do / don't

**Do**
- keep each region semantically distinct
- use nested tags when the source material is naturally nested
- separate examples from live input
- keep tag names stable throughout the prompt

**Don't**
- rely on tags to replace unclear instructions
- mix demonstrations and live data in the same block
- treat this as a strict parser contract
- assume the prompt must be valid XML

## Mental model

Think of XML tags here as **legibility markup for the model**, not as a machine-validated schema. The goal is to make prompt boundaries obvious so Claude does not confuse instructions, context, examples, and live input.

## See also

- [[lit-anthropic-prompt-engineering]]
- [[anthropic-xml-prompt-structuring]]
- [[anthropic-messages-api]]
- [[chat-templates]]
