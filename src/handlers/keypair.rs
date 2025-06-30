use axum::{response::Json, http::StatusCode, extract::Json as JsonExtractor};
use solana_sdk::signer::{keypair::Keypair, Signer};
use crate::models::KeypairResponse;
use serde_json::Value;

pub async fn generate_keypair(
    // Accept optional JSON body for maximum compatibility
    _body: Option<JsonExtractor<Value>>
) -> Result<Json<KeypairResponse>, StatusCode> {
    // Generate keypair regardless of request body
    let keypair = Keypair::new();
    let pubkey = keypair.pubkey().to_string();

    // Extract only the secret key part (first 32 bytes) for Ed25519 signing
    let secret_bytes = &keypair.to_bytes()[..32];
    let secret = bs58::encode(secret_bytes).into_string();

    let response_data = KeypairResponse {
        pubkey,
        secret,
    };

    Ok(Json(response_data))
}
