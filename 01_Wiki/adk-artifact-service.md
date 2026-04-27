---
title: [[agent-development-kit|ADK]] Artifact Service
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - artifact-service
  - adk-artifacts
  - GcsArtifactService
  - InMemoryArtifactService
type: permanent
---

# ADK Artifact Service

The **Artifact Service** in the [[agent-development-kit|ADK]] manages the persistence, retrieval, and versioning of binary data (images, PDFs, generated reports) produced or consumed during an agent's session.

## Core Concepts
*   **Abstraction:** Agents interact with artifacts via the `CallbackContext` or `ToolContext`, which abstracts the underlying storage backend.
*   **Versioning:** Artifacts are automatically versioned. Each save operation creates a new version of the file.
*   **Scoping:**
    *   **Session Scope:** Default. Artifacts are associated with a specific `sessionId`.
    *   **User Scope:** Prefixing a filename with `user:` (e.g., `user:settings.json`) scopes the artifact to the user, making it accessible across multiple sessions (supported by `GcsArtifactService`).

## Service Implementations

### 1. `InMemoryArtifactService`
Stores artifacts in memory.
*   **Use Case:** Local testing, development, or transient tasks.
*   **Persistence:** Data is lost when the process terminates.

### 2. `GcsArtifactService`
Uses Google Cloud Storage for persistent storage.
*   **Use Case:** Production environments, long-running agents, and cross-session memory.
*   **Features:** Explicit versioning as GCS objects and namespace support.

## Developer Workflow

### Configuration
The service must be provided to the `Runner` during initialization.

```go
// Go Example
artifactService := artifact.InMemoryService()
runnerConfig := &launcher.Config{
    ArtifactService: artifactService,
    // ... other config
}
```

### Usage (Context)
Agents save and load artifacts through their context objects.

```python
# [[python]] Example
async def my_tool(context: ToolContext):
    data = b"Some binary content"
    await context.save_artifact("report.pdf", data)
```

## Key Methods
*   `save_artifact(filename, data)`: Persists data and creates a new version.
*   `load_artifact(filename, version=None)`: Retrieves a specific or latest version.
*   `list_artifacts()`: Returns all artifacts associated with the current scope.

---
*Source: [[lit-adk-documentation]]*

## Related
- [[adk-session-service]]

