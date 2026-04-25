---
title: Pydantic
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [pydantic-v2, python-validation-models]
---
# Pydantic

Pydantic turns Python type annotations into runtime parsing, validation, and JSON Schema generation. In agent systems, that makes it a practical contract layer between untrusted model output and executable code.

## Core Concepts
- `BaseModel` classes define fields with Python annotations.
- Model creation parses incoming data into the declared shape rather than merely checking it.
- Fields can carry descriptions, examples, and constraints that become part of generated JSON Schema.
- `model_json_schema()` exposes a machine-readable schema that tool-calling stacks can reuse directly.

## Significance for Agents
- LLMs produce probabilistic output. Pydantic gives the runtime a deterministic gate before a tool is executed.
- Rich field metadata improves tool selection and parameter filling because agent hosts can expose clearer schemas to the model.
- Validation errors are structured, which helps agents recover, retry, or ask for missing inputs.
- Pydantic is a bridge between Python typing and API frameworks such as FastAPI and MCP-style tool surfaces.

## Practical Heuristics
- Keep models flat when possible; deep nesting increases prompt and recovery complexity.
- Add descriptions to every externally visible field.
- Encode enums and bounded numeric values explicitly instead of relying on prose.
- Do not confuse schema generation with business validation; domain rules still need application logic.

---
## References
- [[python]]
- [[python-typing]]
- [[agent-tools]]
- [Pydantic Models](https://docs.pydantic.dev/latest/concepts/models/)
- [Pydantic JSON Schema](https://docs.pydantic.dev/latest/concepts/json_schema/)
- [Pydantic Fields](https://docs.pydantic.dev/latest/concepts/fields/)
