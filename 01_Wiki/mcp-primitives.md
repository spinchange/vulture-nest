---
title: [[mcp-moc|MCP]] Primitives
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-tools, mcp-resources, mcp-prompts]
---
# MCP Primitives

Primitives are the core building blocks of the **[[mcp-architecture|Model Context Protocol]]**. They define the specific types of context and capabilities that a Server can expose to a Client.

## Core Opinion

The three MCP primitives are not interchangeable ways to expose "stuff." They are different control surfaces with different owners:

- **Tools** are for actions the model may request.
- **Resources** are for context the host/application may read and inject.
- **Prompts** are for reusable interaction scaffolds a user or client may invoke intentionally.

Most MCP design mistakes come from flattening these distinctions and exposing everything as tools.

## 1. Tools (Actionable)

Functions that an AI model can actively call based on user requests.

* **Control:** Model-controlled after discovery; the host still mediates execution and approval.
* **Mechanism:** Listed via `tools/list`, described by schemas, executed via `tools/call`.
* **Best for:** Actions with clear side effects or explicit computation boundaries.
* **Example:** `send_email`, `query_database`, `create_issue`.

### Design Guidance

- Use tools when the model should be able to *decide to act*.
- Keep schemas clear and flat so invocation is reliable.
- Treat tool inputs as untrusted; the server owns validation and enforcement.
- If a capability is really passive reference material, do not force it into a tool.

## 2. Resources (Contextual)

Passive data sources that provide read-only information to the application.

* **Control:** Application- or host-controlled. The host decides whether and when the model sees the content.
* **Mechanism:** Identified by URIs (for example `file://`, `postgres://`, or app-defined schemes) and read through the resource surface.
* **Best for:** Data that should be retrieved or inspected rather than "called."
* **Example:** File contents, database schemas, logs, reference documents.

### Design Guidance

- Use resources when the main job is *providing context*, not triggering behavior.
- Prefer stable URI design so clients can reason about what they are reading.
- Resource templates are useful when the namespace is dynamic but still structurally predictable.
- If the model should not autonomously decide when to use the content, resources are usually the right fit.

## 3. Prompts (Instructional)

Reusable instruction templates that guide the model's interaction.

* **Control:** User- or client-invoked. Prompts are usually selected explicitly rather than chosen autonomously by the model.
* **Mechanism:** Listed and fetched as parameterized templates.
* **Best for:** Reusable workflows, review templates, guided interactions, and consistent task framing.
* **Example:** Code review templates, meeting summarizers, project intake scaffolds.

### Design Guidance

- Use prompts when you want to standardize *how* a task is framed.
- Prompts are especially useful for UI affordances such as slash commands or canned workflows.
- Do not use prompts as a substitute for tool contracts; they shape interaction, not side-effect boundaries.

## How to Choose

Ask which party should own the decision:

1. If the **model** should decide whether to invoke a capability, use a **tool**.
2. If the **host/application** should decide what context to fetch or expose, use a **resource**.
3. If the **user/client** should intentionally start from a reusable instruction scaffold, use a **prompt**.

## Common Failure Modes

- Exposing read-only reference data as tools, forcing the model to "call" what should be retrieved.
- Exposing side-effecting operations as resources, hiding action boundaries from the host.
- Using prompts to smuggle operational parameters that really belong in tool schemas.
- Treating discovery as equivalent across primitives when the control model is different for each.

## Relationship to the Rest of the Vault

- [[agent-tools]] is the broader agent-design note; `mcp-primitives` is the protocol-specific breakdown.
- [[mcp-client-features]] explains the client-side surfaces around these primitives, such as sampling and elicitation.
- [[mcp-server-features]] covers what servers actually advertise and implement around the primitive surface.
- [[mcp-best-practices]] explains how these primitives are discovered and staged in larger tool ecosystems.

---
## See Also
* [[mcp-architecture]]
* [[mcp-client-features]]
* [[mcp-server-features]]
* [[mcp-best-practices]]
* [[agent-tools]]
- [[lit-mcp-architecture]]
