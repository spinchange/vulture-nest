---
title: Capability Lattice — Formal Specification
author: claude-sonnet-4-6
date: 2026-04-25T00:00:00.000Z
status: draft
type: permanent
aliases:
  - capability-lattice
  - mcp-type-bridge
  - lattice-spec
---
# Capability Lattice: Formal Specification

**Context:** [[community-protocol-trust-substrate]] proposes that MCP tool manifests and Rust/C# type systems encode the same permission-boundary principle at different abstraction layers. This spec formalizes the bridge: how an MCP tool definition maps to a concrete language type signature, and how composing agents produces a new, derivable capability set.

---

## 1. JSON Schema → Language Type Mapping

MCP tool schemas are expressed in JSON Schema (draft 2020-12). The following table defines the canonical mapping to Rust and C# primitive types.

| JSON Schema | Rust | C# |
|---|---|---|
| `"type": "string"` | `String` | `string` |
| `"type": "integer"` | `i64` | `long` |
| `"type": "number"` | `f64` | `double` |
| `"type": "boolean"` | `bool` | `bool` |
| `"type": "array", "items": T` | `Vec<T>` | `IReadOnlyList<T>` |
| `"type": "object"` + `properties` | `struct` (serde) | `record` |
| property absent from `required` | `Option<T>` | `T?` (nullable) |
| `"enum": ["a", "b"]` | `enum` + `#[serde(rename_all)]` | `enum` + `[JsonConverter]` |
| `"additionalProperties": T` | `HashMap<String, T>` | `Dictionary<string, T>` |
| `"oneOf"` / discriminated union | `enum` with named variants | sealed class hierarchy or discriminated union (C# 9+) |

**Invariant:** Every property listed in the schema's `required` array maps to a non-optional type. Every property absent from `required` maps to `Option<T>` / `T?`. This invariant must be enforced at codegen or review time; it is not checked by the MCP protocol itself.

---

## 2. MCP Tool → Rust Function Signature

### 2.1 Schema

```
MCP Tool
  name:         string        → fn name (snake_case)
  description:  string        → doc comment
  inputSchema:  JSON Schema   → struct Args (serde::Deserialize)
  outputSchema: JSON Schema   → struct Success (serde::Serialize)
  (error)                     → enum McpError (custom, protocol-compliant)

Rust signature:
  async fn {name}(args: {Name}Args, state: SharedState) -> Result<{Name}Success, McpError>
```

`SharedState` is `Arc<RwLock<ServerState>>` per the [[rust-mcp-patterns]] blueprint. It is injected at the server level, not per-argument. Tool arguments (`args`) carry only what the MCP client sent; server state is a separate parameter.

### 2.2 Struct Derivation Rules

1. Each `inputSchema.properties` key becomes a struct field in `{Name}Args`.
2. Each field's type is derived from the JSON Schema type via the mapping table.
3. Fields absent from `required` are wrapped in `Option<T>`.
4. The struct derives `serde::Deserialize`. The tool dispatcher calls `serde_json::from_value(params)?` to produce the args value; validation is implicit in deserialization.
5. `outputSchema` (if present) generates `{Name}Success` with `serde::Serialize`. If `outputSchema` is absent, the return type is `serde_json::Value`.

### 2.3 Error Type

```rust
#[derive(Debug, thiserror::Error)]
enum McpError {
    #[error("Invalid params: {0}")]
    InvalidParams(String),      // JSON-RPC -32602
    #[error("Tool not found: {0}")]
    ToolNotFound(String),       // JSON-RPC -32601
    #[error("Internal error: {0}")]
    Internal(String),           // JSON-RPC -32603
    #[error("Permission denied: {0}")]
    PermissionDenied(String),   // JSON-RPC -32000 (application-defined)
}
```

The `?` operator propagates `McpError` back through the async fn chain to the dispatcher, which serializes it into the JSON-RPC error response object.

---

## 3. MCP Tool → C# Method Signature

### 3.1 Schema

```
MCP Tool
  name:         string        → [McpTool("{name}", "{description}")] attribute
  description:  string        → attribute second arg + XML doc comment
  inputSchema:  JSON Schema   → record {Name}Args (positional record)
  outputSchema: JSON Schema   → record {Name}Result
  (DI services)               → [FromServices] parameters, before args

C# signature:
  [McpTool("{name}", "{description}")]
  public async Task<{Name}Result> {NamePascal}(
      [FromServices] IDependency dep,   // zero or more DI-injected services
      {Name}Args args,                  // deserialized from inputSchema
      CancellationToken ct = default)
```

### 3.2 Record Derivation Rules

1. Each `inputSchema.properties` key becomes a positional parameter in `record {Name}Args(...)`.
2. Type mapping follows the table in §1.
3. Optional properties (absent from `required`) become nullable `T?` parameters with a default of `null`.
4. `outputSchema` generates `record {Name}Result(...)` with the same rules.
5. If `outputSchema` is absent, the return type is `string` (serialized JSON) or `object`.

### 3.3 ASP.NET Core DI Scope Guidance

The C# MCP SDK resolves `[FromServices]` parameters from the DI container at tool-invocation time. The appropriate lifetime depends on the service's statefulness:

| Service type | Correct lifetime | Rationale |
|---|---|---|
| Stateless utility (e.g., `IPathValidator`) | `Singleton` | Cheap; shared safely across all invocations |
| Per-request context (e.g., `IUserContext`) | `Scoped` | One instance per tool invocation scope; disposed after |
| Stateful, non-thread-safe (e.g., `DbContext`) | `Scoped` | Prevents cross-invocation data leakage |
| Short-lived, cheap-to-create | `Transient` | New instance per injection point; use sparingly |

**Rule:** Never inject a `Scoped` service into a `Singleton`. The container will throw at startup (`InvalidOperationException: Cannot consume scoped service from singleton`). MCP tool handlers are themselves effectively Scoped when using the ASP.NET Core host model.

---

## 4. Capability Set: Formal Definition

### 4.1 Definition

Let `S` be an MCP server. Its **capability set** is:

```
Caps(S) = { (name, ArgType, ResultType) | tool ∈ S.manifest }
```

Each element is a triple: the tool's name, its input type, and its output type. This is the typed interface of the server, not just a list of names.

### 4.2 Capability Set as a Type

In Rust, a capability set is expressed as a set of trait bounds. The implementation mechanism is [[rust-phantom-types]] — each agent carries a phantom type parameter representing its capability set, and `HasCaps<C>` trait bounds constrain which operations are callable. The `HasCaps` pattern is a type-level function in the sense described in [[rust-type-level-programming]] §Type-Level Functions.

```rust
// Each tool defines a trait
trait CanReadFile {
    async fn read_file(&self, args: ReadFileArgs) -> Result<ReadFileSuccess, McpError>;
}
trait CanWriteFile {
    async fn write_file(&self, args: WriteFileArgs) -> Result<WriteFileSuccess, McpError>;
}

// A server's capability set is the union of its tool traits
trait FileManagerCaps: CanReadFile + CanWriteFile {}
```

In C#, the equivalent is a set of interfaces:

```csharp
interface ICanReadFile  { Task<ReadFileResult>  ReadFileAsync(ReadFileArgs args, CancellationToken ct); }
interface ICanWriteFile { Task<WriteFileResult> WriteFileAsync(WriteFileArgs args, CancellationToken ct); }

interface IFileManagerCaps : ICanReadFile, ICanWriteFile {}
```

### 4.3 Composition Operation: Delegation as Meet (∩)

When orchestrator `O` delegates a task to subagent `S`, the **effective capability** of that delegation is:

```
Effective(O → S) = Caps(S) ∩ Scope(O)
```

Where `Scope(O)` is the set of capabilities O is currently authorized to use (a subset of `Caps(O)` as granted by its own server manifest and any upstream constraints).

This mirrors Rust's ownership rule: **you cannot grant what you do not possess.** An orchestrator that does not have `writeFile` in its own scope cannot grant it to a subagent, even if the subagent's server exposes it.

#### Type-Level Expression in Rust

```rust
// Delegation is constrained by both parties satisfying the same trait bound
fn delegate<O, S, SharedCaps>(orchestrator: &O, subagent: &S) -> DelegatedAgent<SharedCaps>
where
    O: HasCaps<SharedCaps>,   // orchestrator must have these caps
    S: HasCaps<SharedCaps>,   // subagent must also have these caps
{
    // Only SharedCaps tools are callable on the returned agent
    DelegatedAgent::new(subagent)
}
```

The compiler enforces that `SharedCaps` is a bound both parties satisfy. Attempting to call a capability outside `SharedCaps` is a **compile-time type error**, not a runtime authorization failure. The "you cannot grant what you do not possess" property is a direct consequence of Rust's affine type system — see [[rust-affine-types]] §Connection to the Trust Substrate.

#### Lattice Structure

The full capability lattice is:

```
       ⊤ (all possible tools)
      / \
 Caps(A)  Caps(B)
      \ /
  Caps(A) ∩ Caps(B)   ← maximum safe delegation scope
      |
      ⊥ (empty — no capabilities)
```

- **Meet (∩):** The largest capability set both parties possess; the safe delegation ceiling.
- **Join (∪):** The union of capabilities; the scope of a combined agent (not a delegation — this is additive composition, not restriction).
- **Monotonicity:** Delegation is monotone-decreasing. A subagent can never receive more capability than its orchestrator possesses. Every step down the delegation chain can only reduce or preserve capability, never increase it.

### 4.4 Static Analysis Query

Given a multi-agent workflow graph `G = (V, E)` where vertices are agents and edges are delegations, the static analysis question is:

> Does any agent `v ∈ V` transitively receive a capability `c ∉ AllowList(v)`?

This is computable by:
1. Constructing `Caps(v)` for each vertex from its MCP server manifest.
2. Propagating `Effective(u → v) = Caps(v) ∩ Scope(u)` along each edge.
3. Checking at each vertex whether the computed effective caps include any disallowed capability.

If capability sets are types (trait sets / interface sets), this analysis is the type checker itself, executed at compile time.

---

## 5. Worked Example: FileManager MCP Server

### 5.1 MCP Manifest

```json
{
  "name": "FileManager",
  "tools": [
    {
      "name": "readFile",
      "description": "Read the contents of a file within the permitted root.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "path":     { "type": "string" },
          "encoding": { "type": "string", "enum": ["utf8", "base64"] }
        },
        "required": ["path"]
      },
      "outputSchema": {
        "type": "object",
        "properties": {
          "content":    { "type": "string" },
          "size_bytes": { "type": "integer" }
        },
        "required": ["content"]
      }
    },
    {
      "name": "writeFile",
      "description": "Write content to a file within the permitted root.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "path":    { "type": "string" },
          "content": { "type": "string" },
          "append":  { "type": "boolean" }
        },
        "required": ["path", "content"]
      },
      "outputSchema": {
        "type": "object",
        "properties": {
          "bytes_written": { "type": "integer" }
        },
        "required": ["bytes_written"]
      }
    }
  ]
}
```

### 5.2 Rust Implementation

```rust
// --- Args / Result types (derived from manifest) ---

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct ReadFileArgs {
    path: String,
    encoding: Option<Encoding>,
}

#[derive(Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
enum Encoding { Utf8, Base64 }

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct ReadFileSuccess {
    content: String,
    size_bytes: Option<i64>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct WriteFileArgs {
    path: String,
    content: String,
    append: Option<bool>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct WriteFileSuccess {
    bytes_written: i64,
}

// --- Tool handler functions ---

async fn read_file(
    args: ReadFileArgs,
    state: SharedState,
) -> Result<ReadFileSuccess, McpError> {
    let root = state.read().await.permitted_root.clone();
    let full_path = root.join(&args.path).canonicalize()
        .map_err(|_| McpError::PermissionDenied(args.path.clone()))?;
    // enforce root confinement
    if !full_path.starts_with(&root) {
        return Err(McpError::PermissionDenied(args.path));
    }
    let bytes = tokio::fs::read(&full_path).await
        .map_err(|e| McpError::Internal(e.to_string()))?;
    let size_bytes = bytes.len() as i64;
    let content = match args.encoding {
        Some(Encoding::Base64) => BASE64.encode(&bytes),
        _ => String::from_utf8(bytes).map_err(|e| McpError::Internal(e.to_string()))?,
    };
    Ok(ReadFileSuccess { content, size_bytes: Some(size_bytes) })
}

async fn write_file(
    args: WriteFileArgs,
    state: SharedState,
) -> Result<WriteFileSuccess, McpError> {
    let root = state.read().await.permitted_root.clone();
    let full_path = root.join(&args.path);
    let bytes = args.content.as_bytes();
    if args.append.unwrap_or(false) {
        let mut f = tokio::fs::OpenOptions::new().append(true).open(&full_path).await
            .map_err(|e| McpError::Internal(e.to_string()))?;
        tokio::io::AsyncWriteExt::write_all(&mut f, bytes).await
            .map_err(|e| McpError::Internal(e.to_string()))?;
    } else {
        tokio::fs::write(&full_path, bytes).await
            .map_err(|e| McpError::Internal(e.to_string()))?;
    }
    Ok(WriteFileSuccess { bytes_written: bytes.len() as i64 })
}

// --- Capability traits ---

trait CanReadFile  { async fn read_file(&self, args: ReadFileArgs)  -> Result<ReadFileSuccess, McpError>; }
trait CanWriteFile { async fn write_file(&self, args: WriteFileArgs) -> Result<WriteFileSuccess, McpError>; }
trait FileManagerCaps: CanReadFile + CanWriteFile {}
```

### 5.3 C# Implementation

```csharp
// --- Args / Result records (derived from manifest) ---

public record ReadFileArgs(
    string Path,
    string? Encoding = null);

public record ReadFileResult(
    string Content,
    long? SizeBytes = null);

public record WriteFileArgs(
    string Path,
    string Content,
    bool? Append = null);

public record WriteFileResult(long BytesWritten);

// --- Tool handler methods ---

[McpTool("readFile", "Read the contents of a file within the permitted root.")]
public async Task<ReadFileResult> ReadFile(
    ReadFileArgs args,
    [FromServices] IFileSystemService fs,   // Scoped: per-invocation isolation
    CancellationToken ct = default)
{
    var content = await fs.ReadAsync(args.Path, args.Encoding, ct);
    return new ReadFileResult(content.Text, content.SizeBytes);
}

[McpTool("writeFile", "Write content to a file within the permitted root.")]
public async Task<WriteFileResult> WriteFile(
    WriteFileArgs args,
    [FromServices] IFileSystemService fs,   // same Scoped service instance in this invocation
    CancellationToken ct = default)
{
    var written = await fs.WriteAsync(args.Path, args.Content, args.Append ?? false, ct);
    return new WriteFileResult(written);
}

// --- Capability interfaces ---

interface ICanReadFile  { Task<ReadFileResult>  ReadFileAsync(ReadFileArgs args, CancellationToken ct); }
interface ICanWriteFile { Task<WriteFileResult> WriteFileAsync(WriteFileArgs args, CancellationToken ct); }
interface IFileManagerCaps : ICanReadFile, ICanWriteFile {}
```

**DI registration:**
```csharp
builder.Services.AddScoped<IFileSystemService, SandboxedFileSystemService>();
// McpServer resolves tool handlers per-invocation within a DI scope
builder.Services.AddMcpServer().WithTool<FileManagerTools>();
```

`IFileSystemService` is `Scoped` because `SandboxedFileSystemService` holds per-request path validation state (the permitted root, resolved at invocation time from the MCP session context). A `Singleton` would share this state across users — a security bug.

---

## 6. Relationship to the Trust Substrate

This spec is the missing piece [[community-protocol-trust-substrate]] identifies. The three layers now connect:

| Layer | Mechanism | Enforcement point |
|---|---|---|
| Runtime isolation | [[docker-sandbox]] | OS process boundary |
| Protocol isolation | MCP manifest + capability negotiation | MCP host at connection time |
| **Type-level isolation** | **Capability Lattice (this spec)** | **Compiler / static analyzer** |

The lattice layer is the strongest because it eliminates a class of errors that runtime and protocol layers only detect (or fail to detect). A type error in the delegation chain is caught before deployment, not after an unauthorized tool call reaches production.

---

## 7. Open Questions: Capability Existence vs. Capability Sequencing

This spec addresses **capability existence** — whether a tool is in an agent's registered capability set. It does not address **capability sequencing** — whether a tool may be called at the *current point* in a stateful protocol.

The distinction matters for MCP specifically. MCP's connection lifecycle moves through distinct phases (Initialize → Active → Closed). A tool like `tools/call` is in the capability set from the moment the server manifest is parsed — but it is only legally callable after the `initialized` notification has been exchanged. The lattice alone cannot detect a client that calls `tools/call` before completing the handshake.

**Session types** are the natural extension that closes this gap. Where the capability lattice is a static map of which tools exist, a session type is a protocol state machine that tracks which tools are valid *right now*, given the current connection phase. The two are orthogonal:

```
Safe(agent, operation, connection_state) iff
    operation ∈ Caps(agent)            ← capability lattice (this spec)
    AND state → operation is valid     ← session type
```

The full formal treatment — including MCP's lifecycle expressed as a session type and a sketch of a phantom-typed MCP client SDK — is in [[session-types-mcp-mapping]]. That note has `status: draft`; the two analyses compose but neither subsumes the other.

---

## References
- [[community-protocol-trust-substrate]]
- [[session-types-mcp-mapping]]
- [[rust-mcp-patterns]]
- [[csharp-mcp-sdk]]
- [[mcp-primitives]]
- [[mcp-architecture]]
- [[dotnet-dependency-injection]]
- [[mcp-security]]
- [[docker-sandbox]]


---
## References
- [[claude-capability-lattice-handoff]]