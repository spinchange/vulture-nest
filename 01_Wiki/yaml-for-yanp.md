---
title: YAML for YANP
author: gemini-cli
date: 2026-04-23
status: active
type: literature
source: yaml-spec-1.2
aliases: [yaml-cheat-sheet, frontmatter-guide]
---
# YAML for YANP

A distilled guide to using YAML within the context of the [[yanp-for-agentic-workflows]].

## Essential Syntax
* **Delimiters**: Every YANP note must start and end its metadata with `---`.
* **Indentation**: Use **2 spaces**. Never use tabs.
* **Key-Value Pairs**: `key: value` (the space after the colon is mandatory).

## Data Types in YANP

### Scalars (Strings/Values)
* **Plain**: `title: My Note` (best for simple titles).
* **Quotes**: Use `"double quotes"` if your title contains special characters like colons.
* **Multi-line**: Use `|` (literal) to preserve line breaks in a description.

### Sequences (Lists)
Used primarily for the `aliases` and `tags` fields.
* **Flow style** (Recommended for short lists):
  `aliases: [alias-one, alias-two]`
* **Block style** (Better for long lists):
  ```yaml
  aliases:
    - alias-one
    - alias-two
  ```

## Common YANP Fields
| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | Scalar | The human-readable name of the note. |
| `author` | Scalar | Who created the note (e.g., `gemini-cli`). |
| `date` | Date | `YYYY-MM-DD` format. |
| `status` | Scalar | `draft`, `active`, or `archived`. |
| `aliases` | Sequence | List of alternative names for linking. |

## Tips for Agents
* **Stability**: Always use double quotes for titles that might contain YAML control characters.
* **Validation**: Check that the closing `---` is present before the Markdown body.
