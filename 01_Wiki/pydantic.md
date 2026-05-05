---
title: Pydantic
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [pydantic-v2, python-validation-models]
---
# Pydantic

Pydantic turns [[python]] type annotations into runtime parsing, validation, and JSON Schema generation. In agent systems, that makes it a practical contract layer between untrusted model output and executable code.

## Core Concepts
- `BaseModel` classes define fields with Python annotations.
- Model creation parses incoming data into the declared shape rather than merely checking it.
- Fields can carry descriptions, examples, and constraints that become part of generated JSON Schema.
- `model_json_schema()` exposes a machine-readable schema that tool-calling stacks can reuse directly.

## Significance for Agents
- LLMs produce probabilistic output. Pydantic gives the runtime a deterministic gate before a tool is executed.
- Rich field metadata improves tool selection and parameter filling because agent hosts can expose clearer schemas to the model.
- Validation errors are structured, which helps agents recover, retry, or ask for missing inputs.
- Pydantic is a bridge between Python typing and API frameworks such as FastAPI and [[mcp-moc|MCP]]-style tool surfaces.

## The Schema Pipeline

`model_json_schema()` emits a JSON Schema object with `type: "object"`, a `properties` map (one entry per field carrying its `description` and type constraints), and a `required` list derived from fields with no default. Three tool surfaces consume this shape directly:

- **Anthropic API** — the `input_schema` field in a tool definition is this object verbatim; when Anthropic strict mode (`strict: true`) is enabled, schema conformance matters more because the host treats that generated shape as the execution contract
- **MCP / FastMCP** — `@mcp.tool()` introspects Python type hints and generates `inputSchema` through the same path; passing a Pydantic model as the parameter type produces equivalent output
- **FastAPI** — generates an OpenAPI schema from the Pydantic request model automatically; the `fastapi-mcp` library then reads that OpenAPI spec and registers each route as an MCP tool, meaning a well-described Pydantic model propagates into the MCP tool surface without manual schema translation

Schema quality therefore becomes a correctness concern: a missing `description`, a loose `Any` type, or an unconstrained numeric range degrades both model selection accuracy and strict-mode validation.

## Practical Heuristics
- Keep models flat when possible; deep nesting increases prompt and recovery complexity.
- Add `description` to every externally visible field — it populates the schema the model reads to decide whether and how to call the tool.
- Encode enums with `Literal` and bounded numeric values with `Field(ge=..., le=...)` rather than relying on prose constraints.
- Use `@field_validator` (V2) for cross-field or domain rules that JSON Schema cannot express; do not conflate those with schema shape.
- Do not confuse schema generation with business validation; domain rules still need application logic.

## Where to Start

- **Defining a Pydantic model and understanding validation?** Start here.
- **Wiring models into FastAPI routes or MCP tool registration?** Go to [[pydantic-fastapi-agents]].
- **Understanding the protocol-level tool surface?** Go to [[mcp-server-development]] (Python/FastMCP) or [[anthropic-tool-use]] (Anthropic API).

---
## References
- [[python]]
- [[python-typing]]
- [[agent-tools]]
- [[pydantic-fastapi-agents]]
- [[mcp-server-development]]
- [[anthropic-tool-use]]
- [Pydantic Models](https://docs.pydantic.dev/latest/concepts/models/)
- [Pydantic JSON Schema](https://docs.pydantic.dev/latest/concepts/json_schema/)
- [Pydantic Fields](https://docs.pydantic.dev/latest/concepts/fields/)

