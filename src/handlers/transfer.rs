use axum::{extract::Json as ExtractJson, response::Json, http::StatusCode};
use solana_program::system_instruction;
use spl_token::instruction;
use crate::models::{TransactionResponse, SendSolRequest, SendTokenRequest};
use crate::utils::{validate_pubkey, instruction_to_transaction};

pub async fn send_sol(
    ExtractJson(payload): ExtractJson<SendSolRequest>,
) -> Result<Json<TransactionResponse>, StatusCode> {
    let from = match validate_pubkey(&payload.from) {
        Ok(pubkey) => pubkey,
        Err(e) => {
            eprintln!("Invalid from pubkey: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let to = match validate_pubkey(&payload.to) {
        Ok(pubkey) => pubkey,
        Err(e) => {
            eprintln!("Invalid to pubkey: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let instruction = system_instruction::transfer(&from, &to, payload.amount);
    let response_data = match instruction_to_transaction(instruction, Some(from)) {
        Ok(transaction) => transaction,
        Err(e) => {
            eprintln!("Failed to create transaction: {}", e);
            return Err(StatusCode::INTERNAL_SERVER_ERROR);
        }
    };

    Ok(Json(response_data))
}

pub async fn send_token(
    ExtractJson(payload): ExtractJson<SendTokenRequest>,
) -> Result<Json<TransactionResponse>, StatusCode> {
    let destination = match validate_pubkey(&payload.destination) {
        Ok(pubkey) => pubkey,
        Err(e) => {
            eprintln!("Invalid destination pubkey: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let _mint = match validate_pubkey(&payload.mint) {
        Ok(pubkey) => pubkey,
        Err(e) => {
            eprintln!("Invalid mint pubkey: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let owner = match validate_pubkey(&payload.owner) {
        Ok(pubkey) => pubkey,
        Err(e) => {
            eprintln!("Invalid owner pubkey: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    // For SPL token transfers, we need to derive the source token account
    // In a real scenario, you'd need to get the actual source account
    // For this example, we'll assume the owner is the source account
    let instruction = instruction::transfer(
        &spl_token::id(),
        &owner,
        &destination,
        &owner,
        &[],
        payload.amount,
    ).map_err(|e| {
        eprintln!("Failed to create token transfer instruction: {}", e);
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    let response_data = match instruction_to_transaction(instruction, Some(owner)) {
        Ok(transaction) => transaction,
        Err(e) => {
            eprintln!("Failed to create transaction: {}", e);
            return Err(StatusCode::INTERNAL_SERVER_ERROR);
        }
    };

    Ok(Json(response_data))
}
