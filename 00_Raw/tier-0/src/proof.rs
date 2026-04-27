use crate::capability::CapabilitySet;
use crate::state::StateTransfer;
use hmac::{Hmac, Mac};
use serde::{Deserialize, Serialize};
use sha2::Sha256;

#[derive(Debug, Serialize, Deserialize)]
pub struct GuardrailProof {
    pub checked_caps: CapabilitySet,
    pub signature: String,
    pub checked_at: String,
}

impl GuardrailProof {
    pub fn sign(transfer: &StateTransfer, checked_caps: CapabilitySet, secret: &[u8]) -> Self {
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

#[derive(Debug, Serialize, Deserialize)]
pub struct ValidatedEnvelope {
    pub state: StateTransfer,
    pub proof: GuardrailProof,
}
