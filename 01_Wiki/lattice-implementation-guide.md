---
title: "Lattice Implementation Guide: Callback Guardrails"
author: codex
date: 2026-04-26
status: active
type: permanent
aliases:
  - callback-runner-impl
  - lattice-rust-impl
---

# Lattice Implementation Guide: Callback Guardrails

This guide provides the concrete [[rust]] implementation patterns for the **Callback Guardrails** defined in [[capability-lattice-spec]] §8. It ensures that sensitive [[mcp-moc|MCP]] tools cannot be invoked unless a safety callback has been executed.

## 1. The Token Pattern

We use **Linear Types** (types that cannot be cloned or implicitly dropped without a consumption action, though Rust's affine types are "use-at-most-once") and **Phantom Data** to create a zero-cost proof of execution.

### Token Definition
```rust
use std::marker::PhantomData;

/// A proof-of-execution token for a specific Tool (T).
/// It is zero-sized and has no runtime overhead.
pub struct GuardrailToken<T> {
    _pd: PhantomData<T>,
}

// Ensure the token is NOT Clone or Copy to prevent reuse
// (Standard structs in Rust are already not Clone/Copy unless derived)
```

## 2. The `CallbackRunner` (The Mint)

The `CallbackRunner` is responsible for executing the `before_tool_callback` and minting the token only on success.

```rust
pub struct CallbackRunner {
    // Stores the user-provided callback
    callback: Box<dyn Fn(&CallbackContext, &serde_json::Value) -> Result<(), String> + Send + Sync>,
}

impl CallbackRunner {
    pub async fn run_before_tool<T: ToolCap>(
        &self,
        context: &CallbackContext,
        args: &T::Args,
    ) -> Result<GuardrailToken<T>, GuardrailError> {
        let args_value = serde_json::to_value(args).map_err(|e| GuardrailError::Serialization(e.to_string()))?;
        
        // Execute the callback
        (self.callback)(context, &args_value)
            .map_err(|msg| GuardrailError::Blocked(msg))?;
        
        // Success: Mint the token
        Ok(GuardrailToken { _pd: PhantomData })
    }
}
```

## 3. Tool Invocation Enforcement

Every tool implementation that requires safety must mandate the token in its signature.

```rust
pub trait ToolCap {
    type Args: serde::Serialize + serde::de::DeserializeOwned;
    type Output: serde::Serialize;
    const NAME: &'static str;
}

pub trait SecureTool: ToolCap {
    async fn call_secure(
        &self,
        args: Self::Args,
        token: GuardrailToken<Self>, // Mandatory proof
    ) -> Result<Self::Output, McpError>;
}
```

## 4. Opt-Out Mechanism (`NoGuardrailRequired`)

For tools that are inherently safe (e.g., `list_tools`, `get_version`), we use a **Sealed Trait** to allow explicit, safe bypasses.

```rust
/// Tools implementing this are declared safe to call without a guardrail.
pub trait NoGuardrailRequired: ToolCap {}

impl<T: NoGuardrailRequired> GuardrailToken<T> {
    /// Explicitly construct a token for safe tools.
    pub fn unchecked() -> Self {
        GuardrailToken { _pd: PhantomData }
    }
}
```

## 5. Integration Test (Compiler Verification)

The following fragment demonstrates the enforcement.

```rust
struct MySensitiveTool;
impl ToolCap for MySensitiveTool { ... }
impl SecureTool for MySensitiveTool { ... }

async fn run_workflow(runner: CallbackRunner, tool: MySensitiveTool) {
    let args = ...;

    // --- CASE 1: VIOLATION ---
    // This fails to compile: "mismatched types: expected GuardrailToken<MySensitiveTool>"
    // tool.call_secure(args, ()).await; 

    // --- CASE 2: COMPLIANCE ---
    let context = ...;
    if let Ok(token) = runner.run_before_tool::<MySensitiveTool>(&context, &args).await {
        tool.call_secure(args, token).await; // Compiles!
    }
}
```

## Recommendations for Vulture-MCP Integration
1.  **Refactor Dispatcher:** The MCP tool dispatcher must be updated to check if a tool implements `SecureTool`.
2.  **State Injection:** The `CallbackRunner` should be part of the `SharedState`.
3.  **Linearity Check:** Verify that tokens are consumed by `call_secure` to prevent a single token from being used to call a tool multiple times in a loop (though in most MCP scenarios, a tool is called once per request).

---
*Status: Codex Draft 1.0*

