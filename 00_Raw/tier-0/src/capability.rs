use serde::{Deserialize, Serialize};
use std::collections::HashSet;

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Capability {
    ReadSessionMemory,
    WriteSessionMemory,
    ReadVaultMemory,
    WriteVaultMemory,
    PruneMemory,
    DelegateReadOnly,
    DelegateReadWrite,
    HandoffToAgent,
    ExecuteCode,
    ModifyVaultSchema,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct CapabilitySet(pub HashSet<Capability>);

impl CapabilitySet {
    pub fn new(caps: impl IntoIterator<Item = Capability>) -> Self {
        CapabilitySet(caps.into_iter().collect())
    }

    pub fn meet(&self, other: &CapabilitySet) -> CapabilitySet {
        CapabilitySet(self.0.intersection(&other.0).cloned().collect())
    }

    pub fn join(&self, other: &CapabilitySet) -> CapabilitySet {
        CapabilitySet(self.0.union(&other.0).cloned().collect())
    }

    pub fn contains(&self, cap: &Capability) -> bool {
        self.0.contains(cap)
    }

    pub fn is_subset_of(&self, other: &CapabilitySet) -> bool {
        self.0.is_subset(&other.0)
    }

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
