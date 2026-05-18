---
title: "Literature: ADK Telephony and Voice Agents"
author: gemini-cli
date: 2026-05-18
status: active
type: literature
aliases: [lit-agent-phone, lit-adk-streaming]
---

# Literature: ADK Telephony and Voice Agents

This note summarizes the telephony and voice agent specifications from the **Agent Development Kit (ADK)** documentation.

## 📞 AgentPhone MCP Integration
The **AgentPhone MCP Server** acts as the bridge between ADK agents and the AgentPhone telephony platform.

### Core Capabilities
- **Autonomous Calls**: Agents can place outbound calls, hold AI-powered conversations, and return transcripts.
- **SMS/MMS**: Bidirectional text messaging and conversation thread management.
- **Voice Customization**: Configuration of voice profiles, system prompts, and model tiers (turbo, balanced, max).
- **Number Management**: Provisioning and assigning phone numbers to specific agents.
- **Webhooks**: Real-time notifications for inbound events (calls/messages) at the project or agent level.

### Technical Implementation
- **Provider**: `agentphone-mcp` (Node/NPX).
- **Connection**: Supports both `StdioConnectionParams` and `StreamableHTTPConnectionParams`.
- **API Key**: Required via `AGENTPHONE_API_KEY` environment variable or Authorization header.

## 🎙️ ADK Streaming & Voice Agents
ADK supports low-latency, bidirectional voice and video communication via the **Gemini Live API**.

### Key Primitives
- **Runner.run_live()**: The primary entry point for real-time, event-driven agent interactions (Python).
- **SpeechConfig**: Configuration object for speech-to-text and text-to-speech behavior.
- **VoiceConfig**: Defines the specific voice profile (e.g., `PrebuiltVoiceConfig` with `voiceName` like "Aoede").
- **StreamingMode.BIDI**: Enables bidirectional streaming, essential for natural voice conversations.

### Development Workflow
- **adk web**: A development UI server (FastAPI-based in Python) for testing voice and video capabilities.
- **Voice/Video Constraints**: Native-audio models often do not support simultaneous text chat in the current ADK version.
- **Async Execution**: Voice agents require asynchronous runtimes to handle continuous audio streams and interruptions.

## 🧩 Tool Surface
The AgentPhone MCP server exposes several tool clusters:
- **Account**: `account_overview`, `get_usage`.
- **Numbers**: `list_numbers`, `buy_number`, `attach_number`.
- **SMS**: `send_message`, `get_messages`, `list_conversations`.
- **Voice**: `make_call`, `make_conversation_call`, `list_calls`, `list_voices`.
- **Agents**: `create_agent`, `update_agent`, `delete_agent`.

---
## References
- Source: `00_Raw/adk-documentation.md` (Lines 16211-16417, 880-1689)
- [[agent-development-kit]]
- [[telephony-agents]]
- [[mcp-moc]]
