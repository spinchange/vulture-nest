# Hugging Face Agents Course - Bonus Unit 1: Fine-Tuning for Function Calling

Source: [Hugging Face Agents Course](https://hf.co/learn/agents-course/bonus-unit1/introduction)

## Summary
This unit covers how to move beyond prompt-based tool use by fine-tuning models specifically for function calling. It introduces the role-based conversational structure for tools and efficient training techniques like LoRA.

## Key Concepts
*   **Function Calling:** A native capability where a model is trained to generate structured tool calls rather than relying on reasoning alone.
*   **Conversational Roles:** Introduces the `tool` role in messages, allowing the model to distinguish between its own generation and external observations.
*   **LoRA (Low-Rank Adaptation):** A lightweight fine-tuning technique that adds small trainable "adapters" to a frozen base model, drastically reducing memory and compute requirements.
*   **Special Tokens:** Specialized markers (e.g., `[TOOL_CALLS]`, `[TOOL_RESULTS]`) that delimit agentic actions in the token stream.
