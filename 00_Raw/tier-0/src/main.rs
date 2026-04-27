mod capability;
mod error;
mod gate;
mod proof;
mod state;

use crate::capability::CapabilitySet;
use crate::error::GateError;
use crate::gate::gate_delegation;
use crate::proof::{GuardrailProof, ValidatedEnvelope};
use crate::state::{StateTransfer, ValidationError};
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};

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

pub async fn send_state(
    writer: &mut tokio::io::Stdout,
    transfer: &StateTransfer,
) -> Result<(), GateError> {
    let json = serde_json::to_string(transfer)
        .map_err(|e| GateError::Validation(ValidationError::Serde(e)))?;
    writer.write_all(json.as_bytes()).await.map_err(GateError::Io)?;
    writer.write_all(b"\n").await.map_err(GateError::Io)?;
    writer.flush().await.map_err(GateError::Io)?;
    Ok(())
}

fn load_scope_from_config() -> Result<CapabilitySet, Box<dyn std::error::Error>> {
    panic!("not implemented")
}

fn load_target_caps(_originating_agent: &Option<String>) -> Result<CapabilitySet, Box<dyn std::error::Error>> {
    Ok(CapabilitySet::default())
}

fn infer_required_caps(_transfer: &StateTransfer) -> Result<CapabilitySet, Box<dyn std::error::Error>> {
    panic!("not implemented")
}

async fn send_error(
    writer: &mut tokio::io::Stdout,
    code: &str,
    message: &str,
) -> Result<(), GateError> {
    let payload = serde_json::json!({ "error": code, "message": message });
    writer
        .write_all(payload.to_string().as_bytes())
        .await
        .map_err(GateError::Io)?;
    writer.write_all(b"\n").await.map_err(GateError::Io)?;
    writer.flush().await.map_err(GateError::Io)?;
    Ok(())
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let my_scope: CapabilitySet = load_scope_from_config()?;
    let secret = std::env::var("TIER0_SECRET")
        .expect("TIER0_SECRET must be set")
        .into_bytes();

    let stdin = tokio::io::stdin();
    let stdout = tokio::io::stdout();
    let mut reader = BufReader::new(stdin);
    let mut writer = stdout;

    loop {
        let transfer = match receive_state(&mut reader).await {
            Ok(t) => t,
            Err(e) => {
                eprintln!("Gate error: {e}");
                continue;
            }
        };

        let target_caps: CapabilitySet = load_target_caps(&transfer.originating_agent)?;
        let required: CapabilitySet = infer_required_caps(&transfer)?;

        let effective = match gate_delegation(&my_scope, &target_caps, &required) {
            Ok(eff) => eff,
            Err(e) => {
                eprintln!("Capability violation: {e}");
                send_error(&mut writer, "CAPABILITY_DENIED", &e.to_string()).await?;
                continue;
            }
        };

        let proof = GuardrailProof::sign(&transfer, effective.clone(), &secret);
        let envelope = ValidatedEnvelope { state: transfer, proof };
        let env_json = serde_json::to_string(&envelope)?;
        writer.write_all(env_json.as_bytes()).await?;
        writer.write_all(b"\n").await?;
        writer.flush().await?;
    }
}
