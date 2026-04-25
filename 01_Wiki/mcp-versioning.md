---
title: MCP Versioning
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [mcp-version-negotiation, protocol-evolution]
---
# MCP Versioning

The Model Context Protocol uses a date-based versioning scheme to track protocol evolution and ensure interoperability between different versions of clients and servers.

## Version Identifier
Versions are identified by a string in the **`YYYY-MM-DD`** format (e.g., `2025-11-25`). 
*   This identifier is only incremented when **backwards-incompatible** changes are introduced.
*   Backward-compatible improvements are made to the current version without changing the identifier.

## Revisions States
*   **Draft**: Experimental specifications not yet ready for production.
*   **Current**: The authoritative, ready-to-use protocol version.
*   **Final**: Historical versions that are no longer updated.

## Version Negotiation
The negotiation process occurs during the initial `initialize` request:
1.  **Offer**: The Client sends its preferred protocol version to the Server.
2.  **Agreement**: The Server responds with the version it intends to use for the session.
3.  **Conflict**: If the Server cannot support the Client's version (or vice versa), the connection is terminated with a descriptive error.

---
## References
* Source: `00_Raw/mcp/Versioning.md`
* [[mcp-architecture]]
