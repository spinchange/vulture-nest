# YAML 1.2.2 Specification Reference

YAML (YAML Ain’t Markup Language) is a human-friendly, Unicode-based data serialization language designed around common native data types of dynamic programming languages.

## Core Syntax Rules

*   **Indentation:** YAML uses whitespace indentation for structure. Tabs are **strictly forbidden** for indentation to ensure portability across different editors and systems.
*   **Case Sensitivity:** YAML is case-sensitive.
*   **Separation:** Tokens within a line are separated by whitespace.
*   **Comments:** Begin with the octothorpe (`#`) and continue to the end of the line. Comments must be separated from other tokens by whitespace.
*   **Document Separation:**
    *   `---` (three dashes): Directives end marker; signals the start of a document.
    *   `...` (three dots): Document end marker; signals the end of a document without starting a new one.

## Data Types (The Three Primitives)

YAML represents all data using three basic primitives:

### 1. Mappings (Hashes/Dictionaries)
Mappings represent an unordered association of unique keys to values.
*   **Block Style:** Uses a colon and space (`: `) to separate key and value.
    ```yaml
    name: Mark McGwire
    hr: 65
    ```
*   **Flow Style:** Uses curly braces and commas.
    ```yaml
    {name: Mark McGwire, hr: 65}
    ```

### 2. Sequences (Arrays/Lists)
Sequences represent an ordered series of entries.
*   **Block Style:** Each entry is indicated by a dash and space (`- `).
    ```yaml
    - Boston Red Sox
    - Detroit Tigers
    ```
*   **Flow Style:** Uses square brackets and commas.
    ```yaml
    [Boston Red Sox, Detroit Tigers]
    ```

### 3. Scalars (Strings/Numbers)
Scalars are opaque data presentable as Unicode characters.
*   **Plain Style:** Unquoted strings (e.g., `simple_string`).
*   **Quoted Styles:** 
    *   `"Double-quoted"`: Supports escape sequences (e.g., `\n`, `\t`).
    *   `'Single-quoted'`: Literal strings; only `'` is escaped by doubling it (`''`).
*   **Block Styles:**
    *   Literal (`|`): Preserves newlines.
    *   Folded (`>`): Converts single newlines to spaces.

---

## YAML Frontmatter Requirements

YAML frontmatter is a common pattern used in Markdown files to store metadata. Based on the YAML 1.2.2 specification, valid frontmatter must adhere to the following:

1.  **Placement:** It must be at the very beginning of the file.
2.  **Markers:** It must be wrapped in triple-dash delimiters.
    *   The opening `---` must be on the first line.
    *   The closing `---` (or sometimes `...`) signals the end of the YAML block and the start of the Markdown content.
3.  **Structure:** The content must be a valid YAML **Mapping**.
4.  **Encoding:** Should be UTF-8 encoded. A Byte Order Mark (BOM) is allowed but not recommended for UTF-8.
5.  **Syntax:**
    *   Keys should be followed by a colon and a space (`key: value`).
    *   Indentation must consist of spaces, not tabs.
    *   Complex values (like lists of tags or multi-line descriptions) must follow standard block or flow collection rules.

### Example Valid Frontmatter
```yaml
---
title: "YAML 1.2 Reference"
author: Jane Doe
tags: [reference, yaml, guide]
description: |
  This is a multi-line description
  that preserves newlines.
---
# Markdown Content Starts Here
```

## Recommended Schemas
*   **Failsafe Schema:** Guaranteed to work with any YAML document (Mapping, Sequence, String).
*   **JSON Schema:** Maps directly to JSON's basic types (Null, Boolean, Integer, Float).
*   **Core Schema (Default):** The recommended default for YAML 1.2, allowing for more human-readable scalars (e.g., `true`, `True`, `TRUE` are all booleans).
