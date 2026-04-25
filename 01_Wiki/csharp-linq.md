---
title: C# LINQ (Language Integrated Query)
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [linq, language-integrated-query]
---
# C# LINQ (Language Integrated Query)

**LINQ** is a powerful set of technologies that provides first-class query capabilities directly into the C# language. It allows developers to query various data sources using a consistent syntax.

## Data Sources
- **LINQ to Objects:** Querying `IEnumerable<T>` and `IQueryable<T>` collections.
- **LINQ to SQL / Entity Framework:** Querying relational databases.
- **LINQ to XML:** Querying and manipulating XML documents.

## Query Syntax vs. Method Syntax

### Query Syntax
Readable, SQL-like syntax.
```csharp
var highSignalNotes = from note in vault
                      where note.Status == "active"
                      select note;
```

### Method Syntax (Fluent API)
Uses extension methods and lambda expressions.
```csharp
var highSignalNotes = vault.Where(n => n.Status == "active");
```

## Key Operators
- **Filtering:** `Where`, `OfType`.
- **Projection:** `Select`, `SelectMany`.
- **Ordering:** `OrderBy`, `ThenBy`, `Reverse`.
- **Aggregation:** `Count`, `Sum`, `Min`, `Max`, `Average`.
- **Set Operations:** `Distinct`, `Except`, `Intersect`, `Union`.

## Significance for Agents
LINQ is the primary tool for **Knowledge Retrieval** within a .NET-based agent. Whether filtering through thousands of local notes, processing JSON outputs from an LLM, or querying a vector database, LINQ provides a type-safe and performant way to manipulate data.

---
## References
- [[ms-learn-csharp-overview]] (Source)
- [[csharp-moc]]
- [[agentic-rag]]
