---
title: [[agent-development-kit|ADK]] Go Implementation
author: gemini-cli
date: '2026-04-26'
status: active
aliases:
  - adk-go
  - go-adk-sdk
type: permanent
---

# ADK Go Implementation

The [[agent-development-kit|ADK]] Go SDK gives ADK a compiled, strongly typed implementation path. In the ADK documentation snapshot summarized in [[lit-adk-documentation]], the Go quickstart targets Go `1.24.4+` and `google.golang.org/adk`, but specific APIs should still be verified against the current SDK before copying them into production code.

## 1. Project Initialization

```bash
mkdir my_agent && cd my_agent
go mod init my-agent/main
go get google.golang.org/adk
```

## 2. Basic Agent Setup

The ADK docs show a Go quickstart built around `llmagent`, Gemini model bindings, and the launcher packages. A safer reference example is:

```go
func main() {
    ctx := context.Background()

    model, err := gemini.NewModel(ctx, "gemini-1.5-flash", &genai.ClientConfig{
        APIKey: os.Getenv("GOOGLE_API_KEY"),
    })
    if err != nil {
        log.Fatal(err)
    }

    myAgent, err := llmagent.New(llmagent.Config{
        Name:        "helper",
        Model:       model,
        Instruction: "You are a helpful assistant.",
        Tools: []tool.Tool{
            geminitool.GoogleSearch{},
        },
    })
    if err != nil {
        log.Fatal(err)
    }

    l := full.NewLauncher()
    if err := l.Execute(ctx, &launcher.Config{
        AgentLoader: agent.NewSingleLoader(myAgent),
    }, os.Args[1:]); err != nil {
        log.Fatal(err)
    }
}
```

This reflects the shapes described in the quickstart, but it should still be treated as documentation-aligned scaffolding rather than a guarantee that every signature is unchanged in the latest release.

## 3. Go-Specific Patterns

### `Launcher` and `AgentLoader`
The ADK Go quickstart uses a `Launcher` abstraction from `google.golang.org/adk/cmd/launcher` and a `full.NewLauncher()` convenience entrypoint. `AgentLoader` is used to bind one or more agents into that runtime surface.

### Interfaces
*   **Model:** `model.Model`
*   **Agent:** `agent.Agent`
*   **Tool:** `tool.Tool`

### State Management in Go
The ADK docs also describe Go callback and session-state patterns using the runtime context, including `ctx.State().Set(...)`. When reading from state, treat lookups as fallible and handle missing keys or type assertions explicitly rather than assuming a value is always present.

## 4. Caveats
- The ADK Go surface is evolving; verify package paths, imports, and method signatures against current SDK docs or source before depending on this note as executable truth.
- The quickstart examples in the literature source are useful for orientation, but they are not a substitute for production-grade error handling and configuration.
- Tool types such as `geminitool.GoogleSearch{}` are examples from the docs, not a claim that every environment exposes them identically.

## 5. Why Go for ADK?
*   **Compiled deployment:** A single binary is operationally attractive for agent services and internal tools.
*   **Concurrency model:** Go's goroutines and channels fit well with [[workflow-agents]] and other orchestration-heavy workloads.
*   **Typed integration path:** The Go SDK gives a more explicit interface surface than prompt-only orchestration, which can help when wiring tools, sessions, and launchers together.

---
*Source: [[lit-adk-documentation]]*
*Related: [[agent-development-kit]], [[workflow-agents]], [[adk-session-service]], [[adk-artifact-service]]*

