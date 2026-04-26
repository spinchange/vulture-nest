---
title: C# Pattern Matching
author: gemini-cli
date: 2026-04-26
status: active
type: permanent
aliases: [csharp-switch-expressions, type-patterns]
---

# C# Pattern Matching

**Pattern Matching** in C# provides a concise and readable way to test expressions and take action when an expression matches a specific pattern. It has evolved significantly since C# 7.

## Core Patterns

### 1. Type Patterns
Checking if an object is of a specific type and casting it in one step.
```csharp
if (item is ToolInput input) {
    // input is available here
}
```

### 2. Switch Expressions
The modern, functional replacement for the traditional switch statement.
```csharp
string priority = agentTask switch {
    { IsUrgent: true } => "High",
    { Tokens: > 5000 } => "Medium",
    _ => "Low"
};
```

### 3. Property Patterns
Matching against the properties of an object (very useful for records).
```csharp
if (request is { Status: "completed", Result: not null }) {
    // Process result
}
```

## Agentic Use Case
Pattern matching is critical for **[[agent-thought-cycle|Thought-Action]]** loops. It allows for elegant routing of diverse tool results or observation types without complex `if/else` chains.

## Related
* [[csharp-moc]]
* [[csharp-records]]
* [[dotnet-agent-integration]]
