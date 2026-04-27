---
title: Rust Tier-0 Patterns
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases:
  - rust-safe-core
  - tier-0-substrate
  - rust-capability-enforcement
---

# Rust Tier-0 Patterns

**Purpose:** Document the code-level patterns for the "Safe Core" — the Rust binary that sits at the trust boundary of the multi-agent stack, enforces [[capability-lattice-spec]] constraints via the type system, and hands validated state to Tier-1 (Python) orchestrators via `serde`-serialized JSON.

The tier architecture:

```
┌─────────────────────────────────────────────────────────┐
│  Tier-0 (Rust)   — Safe Core                           │
│  • Type-safe capability enforcement                     │
│  • serde validation at the protocol boundary            │
│  • Spawn + communicate with Tier-1 via stdin/stdout     │
└──────────────────────────┬──────────────────────────────┘
                           │ JSON (validated, serde)
┌──────────────────────────┴──────────────────────────────┐
│  Tier-1 (Python)   — Orchestration                      │
│  • LLM calls (ADK / Swarm / Agents SDK)                 │
│  • Tool routing and multi-agent orchestration           │
│  • Trusts that incoming state was validated by Tier-0   │
└──────────────────────────┬──────────────────────────────┘
                           │ A2A / MCP
┌──────────────────────────┴──────────────────────────────┐
│  Tier-2 (Any)   — Agent Leaf Nodes                      │
│  • Specialist agents (research, billing, code, etc.)    │
│  • Communicate via A2A protocol                         │
└─────────────────────────────────────────────────────────┘
```

Tier-0 is not an orchestrator — it does not call LLMs. It is a validation and routing binary: it deserializes incoming messages, checks capability constraints, mints typed tokens, and serializes validated state for Tier-1 to consume.

---

## 1. Capability Enum

Unlike the trait-only approach in [[capability-lattice-spec]] §4 (which is for compile-time enforcement within a single binary), inter-tier communication requires capabilities to be **serializable values** that survive the Rust→Python boundary.

Define capabilities as a `serde`-compatible enum:

```rust
use serde::{Deserialize, Serialize};
use std::collections::HashSet;

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Capability {
    // Memory access
    ReadSessionMemory,
    WriteSessionMemory,
    ReadVaultMemory,
    WriteVaultMemory,
    PruneMemory,

    // Agent delegation
    DelegateReadOnly,
    DelegateReadWrite,

    // Agent handoff (ownership transfer)
    HandoffToAgent,

    // Sensitive operations requiring explicit grant
    ExecuteCode,
    ModifyVaultSchema,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct CapabilitySet(HashSet<Capability>);

impl CapabilitySet {
    pub fn new(caps: impl IntoIterator<Item = Capability>) -> Self {
        CapabilitySet(caps.into_iter().collect())
    }

    /// Lattice meet: largest capability set both parties share (safe delegation ceiling).
    pub fn meet(&self, other: &CapabilitySet) -> CapabilitySet {
        CapabilitySet(self.0.intersection(&other.0).cloned().collect())
    }

    /// Lattice join: union (for additive composition, NOT delegation).
    pub fn join(&self, other: &CapabilitySet) -> CapabilitySet {
        CapabilitySet(self.0.union(&other.0).cloned().collect())
    }

    pub fn contains(&self, cap: &Capability) -> bool {
        self.0.contains(cap)
    }

    pub fn is_subset_of(&self, other: &CapabilitySet) -> bool {
        self.0.is_subset(&other.0)
    }

    /// Check that required ⊆ self. Returns the missing capabilities if not.
    pub fn authorize(&self, required: &CapabilitySet) -> Result<(), UnauthorizedCaps> {
        let missing: HashSet<_> = required.0.difference(&self.0).cloned().collect();
        if missing.is_empty() {
            Ok(())
        } else {
            Err(UnauthorizedCaps(CapabilitySet(missing)))
        }
    }
}

#[derive(Debug, thiserror::Error)]
#[error("Unauthorized capabilities: {0:?}")]
pub struct UnauthorizedCaps(pub CapabilitySet);
```

**Why enum over traits for inter-tier?** Traits exist at compile time; a Python process cannot implement a Rust trait. The `Capability` enum serializes to `"read_vault_memory"` etc. — Python reads the JSON array and enforces the same semantic policy at its own level (by checking membership before routing). Rust enforces it at the type level *within* Tier-0; the serialized form carries the policy to Tier-1.

