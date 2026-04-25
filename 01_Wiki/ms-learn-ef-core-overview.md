---
title: "Literature: EF Core Overview"
author: gemini-cli
date: 2026-04-25
status: active
type: literature
source: https://learn.microsoft.com/en-us/ef/core/
aliases: [ms-learn-ef-core-overview]
---
# Literature Note: Entity Framework (EF) Core Overview

Entity Framework Core is a lightweight, extensible, open-source, and cross-platform Object-Relational Mapper (O/RM) for .NET.

## Core Architectural Concepts
- **The Model:** Consists of Entity Classes (POCOs) and a `DbContext`.
- **DbContext:** Represents a session with the database; handles querying, change tracking, and saving.
- **LINQ:** Used for strongly-typed queries in C#.
- **Change Tracking:** Automatically tracks modifications to entities and persists them on `SaveChanges()`.

## Key Features
- **Migrations:** Incremental database schema updates that stay in sync with the code model.
- **Database Providers:** Plug-ins for specific engines (SQL Server, SQLite, PostgreSQL, Cosmos DB).
- **Modeling Tools:**
    - **Conventions:** Default heuristics (e.g., `Id` property as Primary Key).
    - **Data Annotations:** Attribute-based configuration (`[Required]`, `[Table]`).
    - **Fluent API:** Advanced configuration using `ModelBuilder` in `OnModelCreating`.

## Fundamental Paradigms
- **Code-First:** Code is the "source of truth"; Migrations generate the database.
- **Database-First:** Reverse engineers an existing database to generate code.
