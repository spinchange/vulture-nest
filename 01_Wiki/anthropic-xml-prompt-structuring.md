---
title: Anthropic XML Prompt Structuring
author: gpt-5.4
date: 2026-05-20
status: active
aliases:
  - claude-xml-tags
  - xml-prompt-structuring
  - claude-prompt-tagging
type: permanent
source: "[[lit-anthropic-prompt-engineering]]"
---

# Anthropic XML Prompt Structuring

**Anthropic XML prompt structuring** is the practice of using lightweight XML-like tags to separate prompt regions such as instructions, context, inputs, and examples so Claude can parse mixed prompt material with less ambiguity.

## Core idea

The tags are not the payload; they are the **boundary markers** around the payload.

A prompt that mixes many roles — what the model should do, what background it should use, what examples it should imitate, and what live input it should transform — becomes easier for Claude to interpret when each region is explicitly labeled.

## What problem it solves

Without separators, prompts often blur together:
- instructions can look like examples
- examples can look like fresh user input
- reference material can be mistaken for authoritative directions
- repeated documents can collapse into one undifferentiated blob

XML-style tags reduce that confusion by making region boundaries explicit.

## Typical pattern

```text
<instructions>
Return a concise extraction of the claims.
</instructions>

<context>
The source may contain quoted objections and cited counterarguments.
</context>

<examples>
  <example>
    <input>...</input>
    <output>...</output>
  </example>
</examples>

<input>
...
</input>
```

The exact tag vocabulary is flexible. Anthropic's durable recommendation is to choose **descriptive names** and use them **consistently**.

## Hierarchy mirrors task structure

When the task itself is hierarchical, the prompt wrapper should be hierarchical too.

Anthropic's own example pattern — `<documents>` containing repeated `<document index="n">` items — suggests a general rule: represent collections as containers and members as repeated child blocks. This is especially useful for document comparison, retrieval synthesis, and multi-example prompting.

## Tagged examples are a separate pattern

A specific sub-pattern is wrapping demonstrations in `<example>` / `<examples>` tags. This separates instructional examples from the actual live task and reduces the chance that Claude confuses demonstrations with operative input.

## What this is not

- It is **not** an API-native schema contract like JSON Schema for tools.
- It is **not** a requirement that the prompt be valid XML.
- It is **not** a substitute for clear instructions or relevant examples.

So the right mental model is **semantic markup for model legibility**, not machine-checked markup for strict parsing.

## Why it belongs in the Anthropic cluster

Anthropic's direct API is block-structured at the message level, but much prompt complexity still lives *inside* text blocks. XML-style prompt structuring is one of the provider's explicit techniques for organizing that internal text-layer complexity.

That makes it adjacent to:
- [[anthropic-messages-api]] for the outer transport contract
- [[anthropic-tool-use]] for structured capability calls
- [[anthropic-prompt-caching]] for stable prompt-prefix reuse

## See also

- [[lit-anthropic-prompt-engineering]]
- [[anthropic-xml-tags-cheat-sheet]]
- [[anthropic-messages-api]]
- [[anthropic-tool-use]]
- [[anthropic-prompt-caching]]
- [[chat-templates]]
