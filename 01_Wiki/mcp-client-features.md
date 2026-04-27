---
title: [[mcp-moc|MCP]] Client Capabilities
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-sampling, mcp-elicitation, mcp-roots]
---
# MCP Client Capabilities

In the **[[mcp-architecture|MCP]]** model, the Client (residing in the Host application) can provide features to the Server, enabling more complex agentic workflows.

## 1. Sampling (LLM Access)
Allows a Server to request language model completions from the Host.
*   **Benefit:** Enables "Model-Independent" servers. The server author doesn't need to bundle an LLM SDK or handle API keys; they just ask the host to "sample" the model for them.
*   **Security:** The Host (and User) remains in control of permissions and token limits.

## 2. Elicitation (User Interaction)
Allows a Server to request additional information or confirmation from the user on-demand.
*   **Example:** A travel server pausing a booking to ask for seat preferences.
*   **Mechanism:** `elicitation/create`.

## 3. Roots (Filesystem Boundaries)
Allows a Client to define which directories a Server should focus on.
*   **Note:** These are **advisory boundaries**, not strict OS-level sandboxes. They help well-behaved servers stay within project scopes.
*   **Mechanism:** `file://` URI roots.

## 4. Logging
Servers can send log messages to the Client for real-time debugging and monitoring within the Host UI.

---
## See Also
* [[mcp-architecture]]
* [[mcp-primitives]]
- [[mcp-server-features]]

