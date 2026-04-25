---
title: MCP Primitives
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-tools, mcp-resources, mcp-prompts]
---
# MCP Primitives

Primitives are the core building blocks of the **[[mcp-architecture|Model Context Protocol]]**. They define the specific types of context and capabilities that a Server can expose to a Client.

## 1. Tools (Actionable)
Functions that an AI model can actively call based on user requests.
*   **Control:** Model-controlled.
*   **Mechanism:** Defined via JSON Schema; executed via `tools/call`.
*   **Example:** `send_email`, `query_database`.

## 2. Resources (Contextual)
Passive data sources that provide read-only information to the application.
*   **Control:** Application-controlled (the Host decides how to use the data).
*   **Mechanism:** Identified by URIs (e.g., `file://`, `postgres://`). Supports templates for dynamic queries.
*   **Example:** File contents, database schemas, API logs.

## 3. Prompts (Instructional)
Reusable instruction templates that guide the model's interaction.
*   **Control:** User-controlled (explicitly invoked via slash commands or UI buttons).
*   **Mechanism:** Parameterized templates (e.g., "Plan a vacation for {destination}").
*   **Example:** Code review templates, meeting summarizers.

---
## See Also
* [[mcp-architecture]]
* [[mcp-client-features]]
