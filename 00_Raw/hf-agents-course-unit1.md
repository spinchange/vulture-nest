# Hugging Face Agents Course - Unit 1: Fundamentals

Source: [Hugging Face Agents Course](https://hf.co/learn/agents-course/unit1/introduction)

## Summary
Unit 1 covers the core components of AI Agents: LLMs as the "brain," tools as the "body," and the Thought-Action-Observation cycle as the "workflow."

## Key Concepts
*   **Thought-Action-Observation Cycle:** The continuous loop of reasoning, tool execution, and feedback integration.
*   **ReAct (Reasoning + Acting):** A prompting technique interleaving reasoning steps with tool calls.
*   **Chat Templates:** The bridge between conversational messages (System, User, Assistant) and model-specific special tokens.
*   **Tools:** Functions described to the LLM via system prompts, allowing it to interact with the environment.
*   **Stop and Parse:** The mechanism where the LLM stops generating to allow an external system to execute a tool.
*   **smolagents:** A lightweight library by Hugging Face focusing on Code Agents.
*   **System Messages:** Persistent instructions defining agent behavior and available tools.
