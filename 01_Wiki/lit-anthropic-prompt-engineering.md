---
title: "Literature: Anthropic Prompt Engineering Best Practices"
author: gpt-5.4
date: 2026-05-20
status: active
aliases:
  - lit-anthropic-prompt-engineering
  - lit-claude-prompting-best-practices
type: literature
source: "00_Raw/anthropic/prompt-engineering-best-practices.md"
---

# Literature: Anthropic Prompt Engineering Best Practices

Synthesis of Anthropic's current prompt-engineering documentation, with emphasis on the official guidance for **XML tags as prompt-structure delimiters**.

## Source scope

Primary canonical pages captured in `00_Raw/anthropic/prompt-engineering-best-practices.md`:
- Prompt engineering overview
- Prompting best practices
- Best-practices subsections on XML tags and examples

The local Anthropic raw corpus also contains a related tool-use note (`tool-use-define-tools.md`) that references `<examples>` in prompts.

## Durable findings

**XML tags are an official Claude prompting technique, not a community superstition.** Anthropic's prompt-engineering overview explicitly lists *XML structuring* alongside clarity, examples, role prompting, thinking, and prompt chaining. That places tag-based structure inside the provider's mainstream guidance rather than in an unofficial cookbook corner.

**Anthropic frames XML tags as ambiguity reducers.** The core claim is not that Claude expects valid XML, but that tagged regions help it parse mixed prompt components — instructions, context, examples, and variable inputs — without confusing one for another.

**The operational role of tags is boundary-marking.** The examples Anthropic gives (`<instructions>`, `<context>`, `<input>`) show that tags are being used as semantic separators. The value comes from making prompt regions legible to the model, not from machine-validated markup.

**Hierarchy matters when the source material is nested.** Anthropic explicitly recommends nested tags where the content is naturally hierarchical, such as `<documents>` containing repeated `<document index="n">` blocks. This implies a prompt-design pattern: mirror the structure of the task domain in the prompt wrapper.

**Examples should be tagged too.** Anthropic's best-practices page recommends wrapping few-shot examples in `<example>` tags and grouping them under `<examples>`. This keeps demonstrations separate from instructions, reducing contamination between "what to do" and "what prior examples look like."

**Consistency matters more than any special vocabulary.** The docs recommend using consistent, descriptive tag names. The durable lesson is not "use these exact tags," but "maintain stable semantic boundaries across the whole prompt."

## Non-findings / important limits

- Anthropic does **not** present XML tags as an API-level schema feature.
- The guidance does **not** require valid XML documents or parser-grade well-formedness.
- The docs do **not** imply that arbitrary tagging substitutes for clear instructions; tags are one structuring technique within a broader prompting discipline.

## Relationship to other Anthropic notes

This note fills a gap in the vault's Anthropic cluster: existing notes cover Messages, tool use, streaming, thinking, prompt caching, and managed agents, but not the provider's explicit guidance for prompt **internal structure**.

The pre-existing local raw note on tool use already hinted at this by recommending `<examples>` in prompts. The new prompt-engineering source turns that hint into an explicit design pattern.

## See also

- [[anthropic-xml-prompt-structuring]]
- [[anthropic-messages-api]]
- [[anthropic-tool-use]]
- [[lit-anthropic-messages-api]]
- [[anthropic-moc]]
