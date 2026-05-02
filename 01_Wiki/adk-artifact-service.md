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
*   **Versioning:** Artifacts are versioned by the configured service. The ADK docs describe `save_artifact` as returning an integer version number, with the first saved revision represented as version `0`, and `load_artifact(..., version=None)` as loading the latest version.
*   **Scoping:**
    *   **Session Scope:** Default. Artifacts are associated with the current `app`, `user`, and `sessionId`.
    *   **User Scope:** Prefixing a filename with `user:` (for example `user:settings.json`) is documented as a way to make the artifact accessible across sessions for the same user within the same application boundary.

## Service Implementations

### 1. `InMemoryArtifactService`
Stores artifacts in memory.
*   **Use Case:** Local testing, development, or transient tasks.
*   **Persistence:** Data is lost when the process terminates.
*   **Version model:** The ADK docs describe an in-memory version list keyed by app, user, session, and filename, so repeated saves create retrievable revisions for the life of the process.

### 2. `GcsArtifactService`
Uses Google Cloud Storage for persistent storage.
*   **Use Case:** Production environments, long-running agents, and cross-session memory.
*   **Features:** Persistent storage, service-managed version tracking, and better support for cross-session artifact retention. Exact storage details should be verified against the active ADK implementation and GCS configuration.

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
    version = await context.save_artifact("report.pdf", data)
    latest = await context.load_artifact("report.pdf")
    original = await context.load_artifact("report.pdf", version=version)
```

## Key Methods
*   `save_artifact(filename, data)`: Persists data and creates a new version.
*   `load_artifact(filename, version=None)`: Retrieves a specific or latest version.
*   `list_artifacts()`: Returns artifacts associated with the current scope. Check the active ADK docs for the exact return shape and metadata fields exposed by the implementation you are using.

## Caveats
*   Context artifact methods require a configured artifact service; the ADK docs note they raise errors if no service is attached to the runner.
*   `load_artifact` can return no result if the file or version does not exist, so callers should treat retrieval as fallible.
*   User-scoped names still need deliberate naming discipline. A path like `user:settings.json` is shared across that user's sessions for the app, so teams should define conventions to avoid accidental collisions between tools or features.
*   `InMemoryArtifactService` is convenient for development but can lose data on process exit and consume significant memory for large files.
*   Persistent services such as GCS add durability, but also bring storage cost, permissions, and cleanup concerns.

---
*Source: [[lit-adk-documentation]]*

## Related
- [[adk-session-service]]
- [[adk-long-term-memory]]
- [[agent-development-kit]]
