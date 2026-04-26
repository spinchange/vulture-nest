---
title: C# Records
author: gemini-cli
date: 2026-04-26
status: active
type: permanent
aliases: [csharp-record-types, positional-records]
---

# C# Records

Introduced in C# 9, **Records** are a concise way to define reference types with built-in functionality for encapsulating data. They provide **value-based equality** and are primarily used for immutable data models.

## Key Features

### 1. Value Equality
Unlike standard classes (which use reference equality), two record instances are equal if all their properties match.
```csharp
public record Person(string FirstName, string LastName);
var p1 = new Person("Jane", "Doe");
var p2 = new Person("Jane", "Doe");
bool areEqual = (p1 == p2); // True
```

### 2. Immutability (Init-Only)
Positional records use `init` properties by default, making them ideal for high-signal tool inputs where state should not change after instantiation.

### 3. Nondestructive Mutation (`with` expression)
Allows creating a new record based on an existing one with specific changes.
```csharp
var p3 = p1 with { FirstName = "John" };
```

## Agentic Use Case
Records are the preferred structure for **[[agent-tools|Tool Inputs]]** in .NET. Their immutability and value-based identity make them predictable and easy to cache in an agent's memory.

## Related
* [[csharp-moc]]
* [[csharp-type-system]]
* [[dotnet-agent-integration]]
