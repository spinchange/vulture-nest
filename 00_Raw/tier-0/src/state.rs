use crate::capability::CapabilitySet;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct StateTransfer {
    pub task_id: String,
    pub session_id: String,
    pub scope: CapabilitySet,
    pub context: HashMap<String, serde_json::Value>,
    pub output_keys: HashMap<String, serde_json::Value>,
    pub originating_agent: Option<String>,
    pub snapshot_at: String,
}

impl StateTransfer {
    pub fn validate(&self) -> Result<(), ValidationError> {
        if self.task_id.is_empty() {
            return Err(ValidationError::EmptyField("task_id"));
        }
        if self.session_id.is_empty() {
            return Err(ValidationError::EmptyField("session_id"));
        }
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
