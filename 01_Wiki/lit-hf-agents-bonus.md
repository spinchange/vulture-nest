---
title: "Literature: HF Agents Course - Bonus Units"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: ["00_Raw/hf-agents-bonus1.md", "00_Raw/hf-agents-bonus2.md", "00_Raw/hf-agents-bonus3.md"]
aliases: ["HF Agents Bonus Material", "Agent Observability and Fine-tuning"]
---

# Literature: HF Agents Course - Bonus Material

This literature note covers advanced topics from the bonus units of the Hugging Face Agents Course.

## Bonus Unit 1: Fine-tuning for Function Calling
- **Native Capabilities**: Moving beyond "ReAct" prompting to native **Function Calling** through model fine-tuning.
- **LoRA (Low-Rank Adaptation)**: Efficient fine-tuning that uses small adapter layers to minimize compute costs while enabling agentic behaviors.
- **Conversational Structure**: Introduction of the `tool` role in messages and specialized tokens (e.g., `[TOOL_CALLS]`) to delimit actions in the stream, making tool-use boundaries easier for the model to parse than prompt-only conventions.

## Bonus Unit 2: Observability & Evaluation
- **Observability Primitives**: Using **Traces** (full tasks) and **Spans** (steps) to monitor internal agent logic.
- **Evaluation Strategies**:
    - **Offline**: Benchmarks (e.g., GSM8K) for pre-deployment testing.
    - **Online**: Real-world monitoring and user feedback loops.
- **LLM-as-a-Judge**: Utilizing a high-capability model to automatically score agent outputs for quality and safety.
- **OpenTelemetry**: The standard for instrumenting agentic codebases for telemetry collection.

### Tradeoffs in Evaluation
- **LLM-as-a-Judge caveat**: Automated grading can reduce human review load, but it introduces cost, model bias, and the risk that evaluator quality drifts from human judgment.

## Bonus Unit 3: Agents in Games
- **Autonomous NPCs**: Shifting from scripted logic to agents that plan and act independently, enabling emergent gameplay.
- **Strategy vs. Real-time**: LLMs are more commonly deployed in turn-based environments (e.g., Pokémon battles) because inference latency is easier to manage there; real-time integration is possible but less common.
- **Bridging Logic**: Creating mapping layers (e.g., `LLMAgentBase`) to translate raw game states into semantic prompts.

---
## See Also
- [[hf-agents-course-moc]]
- [[agent-observability]]
- [[agent-evaluation]]
- [[function-calling]]
- [[agents-in-games]]
