use axum::{extract::Json as ExtractJson, response::Json, http::StatusCode};
use ed25519_dalek::{SecretKey, PublicKey};
use crate::models::{
    SignatureResponse, VerificationResponse,
    SignMessageRequest, VerifyMessageRequest
};
use crate::utils::{decode_base58_secret, sign_message as crypto_sign_message, verify_signature};

pub async fn sign_message(
    ExtractJson(payload): ExtractJson<SignMessageRequest>,
) -> Result<Json<SignatureResponse>, StatusCode> {
    let secret_bytes = match decode_base58_secret(&payload.secret) {
        Ok(bytes) => bytes,
        Err(e) => {
            eprintln!("Invalid secret key: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let signature = match crypto_sign_message(&payload.message, &secret_bytes) {
        Ok(sig) => sig,
        Err(e) => {
            eprintln!("Failed to sign message: {}", e);
            return Err(StatusCode::INTERNAL_SERVER_ERROR);
        }
    };

    // Get the public key from the secret key
    let secret_key = match SecretKey::from_bytes(&secret_bytes) {
        Ok(sk) => sk,
        Err(e) => {
            eprintln!("Invalid secret key: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };
    let public_key = PublicKey::from(&secret_key);
    let pubkey = bs58::encode(public_key.to_bytes()).into_string();

    let response_data = SignatureResponse {
        signature,
        pubkey,
    };

    Ok(Json(response_data))
}

pub async fn verify_message(
    ExtractJson(payload): ExtractJson<VerifyMessageRequest>,
) -> Result<Json<VerificationResponse>, StatusCode> {
    let valid = match verify_signature(&payload.message, &payload.signature, &payload.pubkey) {
        Ok(is_valid) => is_valid,
        Err(e) => {
            eprintln!("Failed to verify signature: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let response_data = VerificationResponse { valid };
    Ok(Json(response_data))
}
