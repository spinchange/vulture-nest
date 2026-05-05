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

The [[agent-development-kit|ADK]] documentation describes two higher-leverage capabilities beyond a basic `LlmAgent` loop: planner-assisted reasoning and built-in code execution. In this vault, treat them as opt-in advanced features whose behavior depends on model support, runtime configuration, and safety boundaries.

## 1. Planning and Thinking (`ThinkingConfig`)
ADK documents a "thinking" or "reasoning" path for models that support it. This is most useful when a task benefits from extra intermediate deliberation rather than a single direct answer.

### `ThinkingConfig`
Configures the thinking behavior of the agent.
*   `include_thoughts`: (Boolean) Whether to ask the model to include its thoughts in the response stream.
*   `thinking_budget`: (Integer) Limits the number of tokens allocated to the "thinking" process.

### `BuiltInPlanner`
A planner primitive that delegates structured reasoning support to the model/runtime combination. Practically, this means the runtime can ask a capable model to spend extra budget on intermediate planning before or during answer generation, rather than forcing a single direct completion. It can resemble [[react-pattern|ReAct]]-style loops in spirit when the system alternates between deliberation and action, but this note should not be read as claiming strict algorithmic equivalence or a guaranteed step-by-step trace.

```python
# Configuration Example
thinking_config = ThinkingConfig(include_thoughts=True, thinking_budget=256)
planner = BuiltInPlanner(thinking_config=thinking_config)

agent = LlmAgent(
    model="<thinking-capable-model>",
    planner=planner,
    # ...
)
```

The model name here is intentionally placeholder-style. The raw ADK documentation snapshot contains concrete Gemini examples, but exact model identifiers change faster than the architectural pattern.

### Discovering Support
Treat planner support as a capability lookup, not a hard-coded assumption. In practice, verify support in the current ADK and model documentation before enabling `ThinkingConfig`, because availability, limits, and naming can shift across model releases.

## 2. Code Execution (`BuiltInCodeExecutor`)
ADK also documents a built-in code-execution path, typically using [[python]] snippets for calculation, transformation, or small algorithmic steps.

### `BuiltInCodeExecutor`
Enables the agent to execute code blocks found in its own responses.
*   **Mechanism:** When the LLM generates a part containing `executable_code`, the `Runner` detects it, executes it using the configured executor, and injects the `code_execution_result` back into the conversation history.
*   **Safety:** The ADK docs describe managed execution environments, but the exact sandbox properties, resource limits, and failure behavior remain runtime-specific and should be verified before treating execution as safe by default.
*   **Compatibility:** The ADK docs also note that some code-execution combinations are not supported in every tool configuration. Read "combinations" broadly: model support, executor availability, tool wiring, and runtime environment all have to line up for execution to work.

```python
# Code Execution Example
code_agent = LlmAgent(
    name="calculator",
    model="<code-execution-capable-model>",
    code_executor=BuiltInCodeExecutor(),
    instruction="Write and execute Python code to solve math problems."
)
```

## 3. Interaction Patterns
*   **Thoughts as Events:** The `Runner` can emit intermediate events that expose thinking-related output for inspection or tooling. For callback-oriented handling patterns, see [[adk-callbacks-and-lifecycle]].
*   **Multi-Part Events:** Code execution can appear as event payloads containing normal text, generated code, and execution results as separate parts.
*   **Inspection workflow:** In practice, these events are most useful for logging, debugging, and guardrails rather than as a guaranteed stable public reasoning transcript.

## 4. Streaming & Live Audio

ADK provides a streaming execution path for real-time, bidirectional voice and audio interactions. It uses different primitives from the standard request-response path.

### Execution model
- `Runner.run_live()` replaces `Runner.run()` for streaming sessions.
- `LiveRequestQueue` accepts continuous audio input for bidirectional streaming — the caller pushes audio chunks; the runner emits output events as they arrive.
- Native-audio models power live sessions; text chat is disabled on native-audio model connections, and not all models support this modality.

### Configuration types
- `SpeechConfig` / `VoiceConfig` — controls voice output characteristics (pitch, rate, voice identity).
- `PrebuiltVoiceConfig` — selects from provider-managed voice presets without manual configuration.
- `Modality` — specifies the interaction modality (audio, text, video) during `RunConfig` setup.

### Design considerations
- **Turn detection** — live audio sessions must handle speaker overlap and turn boundaries; these are typically managed by the model or the runtime, not by application code.
- **Testing locally** — the ADK Dev UI (`adk web`) includes a microphone button for voice input; the same session that works as text chat cannot be used with a native-audio model.
- **Custom audio pipelines** — production deployment requires an explicit audio I/O pipeline (microphone capture, speaker output) or an audio-capable hosting platform; the Dev UI handles this only for local development.

### Telephony via MCP
For phone call and SMS capabilities — outbound AI calls, autonomous voice agents, SMS threads, call transfer — the ADK ecosystem documents integration with the AgentPhone MCP server (`agentphone-mcp`). This follows the standard `McpToolset` pattern: the telephony capabilities arrive as tool definitions; no new ADK primitives are involved. See [[mcp-server-development]] for the `McpToolset` connection pattern.

## 5. Tradeoffs and Limits
*   **Token cost:** Planning consumes extra reasoning budget and can increase latency.
*   **Debug surface:** Exposed thoughts and execution traces can improve observability, but they also create more runtime states to inspect and sanitize.
*   **Failure modes:** Planning may exhaust its budget without improving the answer, and code execution can fail due to unsupported operations, timeouts, or sandbox limits.
*   **Security posture:** Treat code execution as an explicitly governed feature, not as a harmless extension of normal text generation.
*   **Streaming latency budget:** Native-audio models are optimized for low latency; the same underlying LLM running in text mode may respond differently in timing and behavior.

## See Also
- [[agent-development-kit]]
- [[adk-callbacks-and-lifecycle]]
- [[react-pattern]]
- [[mcp-server-development]]
- [[python]]
- [[lit-adk-documentation]]

---
*Source: [[lit-adk-documentation]]*

