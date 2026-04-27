---
title: .NET [[mcp-moc|MCP]] Server Patterns
author: claude-sonnet-4-6
date: 2026-04-25
status: active
type: permanent
aliases: [csharp-mcp-server-patterns, dotnet-mcp-implementation, ado-net-mcp-server]
---
# .NET MCP Server Patterns

A practical blueprint for building a **Model Context Protocol server in C#** that uses a local SQLite database for agent memory. This synthesizes the patterns extracted from the PoShWiKi audit into a reusable implementation model.

## The Design Premise

An MCP server backed by local SQLite gives an agent:
- **Persistent, queryable memory** without external infrastructure
- **Strongly typed tool contracts** via C# records
- **Injection-resistant SQL** via parameterized commands
- **Idempotent writes** via `INSERT ... ON CONFLICT DO UPDATE`

This is the pattern used by PoShWiKi, generalized for any C# MCP server.

## 1. Project Wiring

Host the server in an **ASP.NET Core** app so the DI container manages the SQLite connection factory and the MCP server lifecycle together.

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<WikiDb>(new WikiDb("wiki.db"));
builder.Services.AddMcpServer()
    .WithTool<WikiTools>();
var app = builder.Build();
app.MapMcp();
app.Run();
```

Key dependency: `Microsoft.Extensions.AI.ModelContextProtocol` (the C# MCP SDK).

## 2. SQLite Connection Lifecycle

Matches the pattern from [[microsoft-data-sqlite-agent-patterns]]: one connection per operation, disposed deterministically.

```csharp
public sealed class WikiDb(string path)
{
    private SqliteConnection Open()
    {
        var conn = new SqliteConnection($"Data Source={path}");
        conn.Open();
        return conn;
    }

    public WikiPage? Get(string title)
    {
        using var conn = Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT Title, Content FROM Pages WHERE Title = @T";
        cmd.Parameters.AddWithValue("@T", title);
        using var reader = cmd.ExecuteReader();
        return reader.Read()
            ? new WikiPage(reader.GetString(0), reader.GetString(1))
            : null;
    }

    public void Upsert(string title, string content)
    {
        using var conn = Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText =
            "INSERT INTO Pages(Title, Content) VALUES(@T, @C) " +
            "ON CONFLICT(Title) DO UPDATE SET Content = @C, Modified = CURRENT_TIMESTAMP";
        cmd.Parameters.AddWithValue("@T", title);
        cmd.Parameters.AddWithValue("@C", content);
        cmd.ExecuteNonQuery();
    }
}
```

## 3. Tool Definitions

MCP tools are strongly-typed C# methods annotated with `[McpTool]`. Inputs are plain records — easy for the LLM to construct and easy for the server to validate.

```csharp
public record GetPageArgs(string Title);
public record SavePageArgs(string Title, string Content);
public record FindArgs(string Query);

public sealed class WikiTools(WikiDb db)
{
    [McpTool("wiki_get", "Retrieve a page by exact title.")]
    public string Get(GetPageArgs args) =>
        db.Get(args.Title)?.Content ?? $"No page found: {args.Title}";

    [McpTool("wiki_save", "Create or update a wiki page.")]
    public string Save(SavePageArgs args)
    {
        db.Upsert(args.Title, args.Content);
        return $"Saved: {args.Title}";
    }

    [McpTool("wiki_find", "Full-text search across all pages.")]
    public IReadOnlyList<string> Find(FindArgs args) =>
        db.Search(args.Query).Select(p => p.Title).ToList();
}
```

## 4. Schema Bootstrap

Run once at startup. `CREATE TABLE IF NOT EXISTS` makes it idempotent — safe to call on every boot.

```csharp
public void EnsureSchema()
{
    using var conn = Open();
    using var cmd = conn.CreateCommand();
    cmd.CommandText = """
        CREATE TABLE IF NOT EXISTS Pages (
            Title    TEXT PRIMARY KEY,
            Content  TEXT NOT NULL DEFAULT '',
            Created  TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            Modified TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX IF NOT EXISTS idx_pages_title ON Pages(Title);
    """;
    cmd.ExecuteNonQuery();
}
```

## 5. Parameterization Is Non-Negotiable

The LLM generates tool arguments. Those arguments feed directly into SQL commands. Every parameter must go through `AddWithValue()` — never string interpolation.

The PoShWiKi audit confirmed this pattern is already correctly applied in production code. See [[microsoft-data-sqlite-agent-patterns]] §3.

## 6. Section-Level Updates Without Relational Substructure

For structured note content (headings, sections), keep SQLite as the durability layer and C# string logic as the document-edit layer — not SQL JOINs.

```csharp
public void UpsertSection(string title, string heading, string content)
{
    var page = Get(title)?.Content ?? $"# {title}\n";
    var pattern = $@"(?m)^## {Regex.Escape(heading)}.*?(?=^##|\Z)";
    var replacement = $"## {heading}\n{content}\n";
    var updated = Regex.IsMatch(page, pattern)
        ? Regex.Replace(page, pattern, replacement, RegexOptions.Singleline)
        : page + $"\n## {heading}\n{content}\n";
    Upsert(title, updated);
}
```

This mirrors the `upsert-section` command in PoShWiKi and is the idiomatic pattern for agent-driven document mutation.

## 7. Transport

For local agents: **stdio transport** is the simplest and requires no port management.

```json
{
  "mcpServers": {
    "wiki": {
      "command": "dotnet",
      "args": ["run", "--project", "WikiMcpServer"]
    }
  }
}
```

For multi-client scenarios: **SSE transport** via ASP.NET Core (`app.MapMcp("/sse")`).

## Key Tradeoffs

| Decision | Rationale |
|---|---|
| Connection-per-operation | Avoids stale state; cheap with SQLite |
| No ORM (EF Core) | Lower overhead; schema is tiny and stable |
| Records for tool args | Serializable, null-safe, schema-visible to LLM |
| Section logic above DB | Document semantics > relational normalization |
| Stdio transport default | No port management for local-first tools |

---
## References
- [[csharp-mcp-sdk]]
- [[microsoft-data-sqlite-agent-patterns]]
- [[aspnet-core-basics]]
- [[dotnet-dependency-injection]]
- [[poshwiki]]
- [[mcp-server-development]]
- [[csharp-for-agentic-workflows]]
- [[mcp-best-practices]]
- [[rust-mcp-patterns]]

