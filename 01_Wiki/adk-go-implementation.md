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

The [[agent-development-kit|ADK]] Go SDK provides a high-performance, strongly-typed environment for building agents. It is designed to integrate seamlessly with the Go ecosystem (1.24.4+).

## 1. Project Initialization

```bash
mkdir my_agent && cd my_agent
go mod init my-agent/main
go get google.golang.org/adk@latest
```

## 2. Basic Agent Setup

A typical Go agent uses the `llmagent` package and a model provider like `gemini`.

```go
func main() {
    ctx := context.Background()

    // Initialize Model
    model, _ := gemini.NewModel(ctx, "gemini-1.5-flash", &genai.ClientConfig{
        APIKey: os.Getenv("GOOGLE_API_KEY"),
    })

    // Define Agent
    myAgent, _ := llmagent.New(llmagent.Config{
        Name:        "helper",
        Model:       model,
        Instruction: "You are a helpful assistant.",
        Tools: []tool.Tool{
            geminitool.GoogleSearch{},
        },
    })

    // Launch with default Runner
    l := full.NewLauncher()
    l.Execute(ctx, &launcher.Config{
        AgentLoader: agent.NewSingleLoader(myAgent),
    }, os.Args[1:])
}
```

## 3. Go-Specific Patterns

### `Launcher` and `AgentLoader`
Go uses a `Launcher` abstraction (from `google.golang.org/adk/cmd/launcher`) to handle command-line interaction and setup. The `AgentLoader` allows for dynamic loading of agents in multi-agent configurations.

### Interfaces
*   **Model:** `model.Model`
*   **Agent:** `agent.Agent`
*   **Tool:** `tool.Tool`

### State Management in Go
In Go, state access is typically via the `context` object in tools or callbacks, using `context.State().Get(key)` and `context.State().Set(key, value)`.

## 4. Why Go for ADK?
*   **Performance:** Lower overhead for high-concurrency multi-agent systems.
*   **Concurrency:** Leverages Go routines for efficient [[workflow-agents|ParallelAgent]] execution.
*   **Deployment:** Compiles to a single static binary, ideal for containerized or edge deployment.

---
*Source: [[lit-adk-documentation]]*

