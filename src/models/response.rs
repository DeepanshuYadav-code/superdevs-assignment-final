use serde::Serialize;

#[derive(Serialize)]
pub struct ApiResponse<T> {
    pub success: bool,
    pub data: Option<T>,
    pub error: Option<String>,
}

impl<T> ApiResponse<T> {
    pub fn success(data: T) -> Self {
        Self {
            success: true,
            data: Some(data),
            error: None,
        }
    }

    pub fn error(message: String) -> Self {
        Self {
            success: false,
            data: None,
            error: Some(message),
        }
    }
}

#[derive(Serialize)]
pub struct KeypairResponse {
    pub pubkey: String,
    pub secret: String,
}

#[derive(Serialize)]
pub struct InstructionResponse {
    pub program_id: String,
    pub accounts: Vec<AccountMeta>,
    pub instruction_data: String,
}

#[derive(Serialize)]
pub struct TransactionResponse {
    pub transaction: String, // base64-encoded serialized transaction
    pub message: Option<String>,
}

// Alternative direct response formats for automated testing compatibility
#[derive(Serialize)]
pub struct DirectTransactionResponse {
    pub transaction: String,
}

#[derive(Serialize)]
pub struct DirectKeypairResponse {
    pub pubkey: String,
    pub secret: String,
}

#[derive(Serialize)]
pub struct AccountMeta {
    pub pubkey: String,
    pub is_signer: bool,
    pub is_writable: bool,
}

#[derive(Serialize)]
pub struct SignatureResponse {
    pub signature: String,
    pub pubkey: String,
}

#[derive(Serialize)]
pub struct VerificationResponse {
    pub valid: bool,
}
