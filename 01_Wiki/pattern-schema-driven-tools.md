---
title: 'Pattern: Schema-Driven Tool Development'
author: gemini-cli
date: 2026-05-18
status: active
type: permanent
aliases:
  - schema-driven-tools
  - pydantic-tool-mapping
  - agent-schema-contracts
---

# Pattern: Schema-Driven Tool Development

Schema-driven tool development is a methodology where the **source of truth** for an AI agent's capabilities is defined using strongly-typed code (e.g., Pydantic in Python, Zod in TypeScript). These definitions are then automatically exported as JSON Schemas for LLM tool-calling.

## 核心原则: LLM-Centric Design
Traditional API schemas are designed for developers; tool schemas must be designed for **LLMs**.
- **Self-Describing**: Every field MUST have a `description` that explains its purpose to the model.
- **Fail-Fast**: Use runtime validation (Pydantic) to ensure the agent receives exactly what it expects.
- **Atomic Constraints**: Use `Literal`, `Min/Max`, and `Regex` to narrow the model's action space.

## 🛠️ Implementation Patterns

### 1. Pydantic-to-Tool Mapping (Python)
Pydantic `BaseModel` is the industry standard for defining tool inputs.

```python
from pydantic import BaseModel, Field
from typing import Annotated, Literal

class GetWeather(BaseModel):
    """Get the current weather for a specific location."""
    
    location: Annotated[str, Field(description="The city and state, e.g. San Francisco, CA")]
    unit: Literal["celsius", "fahrenheit"] = Field(
        default="celsius", 
        description="The temperature unit to use."
    )
```

### 2. Output Schema Enforcement
In frameworks like **ADK**, Pydantic models can be used to force an agent to respond in structured JSON.

```python
from google.adk.agents import LlmAgent

class ResearchReport(BaseModel):
    summary: str = Field(description="A 3-sentence summary of findings.")
    confidence: float = Field(ge=0, le=1, description="Confidence score.")

agent = LlmAgent(
    # ...
    output_schema=ResearchReport,
    output_key="report" # Result stored in session state
)
```

### 3. The FastAPI/MCP Bridge
Using Pydantic with **FastAPI** allows for automatic **MCP Tool** generation.
- **FastAPI** generates an OpenAPI spec from Pydantic models.
- **FastMCP** (or similar bridges) reads the OpenAPI spec and creates MCP `inputSchema` objects.
- **Metadata Flow**: `Field(description=...)` → `OpenAPI property description` → `MCP tool parameter description`.

## ✅ Best Practices
- **Use `Annotated`**: Keeps the type hint and the metadata (like `Field`) together, improving readability.
- **Semantic Names**: Name tool parameters based on their *role* in the model's thought process, not internal database names.
- **Avoid Over-Nesting**: Deeply nested JSON structures increase the token cost and probability of hallucination. Prefer flat models for tool inputs.
- **Provide Examples**: Some providers (like Anthropic) benefit from `examples` in the JSON Schema, which can be provided via Pydantic `json_schema_extra`.

---
## References
- [[pydantic]]
- [[pydantic-fastapi-agents]]
- [[python-moc]]
- [[agent-tools]]
- [[mcp-moc]]
- [[lit-adk-telephony]]
