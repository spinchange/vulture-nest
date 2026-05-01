---
title: "Literature: YAML 1.2.2 Specification"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: "00_Raw/reference/yaml-spec-1.2.md"
aliases: ["YAML Reference", "YAML 1.2.2 Spec"]
---

# Literature: YAML 1.2.2 Specification

**YAML** (YAML Ain’t Markup Language) is a human-friendly, Unicode-based data serialization language designed for clarity and compatibility with dynamic programming languages.

## Core Syntax Rules
- **Indentation**: Whitespace only; **tabs are strictly forbidden**.
- **Structure**: Uses a combination of Mappings (key-value), Sequences (lists), and Scalars (strings/numbers).
- **Markers**:
    - `---`: Signals the start of a document or directive end.
    - `...`: Signals the end of a document.

## Data Primitives
1. **Mappings**: Block style (key: value) or flow style ({key: value}).
2. **Sequences**: Block style (- item) or flow style ([item1, item2]).
3. **Scalars**: Plain, double-quoted (supports escapes), single-quoted (literal), or block style (Literal `|` vs. Folded `>`).

## Frontmatter Requirements
The specification defines the standard pattern for Markdown metadata:
1. **Placement**: Must be at the very beginning of the file.
2. **Delimiters**: Must be wrapped in triple-dash `---` markers.
3. **Mapping**: The content must be a valid YAML Mapping.
4. **Encoding**: UTF-8 preferred.

---
## See Also
- [[yanp-for-agentic-workflows]]
- [[agent-note-conventions]]
- [[powershell-moc]]
