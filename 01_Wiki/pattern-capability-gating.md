---
title: 'Pattern: Capability Gating'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases:
  - capability-enforcement
  - delegation-authorization
  - lattice-gating
---

# Pattern: Capability Gating

**Intent:** Before any agent delegates to or hands off to another agent, verify that the target's required capabilities fall within the authorized scope of the requesting agent. Violations are rejected at the boundary — never silently forwarded.

Capability Gating is the authorization layer of multi-agent systems. Without it, a compromised or misconfigured agent can escalate privileges by routing tasks to agents with broader capabilities than its own scope permits.

---

## The Lattice Rule

Per [[capability-lattice-spec]], the effective capability of a delegation edge is the **meet** (intersection) of the target's declared capabilities and the caller's authorized scope:

```
Effective(A → B) = Caps(B) ∩ Scope(A)
Required(task)  ⊆ Effective(A → B)   ← must hold before delegation proceeds
```

If `Required ⊄ Effective`, the delegation **must not proceed**. The calling agent should transition to `FAILED` (or `INPUT_REQUIRED` for human escalation) — never silently route to an out-of-scope agent.

This is a **monotone constraint**: a delegation chain can only narrow capabilities, never expand them. An agent with read-only scope cannot grant write access by routing through an agent that has it.

---

## Framework Implementations

### A2A — Explicit Lattice Enforcement
A2A formalizes capability gating as a pre-flight check before `TRANSFERRED`:
```
before state = TRANSFERRED:
  allowed = Caps(TargetAgent) ∩ Scope(OriginatingAgent)
  required = Skills declared necessary for the task
  assert required ⊆ allowed
  if assertion fails:
    state = FAILED
    reason = "Capability scope violation: {required - allowed}"
```
The `AgentCard` provides `Caps(TargetAgent)` via the `/.well-known/agent-card.json` discovery endpoint. `Scope(OriginatingAgent)` is configured at deployment time and enforced by the orchestrator.

### ADK — Implicit Hierarchy
ADK enforces capability scope through its agent hierarchy. A child agent can only access tools and state that the parent has explicitly passed or granted. There is no out-of-band scope declaration, so the constraint is enforced structurally (by what the parent wires up) rather than declaratively.

```python
# The parent controls which tools the sub-agent can see
coordinator = LlmAgent(
    sub_agents=[
        read_only_agent,      # has only read tools
        # write_agent NOT included → coordinator cannot delegate write tasks
    ]
)
```

### Swarm — No Native Gating
Swarm has no built-in capability gating. Any agent can transfer to any other agent reachable in the Python process. Scope enforcement must be implemented externally — e.g., by validating handoff targets before returning them from a function.

---

## Canonical Structure

```
[Agent A receives task requiring capability C]
  └─ Identifies candidate agent B with Caps(B) ∋ C
  └─ Gate Check:
      allowed = Caps(B) ∩ Scope(A)
      required = {C}
      if required ⊄ allowed:
        → FAIL with "Scope violation"
      else:
        → proceed with delegation/handoff
```

---

## Why Failing Loudly Matters

Silent forwarding to an out-of-scope agent produces:
*   **Privilege escalation:** Task gains capabilities it was not authorized for.
*   **Audit gap:** No record of the unauthorized route in the task history.
*   **Non-determinism:** The same task produces different outcomes depending on which agent is reachable, not what was authorized.

Explicit FAILED transitions keep every path in the delegation graph **statically analyzable** — a security property required for the trust model in [[community-protocol-trust-substrate]].

---

## Implementation Checklist
- [ ] Every agent declares its capability surface (ADK: tool list; A2A: AgentCard skills; Swarm: functions list).
- [ ] Every orchestrator declares a scope for each agent it coordinates (what capabilities it may delegate).
- [ ] Pre-delegation gate check: `required ⊆ Caps(B) ∩ Scope(A)`.
- [ ] Gate failure produces an explicit error state (FAILED / exception), not a silent route.
- [ ] Capability declarations are version-controlled alongside agent definitions.

---

## References
- [[capability-lattice-spec]] — formal lattice model
- [[a2a-capability-lattice]] — A2A-specific lattice treatment
- [[a2a-protocol]] — TRANSFERRED state enforcement
- [[community-protocol-trust-substrate]] — trust model requiring gating
- [[pattern-dynamic-delegation]] — gating applies before every delegation
- [[pattern-progressive-handoff]] — gating is mandatory before TRANSFERRED
- [[lit-rust-programming-language]] — Rust's type-system enforcement of visibility (structural analog)