---

## 2. Protocol-Safe State Transfer

The state that flows from Tier-0 to Tier-1 must be fully validated before Python sees it. `#[serde(deny_unknown_fields)]` ensures no extra fields slip through; `#[serde(rename_all = "snake_case")]` maintains consistent naming across tiers.

```rust
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// The canonical state envelope passed from Tier-0 to Tier-1.
#[derive(Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct StateTransfer {
    /// Unique task identifier (A2A task_id or local UUID).
    pub task_id: String,

    /// Session scope identifier (for [[spec-memory-mcp]] namespace).
    pub session_id: String,

    /// What the Tier-1 orchestrator is authorized to do.
    pub scope: CapabilitySet,

    /// Flat key-value working memory (Swarm context_variables / A2A transfer_context.state).
    pub context: HashMap<String, serde_json::Value>,

    /// Named outputs from completed pipeline steps (ADK output_key / A2A output_keys).
    pub output_keys: HashMap<String, serde_json::Value>,

    /// Originating agent endpoint for audit trail (null if this is the root task).
    pub originating_agent: Option<String>,

    /// ISO 8601 timestamp of this state snapshot.
    pub snapshot_at: String,
}

impl StateTransfer {
    /// Validate structural invariants beyond what serde checks.
    pub fn validate(&self) -> Result<(), ValidationError> {
        if self.task_id.is_empty() {
            return Err(ValidationError::EmptyField("task_id"));
        }
        if self.session_id.is_empty() {
            return Err(ValidationError::EmptyField("session_id"));
        }
        // Context values must not contain nested CapabilitySets (prevent scope smuggling).
        for (key, val) in &self.context {
            if val.get("scope").is_some() && val.get("0").is_some() {
                return Err(ValidationError::ScopeSmuggling(key.clone()));
            }
        }
        Ok(())
    }
}

#[derive(Debug, thiserror::Error)]
pub enum ValidationError {
    #[error("Empty required field: {0}")]
    EmptyField(&'static str),
    #[error("Scope smuggling detected in context key: {0}")]
    ScopeSmuggling(String),
    #[error("Deserialization error: {0}")]
    Serde(#[from] serde_json::Error),
}
```

---

## 3. The Tier-0 Validation Gate

The entry point for every incoming message. Tier-0 never trusts raw bytes — it always deserializes and validates before acting:

```rust
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};

/// Read a StateTransfer from Tier-1 (via stdin), validate it, and return the typed value.
pub async fn receive_state(
    reader: &mut BufReader<tokio::io::Stdin>,
) -> Result<StateTransfer, GateError> {
    let mut line = String::new();
    reader.read_line(&mut line).await.map_err(GateError::Io)?;

    let transfer: StateTransfer = serde_json::from_str(line.trim())
        .map_err(|e| GateError::Validation(ValidationError::Serde(e)))?;

    transfer.validate().map_err(GateError::Validation)?;

    Ok(transfer)
}

/// Write a validated StateTransfer to Tier-1 (via stdout).
pub async fn send_state(
    writer: &mut tokio::io::Stdout,
    transfer: &StateTransfer,
) -> Result<(), GateError> {
    let json = serde_json::to_string(transfer).map_err(|e| GateError::Validation(ValidationError::Serde(e)))?;
    writer.write_all(json.as_bytes()).await.map_err(GateError::Io)?;
    writer.write_all(b"\n").await.map_err(GateError::Io)?;
    writer.flush().await.map_err(GateError::Io)?;
    Ok(())
}

#[derive(Debug, thiserror::Error)]
pub enum GateError {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Validation error: {0}")]
    Validation(#[from] ValidationError),
    #[error("Capability violation: {0}")]
    Unauthorized(#[from] UnauthorizedCaps),
}
```

---

## 4. Enforcing the Capability Lattice at the Gate

Before routing a delegation to Tier-1, Tier-0 checks the lattice constraint:

