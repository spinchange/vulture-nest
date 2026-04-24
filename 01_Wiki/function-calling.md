---
title: Function Calling
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [native-tool-use, tool-calling-api, role-based-agency]
---
# Function Calling

**Function Calling** is a learned capability where an LLM is fine-tuned to detect when a tool should be invoked and to generate the structured arguments for that tool call.

## Learned vs. Prompted Agency
*   **Prompt-based (Unit 1):** The agent relies on a "ReAct" prompt to simulate reasoning and formatting. The model "generalizes" to use the tools.
*   **Fine-tuned (Native):** The model has been trained on thousands of examples of tool use. It is more robust, follows schemas more accurately, and requires less instruction overhead.

## Conversational Roles
Function calling often introduces a specialized role structure in chat histories:
1.  **User:** The request.
2.  **Assistant:** The reasoning and the **Function Call** (Action).
3.  **Tool:** The **Observation** returned by the system.
4.  **Assistant:** The final synthesized response.

## Special Tokens
Models like Mistral use dedicated tokens to delimit these turns:
*   `[TOOL_CALLS]`: Signals an outgoing action.
*   `[TOOL_RESULTS]`: Signals incoming feedback from the environment.

## See Also
* [[agent-actions]]
* [[lora]]
* [[agentic-frameworks-moc]]
