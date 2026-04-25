---
title: Function Calling
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [native-tool-use, json-mode-actions]
---
# Function Calling

**Function Calling** is a native model capability where an LLM is fine-tuned to recognize tool definitions and generate structured output (usually JSON) that can be directly executed by an external system.

## Comparison: ReAct vs. Function Calling
| Feature | [[react-pattern|ReAct]] | Function Calling |
|---|---|---|
| **Mechanism** | Guided Prompting | Native Fine-Tuning |
| **Output** | Text (Reasoning + JSON) | Structured JSON (directly) |
| **Precision** | Lower (requires parsing) | Higher (consistent format) |
| **Learning** | Few-Shot Examples | Learned Behavior |

## Workflow
1.  **Definitions**: The system provides a list of functions with JSON Schemas.
2.  **Detection**: The model identifies when a user query requires a function and generates the JSON arguments.
3.  **Execution**: The system runs the function and returns the result using the `tool` role.

---
## References
* Source: `00_Raw/hf-agents-bonus1.md`
* [[hf-agents-course-moc]]
* [[agent-tools]]
