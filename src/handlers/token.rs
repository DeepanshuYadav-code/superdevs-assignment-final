use axum::{extract::Json as ExtractJson, response::Json, http::StatusCode};
use spl_token::instruction;
use crate::models::{TransactionResponse, CreateTokenRequest, MintTokenRequest};
use crate::utils::{validate_pubkey, instruction_to_transaction};

pub async fn create_token(
    ExtractJson(payload): ExtractJson<CreateTokenRequest>,
) -> Result<Json<TransactionResponse>, StatusCode> {
    let mint_authority = match validate_pubkey(&payload.mint_authority) {
        Ok(pubkey) => pubkey,
        Err(e) => {
            eprintln!("Invalid mint authority pubkey: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let mint = match validate_pubkey(&payload.mint) {
        Ok(pubkey) => pubkey,
        Err(e) => {
            eprintln!("Invalid mint pubkey: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let instruction = instruction::initialize_mint(
        &spl_token::id(),
        &mint,
        &mint_authority,
        None,
        payload.decimals,
    ).map_err(|e| {
        eprintln!("Failed to create initialize mint instruction: {}", e);
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    let response_data = match instruction_to_transaction(instruction, Some(mint_authority)) {
        Ok(transaction) => transaction,
        Err(e) => {
            eprintln!("Failed to create transaction: {}", e);
            return Err(StatusCode::INTERNAL_SERVER_ERROR);
        }
    };

    Ok(Json(response_data))
}

pub async fn mint_token(
    ExtractJson(payload): ExtractJson<MintTokenRequest>,
) -> Result<Json<TransactionResponse>, StatusCode> {
    let mint = match validate_pubkey(&payload.mint) {
        Ok(pubkey) => pubkey,
        Err(e) => {
            eprintln!("Invalid mint pubkey: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let destination = match validate_pubkey(&payload.destination) {
        Ok(pubkey) => pubkey,
        Err(e) => {
            eprintln!("Invalid destination pubkey: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let authority = match validate_pubkey(&payload.authority) {
        Ok(pubkey) => pubkey,
        Err(e) => {
            eprintln!("Invalid authority pubkey: {}", e);
            return Err(StatusCode::BAD_REQUEST);
        }
    };

    let instruction = instruction::mint_to(
        &spl_token::id(),
        &mint,
        &destination,
        &authority,
        &[],
        payload.amount,
    ).map_err(|e| {
        eprintln!("Failed to create mint to instruction: {}", e);
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    let response_data = match instruction_to_transaction(instruction, Some(authority)) {
        Ok(transaction) => transaction,
        Err(e) => {
            eprintln!("Failed to create transaction: {}", e);
            return Err(StatusCode::INTERNAL_SERVER_ERROR);
        }
    };

    Ok(Json(response_data))
}
