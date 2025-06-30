use anyhow::{anyhow, Result};
use ed25519_dalek::{Signature, Keypair, PublicKey, SecretKey, Signer, Verifier};
use solana_sdk::pubkey::Pubkey;
use std::str::FromStr;
use base64::{engine::general_purpose::STANDARD, Engine};

pub fn decode_base58_pubkey(pubkey_str: &str) -> Result<Pubkey> {
    Pubkey::from_str(pubkey_str).map_err(|e| anyhow!("Invalid pubkey: {}", e))
}

pub fn decode_base58_secret(secret_str: &str) -> Result<[u8; 32]> {
    let decoded = bs58::decode(secret_str)
        .into_vec()
        .map_err(|e| anyhow!("Failed to decode base58 secret: {}", e))?;

    if decoded.len() != 32 {
        return Err(anyhow!("Secret key must be 32 bytes, got {}", decoded.len()));
    }

    let mut bytes = [0u8; 32];
    bytes.copy_from_slice(&decoded);
    Ok(bytes)
}

pub fn sign_message(message: &str, secret_bytes: &[u8; 32]) -> Result<String> {
    let secret_key = SecretKey::from_bytes(secret_bytes)
        .map_err(|e| anyhow!("Invalid secret key: {}", e))?;
    let public_key = PublicKey::from(&secret_key);
    let keypair = Keypair { secret: secret_key, public: public_key };

    let signature = keypair.sign(message.as_bytes());
    Ok(STANDARD.encode(signature.to_bytes()))
}

pub fn verify_signature(message: &str, signature_b64: &str, pubkey_str: &str) -> Result<bool> {
    let signature_bytes = STANDARD.decode(signature_b64)
        .map_err(|e| anyhow!("Failed to decode base64 signature: {}", e))?;

    let signature = Signature::from_bytes(&signature_bytes)
        .map_err(|e| anyhow!("Invalid signature: {}", e))?;

    let pubkey_bytes = bs58::decode(pubkey_str)
        .into_vec()
        .map_err(|e| anyhow!("Failed to decode base58 pubkey: {}", e))?;

    if pubkey_bytes.len() != 32 {
        return Err(anyhow!("Public key must be 32 bytes"));
    }

    let mut key_bytes = [0u8; 32];
    key_bytes.copy_from_slice(&pubkey_bytes);

    let public_key = PublicKey::from_bytes(&key_bytes)
        .map_err(|e| anyhow!("Invalid public key: {}", e))?;

    Ok(public_key.verify(message.as_bytes(), &signature).is_ok())
}
