---
title: Chat Templates
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [chat-ml, system-messages, special-tokens]
---
# Chat Templates

**Chat Templates** are the bridge between a human-readable list of messages and the raw prompt string expected by an LLM. They ensure that **Special Tokens** (like EOS tokens) are placed correctly.

## Message Roles
1.  **System Message:** Persistent instructions defining the agent's persona, behavior, and available tools. This is the "operating system" of the session.
2.  **User Message:** The human's input or instructions.
3.  **Assistant Message:** The agent's reasoning, actions, and final responses.

## Special Tokens
Models use unique delimiters to separate roles.
*   **SmolLM2:** Uses `<|im_start|>` and `<|im_end|>`.
*   **Llama 3:** Uses `<|start_header_id|>` and `<|eot_id|>`.

## Agentic Importance
For agents, the chat template must handle the **Stop and Parse** mechanism by ensuring the model stops generating immediately after an **Action** block, allowing the system to insert an **Observation**.

## See Also
* [[yanp-for-agentic-workflows]] (Protocol-level application of templates)
* [[agentic-frameworks-moc]]
