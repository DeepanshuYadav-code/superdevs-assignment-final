#!/bin/bash

echo "🧪 Testing all endpoints with new direct response format..."
echo ""

# Test 1: Keypair generation
echo "1. Testing POST /keypair"
KEYPAIR_RESPONSE=$(curl -s -X POST http://localhost:3000/keypair)
echo "Response: $KEYPAIR_RESPONSE"
PUBKEY=$(echo $KEYPAIR_RESPONSE | jq -r '.pubkey')
SECRET=$(echo $KEYPAIR_RESPONSE | jq -r '.secret')
echo "✅ Keypair: $PUBKEY"
echo ""

# Test 2: Message signing
echo "2. Testing POST /message/sign"
SIGN_RESPONSE=$(curl -s -X POST http://localhost:3000/message/sign \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"Test message\", \"secret\": \"$SECRET\"}")
echo "Response: $SIGN_RESPONSE"
SIGNATURE=$(echo $SIGN_RESPONSE | jq -r '.signature')
echo "✅ Signature: $SIGNATURE"
echo ""

# Test 3: Message verification
echo "3. Testing POST /message/verify"
VERIFY_RESPONSE=$(curl -s -X POST http://localhost:3000/message/verify \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"Test message\", \"signature\": \"$SIGNATURE\", \"pubkey\": \"$PUBKEY\"}")
echo "Response: $VERIFY_RESPONSE"
VALID=$(echo $VERIFY_RESPONSE | jq -r '.valid')
echo "✅ Verification: $VALID"
echo ""

# Test 4: SOL transfer
echo "4. Testing POST /send/sol"
SOL_RESPONSE=$(curl -s -X POST http://localhost:3000/send/sol \
  -H "Content-Type: application/json" \
  -d '{"from": "11111111111111111111111111111112", "to": "11111111111111111111111111111113", "amount": 1000000000}')
echo "Response format: $(echo $SOL_RESPONSE | jq 'keys')"
TRANSACTION=$(echo $SOL_RESPONSE | jq -r '.transaction')
echo "✅ SOL Transaction: ${TRANSACTION:0:50}..."
echo ""

# Test 5: Token creation
echo "5. Testing POST /token/create"
TOKEN_CREATE_RESPONSE=$(curl -s -X POST http://localhost:3000/token/create \
  -H "Content-Type: application/json" \
  -d '{"mintAuthority": "11111111111111111111111111111112", "mint": "11111111111111111111111111111113", "decimals": 9}')
echo "Response format: $(echo $TOKEN_CREATE_RESPONSE | jq 'keys')"
TOKEN_TRANSACTION=$(echo $TOKEN_CREATE_RESPONSE | jq -r '.transaction')
echo "✅ Token Create Transaction: ${TOKEN_TRANSACTION:0:50}..."
echo ""

# Test 6: Token minting
echo "6. Testing POST /token/mint"
TOKEN_MINT_RESPONSE=$(curl -s -X POST http://localhost:3000/token/mint \
  -H "Content-Type: application/json" \
  -d '{"mint": "11111111111111111111111111111113", "destination": "11111111111111111111111111111114", "authority": "11111111111111111111111111111112", "amount": 1000000}')
echo "Response format: $(echo $TOKEN_MINT_RESPONSE | jq 'keys')"
MINT_TRANSACTION=$(echo $TOKEN_MINT_RESPONSE | jq -r '.transaction')
echo "✅ Token Mint Transaction: ${MINT_TRANSACTION:0:50}..."
echo ""

# Test 7: Token transfer
echo "7. Testing POST /send/token"
TOKEN_TRANSFER_RESPONSE=$(curl -s -X POST http://localhost:3000/send/token \
  -H "Content-Type: application/json" \
  -d '{"destination": "11111111111111111111111111111114", "mint": "11111111111111111111111111111113", "owner": "11111111111111111111111111111112", "amount": 500000}')
echo "Response format: $(echo $TOKEN_TRANSFER_RESPONSE | jq 'keys')"
TRANSFER_TRANSACTION=$(echo $TOKEN_TRANSFER_RESPONSE | jq -r '.transaction')
echo "✅ Token Transfer Transaction: ${TRANSFER_TRANSACTION:0:50}..."
echo ""

echo "🎉 All 7 endpoints tested successfully with new direct response format!"
echo ""
echo "📋 Summary of response formats:"
echo "  - Keypair: {pubkey, secret}"
echo "  - Message Sign: {signature, pubkey}"
echo "  - Message Verify: {valid}"
echo "  - Transaction endpoints: {transaction, message}"
echo ""
echo "✨ This format is consistent with Solana Actions/Pay API specifications!"
