---
title: EF Core Basics
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [entity-framework-core, ef-core-intro, db-context]
---
# EF Core Basics

**Entity Framework Core (EF Core)** is the modern Object-Relational Mapper (O/RM) for .NET. it allows developers to work with a database using .NET objects, eliminating the need for most of the data-access code that developers usually need to write.

## Core Components

### 1. DbContext
The `DbContext` is the primary class that coordinates EF Core functionality for a given data model. It:
- Manages database connections.
- Provides `DbSet<TEntity>` properties for each entity in the model.
- Tracks changes made to objects.
- Executes `SaveChanges()` to persist data.

### 2. Entities (POCOs)
Entities are Plain Old CLR Objects (POCOs) that represent the data in your database tables. They do not need to inherit from any base class, making them lightweight and easy to test.

### 3. LINQ to Entities
Queries are written using **LINQ**, which EF Core translates into the appropriate SQL for the specific database provider being used.

## Configuration Methods
- **Conventions:** Automatic mapping based on property names (e.g., a property named `Id` becomes the primary key).
- **Data Annotations:** Attributes applied directly to classes/properties (e.g., `[Key]`, `[StringLength(100)]`).
- **Fluent API:** Detailed configuration inside `OnModelCreating` using the `ModelBuilder` object.

## Significance for Agents
EF Core provides a structured, type-safe way for agents to store and retrieve data. Instead of raw SQL strings, an agent can interact with its "memory" or "knowledge base" using standard C# objects, which are easier to validate and manipulate.

---
## References
- [[ms-learn-ef-core-overview]] (Source)
- [[dotnet-moc]]
- [[csharp-linq]]
