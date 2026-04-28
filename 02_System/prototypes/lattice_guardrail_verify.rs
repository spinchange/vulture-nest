// Lattice Guardrail Verification Fragment
// This file serves as an "Executable Intent" to verify the type-level enforcement
// defined in capability-lattice-spec.md §8.
//
// To verify: `rustc --crate-type lib lattice_guardrail_verify.rs`
// (Expect failure on CASE 1, success on CASE 2)

use std::marker::PhantomData;

// --- Primitives ---

pub struct CallbackContext {
    pub agent_name: String,
}

#[derive(Debug)]
pub enum GuardrailError {
    Blocked(String),
}

pub enum McpError {
    Internal(String),
}

// --- Lattice Traits ---

pub trait ToolCap {
    type Args;
    type Output;
}

pub struct GuardrailToken<T: ToolCap> {
    _pd: PhantomData<T>,
}

pub struct CallbackRunner {
    pub agent_name: String,
}

impl CallbackRunner {
    pub fn run_before_tool<T: ToolCap>(
        &self,
        _args: &T::Args,
    ) -> Result<GuardrailToken<T>, GuardrailError> {
        // In a real impl, this would run the user's callback
        Ok(GuardrailToken { _pd: PhantomData })
    }
}

pub trait SecureTool: ToolCap {
    fn call_secure(
        &self,
        args: Self::Args,
        _token: GuardrailToken<Self>,
    ) -> Result<Self::Output, McpError>;
}

// --- Concrete Tool Implementation ---

struct FileReadArgs {
    path: String,
}

struct FileReadTool;

impl ToolCap for FileReadTool {
    type Args = FileReadArgs;
    type Output = String;
}

impl SecureTool for FileReadTool {
    fn call_secure(
        &self,
        _args: Self::Args,
        _token: GuardrailToken<Self>,
    ) -> Result<Self::Output, McpError> {
        Ok("File content".to_string())
    }
}

// --- Verification Cases ---

#[allow(dead_code)]
fn test_workflow() {
    let runner = CallbackRunner { agent_name: "AgentA".to_string() };
    let tool = FileReadTool;
    let args = FileReadArgs { path: "secret.txt".to_string() };

    // CASE 1: VIOLATION (Skip the callback)
    // UNCOMMENTING THE LINE BELOW SHOULD CAUSE A COMPILER ERROR:
    // "mismatched types: expected `GuardrailToken<FileReadTool>`, found `()`"
    // let _ = tool.call_secure(args, ()); 

    // CASE 2: COMPLIANCE (Run the callback to get the token)
    if let Ok(token) = runner.run_before_tool::<FileReadTool>(&args) {
        let _ = tool.call_secure(args, token);
        println!("Case 2: Success!");
    }
}
