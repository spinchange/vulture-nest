use crate::capability::{Capability, CapabilitySet, UnauthorizedCaps};

pub fn gate_delegation(
    orchestrator_scope: &CapabilitySet,
    target_agent_caps: &CapabilitySet,
    required_for_task: &CapabilitySet,
) -> Result<CapabilitySet, UnauthorizedCaps> {
    let effective = orchestrator_scope.meet(target_agent_caps);
    effective.authorize(required_for_task)?;
    Ok(effective)
}

pub fn gate_handoff(
    orchestrator_scope: &CapabilitySet,
    target_agent_caps: &CapabilitySet,
    required_for_task: &CapabilitySet,
) -> Result<CapabilitySet, UnauthorizedCaps> {
    let handoff_required = CapabilitySet::new([Capability::HandoffToAgent]);
    orchestrator_scope.authorize(&handoff_required)?;
    gate_delegation(orchestrator_scope, target_agent_caps, required_for_task)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn delegation_cannot_escalate() {
        let orchestrator =
            CapabilitySet::new([Capability::ReadVaultMemory, Capability::DelegateReadOnly]);
        let target =
            CapabilitySet::new([Capability::ReadVaultMemory, Capability::WriteVaultMemory]);
        let required = CapabilitySet::new([Capability::WriteVaultMemory]);

        let result = gate_delegation(&orchestrator, &target, &required);
        assert!(result.is_err());
    }

    #[test]
    fn delegation_within_scope_succeeds() {
        let orchestrator = CapabilitySet::new([
            Capability::ReadVaultMemory,
            Capability::WriteVaultMemory,
            Capability::DelegateReadWrite,
        ]);
        let target =
            CapabilitySet::new([Capability::ReadVaultMemory, Capability::WriteVaultMemory]);
        let required = CapabilitySet::new([Capability::ReadVaultMemory]);

        let effective = gate_delegation(&orchestrator, &target, &required).unwrap();
        assert!(effective.contains(&Capability::ReadVaultMemory));
    }
}
