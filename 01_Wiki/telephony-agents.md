---
title: Telephony & Voice Agents
author: gemini-cli
date: 2026-05-18
status: active
type: permanent
aliases: [voice-agents, agent-phone, interactive-voice-response, ivr-agents]
---

# Telephony & Voice Agents

Telephony agents are autonomous systems capable of interacting with the Public Switched Telephone Network (PSTN) and mobile networks via voice and SMS. Unlike traditional text-based agents, they operate in real-time, low-latency environments where audio processing and conversation flow are critical.

## 🏗️ Architectural Layers

### 1. Transport & Connectivity
The bridge between the AI and the telephony network is typically handled via:
- **MCP Servers**: Specialized servers like `agentphone-mcp` that wrap telephony APIs into tool-calling surfaces.
- **Webhooks**: Event-driven notifications for inbound calls, SMS, and status updates (e.g., call answered, hangup).
- **Streaming Protocols**: Bidirectional streams (often WebSockets or gRPC) for real-time audio transfer between the agent and the model.

### 2. Audio Processing (STT/TTS)
- **Speech-to-Text (STT)**: Converting user audio into text tokens for the model to process.
- **Text-to-Speech (TTS)**: Synthesizing model responses back into audio.
- **Live Models**: Modern models (like Gemini 2.0+ with Live API) support native audio inputs/outputs, bypassing discrete STT/TTS steps for lower latency and better prosody.

### 3. Orchestration
Orchestration of voice agents requires handling specific non-textual events:
- **Interruptions**: Detecting when a user speaks over the agent.
- **Silence/Turn Detection**: Determining when the user has finished their turn.
- **Voice Configuration**: Selecting appropriate voices (e.g., "Aoede", "Puck") and model tiers (e.g., `turbo` for speed).

## 🛠️ ADK Implementation Pattern

In the **Agent Development Kit (ADK)**, telephony and voice are implemented through two primary paths:

### Path A: MCP-Driven Telephony
Using the `AgentPhone` toolkit to give an agent "phone skills":
- **Tools**: `make_call`, `send_message`, `list_conversations`.
- **Use Case**: Asynchronous tasks where the agent initiates a call to gather information or send an alert.

### Path B: Native Streaming (Voice Agents)
Using `Runner.run_live()` for high-fidelity, real-time voice interactions:
- **Config**: `SpeechConfig` and `VoiceConfig` (e.g., `PrebuiltVoiceConfig`).
- **Streaming Mode**: Bidirectional (`BIDI`) for low-latency feedback.
- **Models**: Requires models that support the **Gemini Live API**.

## ⚖️ Tradeoffs & Constraints

| Feature | Text-based Agent | Telephony Agent |
|---|---|---|
| **Latency** | Medium/High (Seconds) | Very Low (Milliseconds) |
| **State** | Context Window | Call Lifecycle + Persistent Session |
| **Input** | Clean Text | Noisy Audio (Background noise, accents) |
| **Output** | Markdown/JSON | Synthesized Voice / Audio Stream |
| **Interaction** | Turn-based | Continuous / Fluid (Interruption-sensitive) |

## 🚀 Where to Start
- **Building a phone-calling tool?** See [[lit-adk-telephony]] and the `AgentPhone` MCP docs.
- **Implementing a real-time voice assistant?** See [[adk-advanced-capabilities]] § Streaming.
- **Connecting models to hardware audio?** See [[hardware-aware-inference]].

---
## References
- [[lit-adk-telephony]]
- [[agent-development-kit]]
- [[mcp-moc]]
- [[agent-thought-cycle]]
- [[adk-advanced-capabilities]]
