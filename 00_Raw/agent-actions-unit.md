# Actions: Enabling the Agent to Engage with Its Environment

Source: Agents Course (Unit 1) - Hugging Face

## Summary
Actions are the concrete steps an AI agent takes to interact with its environment (web browsing, tool usage, API calls).

## Key Concepts
* **JSON Agent:** Actions specified in JSON.
* **Code Agent:** Agent generates executable code blocks (e.g., Python).
* **Function-calling Agent:** Fine-tuned JSON agent for discrete tool calls.
* **Stop and Parse:** The LLM must stop generating after the action tokens to allow an external parser to execute the tool and return control.

## Advantages of Code Agents
* Expressiveness (loops, conditionals).
* Modularity/Reusability.
* Enhanced debuggability.
* Direct integration with libraries.