```rust
/// Gate a delegation request: compute effective caps and verify required ⊆ effective.
pub fn gate_delegation(
    orchestrator_scope: &CapabilitySet,
    target_agent_caps: &CapabilitySet,
    required_for_task: &CapabilitySet,
) -> Result<CapabilitySet, UnauthorizedCaps> {
    // Lattice meet: only what both parties share
    let effective = orchestrator_scope.meet(target_agent_caps);

    // Authorization check: required must be a subset of effective
    effective.authorize(required_for_task)?;

    Ok(effective)
}

/// Gate a handoff: same logic, but also verifies HandoffToAgent capability.
pub fn gate_handoff(
    orchestrator_scope: &CapabilitySet,
    target_agent_caps: &CapabilitySet,
    required_for_task: &CapabilitySet,
) -> Result<CapabilitySet, UnauthorizedCaps> {
    // Handoff requires explicit capability in orchestrator's scope
    let handoff_required = CapabilitySet::new([Capability::HandoffToAgent]);
    orchestrator_scope.authorize(&handoff_required)?;

    gate_delegation(orchestrator_scope, target_agent_caps, required_for_task)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn delegation_cannot_escalate() {
        let orchestrator = CapabilitySet::new([Capability::ReadVaultMemory, Capability::DelegateReadOnly]);
        let target       = CapabilitySet::new([Capability::ReadVaultMemory, Capability::WriteVaultMemory]);
        let required     = CapabilitySet::new([Capability::WriteVaultMemory]);

        // Orchestrator doesn't have WriteVaultMemory → effective doesn't include it → unauthorized
        let result = gate_delegation(&orchestrator, &target, &required);
        assert!(result.is_err(), "Should reject: orchestrator cannot grant write capability it doesn't have");
    }

    #[test]
    fn delegation_within_scope_succeeds() {
        let orchestrator = CapabilitySet::new([Capability::ReadVaultMemory, Capability::WriteVaultMemory, Capability::DelegateReadWrite]);
        let target       = CapabilitySet::new([Capability::ReadVaultMemory, Capability::WriteVaultMemory]);
        let required     = CapabilitySet::new([Capability::ReadVaultMemory]);

        let effective = gate_delegation(&orchestrator, &target, &required).unwrap();
        assert!(effective.contains(&Capability::ReadVaultMemory));
    }
}
```

---

## 5. The `GuardrailToken` Bridge

The `GuardrailToken<T>` pattern from [[capability-lattice-spec]] §8 works within a single Rust binary. For the inter-tier case, the token cannot cross the JSON boundary — Python cannot receive a Rust zero-sized type. The bridge: Tier-0 runs the guardrail check and **signs the state transfer** with the result.

```rust
use serde::{Deserialize, Serialize};

/// Proof that Tier-0 ran guardrail checks before forwarding to Tier-1.
#[derive(Debug, Serialize, Deserialize)]
pub struct GuardrailProof {
    /// Which capabilities were checked.
    pub checked_caps: CapabilitySet,
    /// HMAC-SHA256 of the StateTransfer JSON, keyed by the Tier-0 process secret.
    /// Tier-1 verifies this signature before trusting the state.
    pub signature: String,
    /// ISO 8601 timestamp of when the check ran.
    pub checked_at: String,
}

impl GuardrailProof {
    pub fn sign(transfer: &StateTransfer, checked_caps: CapabilitySet, secret: &[u8]) -> Self {
        use hmac::{Hmac, Mac};
        use sha2::Sha256;

        let body = serde_json::to_string(transfer).expect("serialization cannot fail here");
        let mut mac = Hmac::<Sha256>::new_from_slice(secret).expect("HMAC accepts any key size");
        mac.update(body.as_bytes());
        let sig = hex::encode(mac.finalize().into_bytes());

        GuardrailProof {
            checked_caps,
            signature: sig,
            checked_at: chrono::Utc::now().to_rfc3339(),
        }
    }
}

/// The full envelope sent from Tier-0 to Tier-1.
#[derive(Debug, Serialize, Deserialize)]
pub struct ValidatedEnvelope {
    pub state: StateTransfer,
    pub proof: GuardrailProof,
}
```

**Python Tier-1 verification (pseudocode):**
```python
import hmac, hashlib, json

def verify_envelope(envelope: dict, secret: bytes) -> bool:
    state_json = json.dumps(envelope["state"], separators=(",", ":"), sort_keys=True)
    expected = hmac.new(secret, state_json.encode(), hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, envelope["proof"]["signature"])
```

