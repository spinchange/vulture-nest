---
title: [[agent-development-kit|ADK]] Callbacks & Lifecycle Hooks
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - adk-callbacks
  - before_model_callback
  - before_tool_callback
  - adk-guardrails
type: permanent
---

# ADK Callbacks & Lifecycle Hooks

**Callbacks** in the [[agent-development-kit|ADK]] provide a powerful mechanism to inject custom logic, security guardrails, and observability into an agent's execution loop without modifying the core agent definition.

## 1. Core Callback Types

### `before_model_callback`
Triggered immediately before an LLM request is sent to the model provider.
*   **Signature:** `(callback_context: CallbackContext, llm_request: LlmRequest) -> Optional[LlmResponse]`
*   **Primary Use:** **Input Guardrails**. Checking for blocked keywords, PII, or policy violations.
*   **Blocking:** If the function returns an `LlmResponse` instead of `None`, the model call is skipped, and the returned response is used as the model's output.

### `before_tool_callback`
Triggered immediately before a tool is executed.
*   **Signature:** `(callback_context: CallbackContext, tool_name: str, args: dict) -> Optional[Union[dict, str, Part]]`
*   **Primary Use:** **Tool Argument Guardrails**. Restricting tool access (e.g., blocking a specific city in a weather tool) or modifying arguments.
*   **Blocking:** If the function returns a value (like an error dictionary), the tool execution is skipped, and the returned value is provided to the agent as the "result."

### Lifecycle Observability Hooks
These hooks are typically used for logging, tracing, and metric collection:
*   `on_tool_start`: Triggered when a tool begins execution.
*   `on_tool_end`: Triggered when a tool completes.
*   `on_agent_start`: Triggered when an agent (or sub-agent) begins its turn.
*   `on_agent_finish`: Triggered when an agent completes its execution.

## 2. The `CallbackContext`
All callbacks receive a `CallbackContext` object, providing access to:
*   `agent_name`: The name of the agent currently executing.
*   `state`: Access to the shared [[adk-session-service|Session State]].
*   `session_id` / `user_id`: Identifiers for the current interaction.

## 3. Implementation Patterns

### Safety Guardrail Pattern
Using `before_model_callback` to block malicious prompts:
```python
def safety_guardrail(context: CallbackContext, request: LlmRequest):
    last_msg = request.messages[-1].content.parts[0].text
    if "restricted_topic" in last_msg:
        return LlmResponse(content=types.Content(parts=[types.Part(text="I cannot discuss that.")]))
    return None
```

### Delegation & Callbacks
**Note:** Callbacks defined on a Parent agent do **not** automatically propagate to Sub-agents. Each agent in a [[adk-multi-agent-orchestration|Multi-Agent System]] must have its callbacks configured explicitly if they are required at that level.

---
*Source: [[lit-adk-documentation]]*

