---
title: Python JSON
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [python-serialization-json, json-module]
---
# Python JSON

The `json` module encodes Python objects to JSON text and decodes JSON text back into Python data structures. It is the default interchange layer for APIs, tool calling, and many agent logs.

## Core Concepts
- `dump` and `dumps` serialize to a file-like object or string.
- `load` and `loads` deserialize from a file-like object or string.
- Custom serialization uses `default=` or a `JSONEncoder` subclass.
- Custom decoding uses hooks such as `object_hook`, `object_pairs_hook`, and numeric parsers.

## Significance for Agents
- Tool-calling payloads and model I/O often cross JSON boundaries, so serialization choices affect determinism and recoverability.
- The module accepts some JavaScript-style numeric values by default, which is convenient but not fully strict JSON behavior.
- Parsing untrusted JSON can consume significant resources; size and trust boundaries still matter.

## Practical Heuristics
- Use explicit schemas upstream and validate decoded payloads downstream.
- Keep output deterministic when diffability matters by choosing indentation and key ordering intentionally.
- Avoid writing multiple top-level objects to the same file with repeated `dump()` calls because JSON is not a framed protocol.

---
## References
- [[python-standard-library-hubs]]
- [[python-moc]]
- [[pydantic]]
- [json](https://docs.python.org/3.12/library/json.html)