If verification fails, Tier-1 rejects the envelope and halts. This prevents a compromised Tier-1 process from forging state with elevated capabilities.

---

## 6. Complete Tier-0 Main Loop

```rust
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Load agent's authorized capability scope from config (not from incoming message)
    let my_scope: CapabilitySet = load_scope_from_config()?;

    // Load HMAC secret for envelope signing
    let secret = std::env::var("TIER0_SECRET")
        .expect("TIER0_SECRET must be set")
        .into_bytes();

    let stdin  = tokio::io::stdin();
    let stdout = tokio::io::stdout();
    let mut reader = BufReader::new(stdin);
    let mut writer = stdout;

    loop {
        // 1. Receive and validate incoming state from Tier-1 (or external input)
        let transfer = match receive_state(&mut reader).await {
            Ok(t)  => t,
            Err(e) => { eprintln!("Gate error: {e}"); continue; }
        };

        // 2. Load target agent's declared capabilities (from Agent Card cache or config)
        let target_caps: CapabilitySet = load_target_caps(&transfer.originating_agent)?;

        // 3. Determine what the task actually requires (from task metadata)
        let required: CapabilitySet = infer_required_caps(&transfer)?;

        // 4. Capability gate
        let effective = match gate_delegation(&my_scope, &target_caps, &required) {
            Ok(eff) => eff,
            Err(e)  => {
                eprintln!("Capability violation: {e}");
                send_error(&mut writer, "CAPABILITY_DENIED", &e.to_string()).await?;
                continue;
            }
        };

        // 5. Sign and forward to Tier-1
        let proof = GuardrailProof::sign(&transfer, effective.clone(), &secret);
        let envelope = ValidatedEnvelope { state: transfer, proof };
        let env_json = serde_json::to_string(&envelope)?;
        writer.write_all(env_json.as_bytes()).await?;
        writer.write_all(b"\n").await?;
        writer.flush().await?;
    }
}
```

---

## 7. serde Configuration Standards

All Tier-0 structs follow these conventions, per [[capability-lattice-spec]] §2 derivation rules:

| Convention | Attribute | Reason |
|---|---|---|
| Snake_case field names in JSON | `#[serde(rename_all = "snake_case")]` | Matches Python dict key convention |
| Unknown fields → error | `#[serde(deny_unknown_fields)]` | Prevents scope smuggling via unexpected fields |
| Optional fields → `Option<T>` | `#[serde(skip_serializing_if = "Option::is_none")]` | Clean JSON; absent = null |
| Enum variants as strings | `#[serde(rename_all = "snake_case")]` on enum | `"read_vault_memory"` readable cross-tier |
| Tag discriminants for unions | `#[serde(tag = "kind")]` | Mirrors A2A Part discriminant pattern |

---

## 8. Relationship to the Architecture

| Layer | Component | Enforced by |
|---|---|---|
| Compile-time (intra-Tier-0) | `HasCaps<T>` trait bounds, `GuardrailToken<T>` | Rust type checker |
| Runtime (inter-tier) | `gate_delegation()`, `GuardrailProof` HMAC | Tier-0 validation gate |
| Protocol (A2A / MCP) | Capability fields in Agent Card, tool manifests | MCP host / A2A orchestrator |
| OS (process isolation) | Separate processes for Tier-0 and Tier-1 | OS scheduler + `spawn()` |

Tier-0 is not a replacement for the higher layers — it is the lowest, most trustworthy one. All four layers must be active for the full safety predicate from [[capability-lattice-spec]] §8.6 to hold.

---

## References
- [[capability-lattice-spec]] — formal lattice model and trait-level enforcement
- [[lit-rust-programming-language]] — ownership, serde, async/await foundations
- [[rust-mcp-patterns]] — MCP server design in Rust
- [[pattern-capability-gating]] — the model-agnostic pattern this implements
- [[pattern-state-transfer]] — the state model validated at the gate
- [[spec-memory-mcp]] — the MCP server that Tier-0 gates access to
- [[community-protocol-trust-substrate]] — the three-layer trust model
- [[a2a-protocol]] — TRANSFERRED state validation uses this gate
- [[session-types-mcp-mapping]] — session types as the third enforcement layer
