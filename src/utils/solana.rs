use crate::models::{AccountMeta, InstructionResponse, TransactionResponse};
use anyhow::{anyhow, Result};
use solana_program::instruction::Instruction;
use solana_sdk::{
    pubkey::Pubkey,
    transaction::Transaction,
};
use std::str::FromStr;
use base64::{engine::general_purpose::STANDARD, Engine};

pub fn validate_pubkey(pubkey_str: &str) -> Result<Pubkey> {
    Pubkey::from_str(pubkey_str).map_err(|e| anyhow!("Invalid pubkey '{}': {}", pubkey_str, e))
}

pub fn instruction_to_response(instruction: Instruction) -> InstructionResponse {
    let accounts = instruction
        .accounts
        .iter()
        .map(|account| AccountMeta {
            pubkey: account.pubkey.to_string(),
            is_signer: account.is_signer,
            is_writable: account.is_writable,
        })
        .collect();

    InstructionResponse {
        program_id: instruction.program_id.to_string(),
        accounts,
        instruction_data: STANDARD.encode(&instruction.data),
    }
}

pub fn instruction_to_transaction(instruction: Instruction, fee_payer: Option<Pubkey>) -> Result<TransactionResponse> {
    // Create a transaction with a default blockhash and fee payer
    // The client should replace these with actual values before signing
    let default_fee_payer = fee_payer.unwrap_or_else(|| Pubkey::default());

    let transaction = Transaction::new_with_payer(&[instruction], Some(&default_fee_payer));

    // Serialize the transaction using bincode, which is what Solana uses internally
    let serialized = bincode::serialize(&transaction).map_err(|e| {
        anyhow!("Failed to serialize transaction: {}", e)
    })?;

    let base64_transaction = STANDARD.encode(&serialized);

    Ok(TransactionResponse {
        transaction: base64_transaction,
        message: Some("Transaction created successfully".to_string()),
    })
}
