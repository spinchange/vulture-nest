use crate::capability::UnauthorizedCaps;
use crate::state::ValidationError;

#[derive(Debug, thiserror::Error)]
pub enum GateError {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Validation error: {0}")]
    Validation(#[from] ValidationError),
    #[error("Capability violation: {0}")]
    Unauthorized(#[from] UnauthorizedCaps),
}
