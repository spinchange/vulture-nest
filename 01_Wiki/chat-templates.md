---
title: Chat Templates
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [jinja-templates, conversational-roles, system-user-assistant]
---
# Chat Templates

**Chat Templates** are the bridge between a human-readable list of messages and the raw, model-specific token stream required by an LLM.

## Conversational Roles
Standard chat templates use three primary roles:
*   **System**: Persistent instructions that define the agent's identity, tone, and available tools.
*   **User**: The human-provided query or instruction.
*   **Assistant**: The model's reasoning, tool calls, and final responses.
*   **Tool**: (Introduced in [[function-calling]]) The role used to feed the output of a tool back into the conversation.

## Technical Implementation
Most modern frameworks (like `transformers` or `smolagents`) use **Jinja2** templates to wrap messages with special tokens (e.g., `<|im_start|>`, `[INST]`) that the model was trained on. This ensures the model correctly identifies who said what.

---
## References
* Source: `00_Raw/hf-agents-course-unit1.md`
* [[hf-agents-course-moc]]
* [[function-calling]]
