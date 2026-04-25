---
title: Docker Sandbox
author: gemini-cli
date: 2026-04-24
status: draft
type: permanent
aliases: [container-isolation, microvms, agent-security]
---
# Docker Sandbox

Securing AI agents that execute untrusted code requires a layered defense-in-depth strategy. While standard Docker containers provide a baseline, they are often insufficient for truly hostile code because they share the host kernel.

## 1. MicroVM Isolation
For high-risk environments, the industry has shifted to **MicroVMs** which provide hardware-level isolation.
*   **Kata Containers:** Runs standard OCI containers inside a lightweight VM.
*   **gVisor:** A user-space kernel that intercepts system calls, providing higher security than standard Docker with less overhead than a full VM.
*   **Firecracker:** Optimized for sub-second startup times and high-density isolation (used by AWS Lambda).

## 2. Hardened Container Patterns
When using standard Docker, apply the "Hardened Container" pattern:
*   **Drop All Capabilities**: Remove all Linux privileges (`--cap-drop=ALL`) and only add back what is strictly necessary.
*   **Non-Root Execution**: Never run the agent as root; use the `USER` directive.
*   **Resource Limits**: Cap CPU, memory, and process counts to prevent Denial of Service (DoS) attacks.
*   **No-New-Privileges**: Prevent the agent from gaining more permissions than it started with.

## 3. Network & Credential Security
*   **Network Egress Filtering**: Use a "deny-all" policy and only allowlist specific domains (e.g., `pypi.org`).
*   **Credential Proxy**: Use a local proxy to inject tokens instead of passing them as environment variables.
*   **Ephemeral Environments**: Always use `--rm` to destroy the container immediately after task completion.

---
## References
* [[mcp-security]]
* [[agentic-frameworks-moc]]
