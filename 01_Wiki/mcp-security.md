---
title: MCP Security and Authorization
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-security, mcp-authorization]
---
# MCP Security and Authorization

Security in the **Model Context Protocol (MCP)** is built on a "Host-mediated" trust model, where the **Host** (the application the user interacts with) is responsible for enforcing security boundaries and managing user consent.

## Authorization Model
MCP does not have a native, protocol-level "auth" header in the traditional web sense. Instead:
1. **Host Control**: The host application decides which servers to connect to and which capabilities to expose to the LLM.
2. **User Consent**: Hosts should prompt users for permission before an agent executes a tool or accesses a sensitive resource.
3. **Capability Negotiation**: During the `initialize` handshake, clients and servers exchange `capabilities` to define what they are allowed to do.

## Security Best Practices
* **Local-First**: Many MCP servers run as local subprocesses (stdio), inheriting the security context of the host application.
* **Input Validation**: Servers must treat all inputs from the LLM as untrusted.
* **Resource Sandboxing**: When possible, servers should limit their file system access to specific "root" directories.
* **Sampling Safety**: When a server requests "Sampling" (asking the LLM to generate text), the host must ensure the resulting text does not contain sensitive data from other contexts.

## Transport Security
* **Stdio**: Inherently secure as it is a local process pipe.
* **HTTP/SSE**: Requires standard network security measures (TLS/SSL) and potentially API keys if exposed over a network.

---
## References
* Source: `00_Raw/mcp/Secuirty Best Practices.md`, `00_Raw/mcp/Understanding Authorization in MCP.md`
* [[mcp-architecture]]
* [[mcp-primitives]]
