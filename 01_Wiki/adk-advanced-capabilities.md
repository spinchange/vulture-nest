---
title: '[[agent-development-kit|ADK]] Advanced Capabilities: Planning & Code Execution'
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - adk-planning
  - adk-code-execution
  - thinking-config
  - BuiltInPlanner
  - BuiltInCodeExecutor
type: permanent
---

# ADK Advanced Capabilities: Planning & Code Execution

The [[agent-development-kit|ADK]] provides advanced features that enable agents to perform complex reasoning, mathematical calculations, and multi-step goal decomposition.

## 1. Planning and Thinking (`ThinkingConfig`)
ADK allows agents to use a "thinking" or "reasoning" process before generating a final response. This is essential for complex tasks that require multiple steps of internal deliberation.

### `ThinkingConfig`
Configures the thinking behavior of the agent.
*   `include_thoughts`: (Boolean) Whether to ask the model to include its thoughts in the response stream.
*   `thinking_budget`: (Integer) Limits the number of tokens allocated to the "thinking" process.

### `BuiltInPlanner`
A primitive that manages the reasoning loop. When an `LlmAgent` is configured with a planner, it follows a more structured reasoning process (often similar to ReAct).

```python
# Configuration Example
thinking_config = ThinkingConfig(include_thoughts=True, thinking_budget=256)
planner = BuiltInPlanner(thinking_config=thinking_config)

agent = LlmAgent(
    model="gemini-2.5-pro",
    planner=planner,
    # ...
)
```

## 2. Code Execution (`BuiltInCodeExecutor`)
Agents in ADK can natively generate and execute code (typically [[python]]) to perform calculations, data manipulation, or other algorithmic tasks.

### `BuiltInCodeExecutor`
Enables the agent to execute code blocks found in its own responses.
*   **Mechanism:** When the LLM generates a part containing `executable_code`, the `Runner` detects it, executes it using the configured executor, and injects the `code_execution_result` back into the conversation history.
*   **Safety:** Execution usually happens in a managed environment (e.g., Gemini's built-in sandbox).

```python
# Code Execution Example
code_agent = LlmAgent(
    name="calculator",
    model="gemini-2.0-flash",
    code_executor=BuiltInCodeExecutor(),
    instruction="Write and execute Python code to solve math problems."
)
```

## 3. Interaction Patterns
*   **Thoughts as Events:** Thinking events are yielded by the `Runner` during the execution loop, allowing developers to visualize the agent's internal process in real-time (e.g., via the Dev UI).
*   **Multi-Part Events:** Code execution involves complex `Event` objects that contain multiple `Part`s (Text, ExecutableCode, and CodeExecutionResult).

---
*Source: [[lit-adk-documentation]]*

