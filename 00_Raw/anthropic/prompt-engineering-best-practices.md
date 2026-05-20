# Anthropic Prompt Engineering Best Practices (XML-tag excerpt)

Captured from Anthropic Claude API Docs on 2026-05-20.

## Canonical URLs
- Overview: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview
- Best practices: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- XML section anchor: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#structure-prompts-with-xml-tags

## Prompt engineering overview

Anthropic's prompt engineering overview explicitly positions **XML structuring** as one of the standard prompting techniques in the current API docs:

> All prompting techniques — from clarity and examples to XML structuring, role prompting, thinking, and prompt chaining — are covered in Prompting best practices. That's the living reference; start there.

## Prompting best practices — Structure prompts with XML tags

> XML tags help Claude parse complex prompts unambiguously, especially when your prompt mixes instructions, context, examples, and variable inputs. Wrapping each type of content in its own tag (e.g. <instructions>, <context>, <input>) reduces misinterpretation.

Best practices excerpt:
- Use consistent, descriptive tag names across your prompts.
- Nest tags when content has a natural hierarchy (documents inside `<documents>`, each inside `<document index="n">`).

## Prompting best practices — Use examples effectively

Anthropic's same guide also recommends wrapping examples in XML-like tags:

> Structured: Wrap examples in <example> tags (multiple examples in <examples> tags) so Claude can distinguish them from instructions.

Additional note from the guide:
- Include 3–5 examples for best results.

## Related local raw source already present

`00_Raw/anthropic/tool-use-define-tools.md` already contains an Anthropic tool-use guidance passage that says:
- you can guide response style and content through your system prompts and by providing `<examples>` in your prompts
- the assistant's natural-language preambles should not be parsed as strict formatting contracts
