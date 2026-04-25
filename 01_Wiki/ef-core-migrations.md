---
title: EF Core Migrations
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [ef-migrations, database-migrations]
---
# EF Core Migrations

**Migrations** are the standard way to manage database schema changes in an EF Core project. They allow you to evolve your database schema as your data model changes, without losing data.

## The Workflow
1.  **Modify Model:** Add or update C# entity classes.
2.  **Add Migration:** Run `dotnet ef migrations add <Name>`. EF Core compares the current model with a snapshot and generates a migration file.
3.  **Review Code:** The generated migration contains `Up()` (to apply changes) and `Down()` (to revert changes) methods.
4.  **Update Database:** Run `dotnet ef database update`. EF Core applies pending migrations to the database.

## Key Concepts
- **Migration Snapshot:** A file that captures the entire model state after a migration is added.
- **__EFMigrationsHistory Table:** A table in the database that tracks which migrations have already been applied.
- **SQL Script Generation:** You can generate SQL scripts from migrations for deployment in environments where the `dotnet` CLI isn't available.

## Agentic Use Case: Evolving Memories
As an agent's internal logic becomes more complex, its storage schema might need to change (e.g., adding "Confidence Scores" to a "Facts" table). Migrations provide a deterministic, version-controlled way to upgrade the agent's database without manual SQL intervention.

---
## References
- [[ms-learn-ef-core-overview]] (Source)
- [[ef-core-basics]]
- [[dotnet-moc]]
