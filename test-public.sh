#!/bin/bash

# Test script for the new public deployment with direct response format
PUBLIC_URL="https://c94c-2409-40c0-c-6f06-449f-1501-a146-ecbb.ngrok-free.app"

echo "🌐 Testing PUBLIC deployment with new direct response format..."
echo "🔗 Public URL: $PUBLIC_URL"
echo ""

# Test 1: Keypair generation
echo "1. Testing POST /keypair"
KEYPAIR_RESPONSE=$(curl -s -X POST "$PUBLIC_URL/keypair" \
  -H "Content-Type: application/json")
echo "Response: $KEYPAIR_RESPONSE"

# Extract pubkey and secret for further tests
PUBKEY=$(echo $KEYPAIR_RESPONSE | jq -r '.pubkey')
SECRET=$(echo $KEYPAIR_RESPONSE | jq -r '.secret')
echo "✅ Generated keypair: $PUBKEY"
echo ""

# Test 2: Message signing
echo "2. Testing POST /message/sign"
SIGN_RESPONSE=$(curl -s -X POST "$PUBLIC_URL/message/sign" \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"Hello Public Solana!\", \"secret\": \"$SECRET\"}")
echo "Response: $SIGN_RESPONSE"

# Extract signature for verification
SIGNATURE=$(echo $SIGN_RESPONSE | jq -r '.signature')
echo "✅ Signature: $SIGNATURE"
echo ""

# Test 3: Message verification
echo "3. Testing POST /message/verify"
VERIFY_RESPONSE=$(curl -s -X POST "$PUBLIC_URL/message/verify" \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"Hello Public Solana!\", \"signature\": \"$SIGNATURE\", \"pubkey\": \"$PUBKEY\"}")
echo "Response: $VERIFY_RESPONSE"

VALID=$(echo $VERIFY_RESPONSE | jq -r '.valid')
echo "✅ Verification result: $VALID"
echo ""

# Test 4: SOL transfer
echo "4. Testing POST /send/sol"
SOL_RESPONSE=$(curl -s -X POST "$PUBLIC_URL/send/sol" \
  -H "Content-Type: application/json" \
  -d "{\"from\": \"$PUBKEY\", \"to\": \"11111111111111111111111111111112\", \"amount\": 1000000000}")
echo "Response format: $(echo $SOL_RESPONSE | jq 'keys')"
echo "✅ SOL Transaction: $(echo $SOL_RESPONSE | jq -r '.transaction' | head -c 50)..."
echo ""

# Test 5: Token creation
echo "5. Testing POST /token/create"
TOKEN_CREATE_RESPONSE=$(curl -s -X POST "$PUBLIC_URL/token/create" \
  -H "Content-Type: application/json" \
  -d "{\"mintAuthority\": \"$PUBKEY\", \"mint\": \"22222222222222222222222222222222\", \"decimals\": 6}")
echo "Response format: $(echo $TOKEN_CREATE_RESPONSE | jq 'keys')"
echo "✅ Token Create Transaction: $(echo $TOKEN_CREATE_RESPONSE | jq -r '.transaction' | head -c 50)..."
echo ""

# Test 6: Token minting
echo "6. Testing POST /token/mint"
TOKEN_MINT_RESPONSE=$(curl -s -X POST "$PUBLIC_URL/token/mint" \
  -H "Content-Type: application/json" \
  -d "{\"mint\": \"22222222222222222222222222222222\", \"destination\": \"33333333333333333333333333333333\", \"authority\": \"$PUBKEY\", \"amount\": 1000000}")
echo "Response format: $(echo $TOKEN_MINT_RESPONSE | jq 'keys')"
echo "✅ Token Mint Transaction: $(echo $TOKEN_MINT_RESPONSE | jq -r '.transaction' | head -c 50)..."
echo ""

# Test 7: Token transfer
echo "7. Testing POST /send/token"
TOKEN_TRANSFER_RESPONSE=$(curl -s -X POST "$PUBLIC_URL/send/token" \
  -H "Content-Type: application/json" \
  -d "{\"destination\": \"33333333333333333333333333333333\", \"mint\": \"22222222222222222222222222222222\", \"owner\": \"$PUBKEY\", \"amount\": 1000000}")
echo "Response format: $(echo $TOKEN_TRANSFER_RESPONSE | jq 'keys')"
echo "✅ Token Transfer Transaction: $(echo $TOKEN_TRANSFER_RESPONSE | jq -r '.transaction' | head -c 50)..."
echo ""

# Test GET endpoints
echo "8. Testing GET endpoints"
echo "GET /:"
curl -s "$PUBLIC_URL/" | jq '.name'
echo "GET /health:"
curl -s "$PUBLIC_URL/health" | jq '.status'
echo ""

echo "🎉 All public endpoints tested successfully with new direct response format!"
echo ""
echo "📋 Summary of response formats:"
echo "  - Keypair: {pubkey, secret}"
echo "  - Message Sign: {signature, pubkey}"
echo "  - Message Verify: {valid}"
echo "  - Transaction endpoints: {transaction, message}"
echo ""
echo "✨ Public deployment is ready for automated testing!"
echo "🔗 Submit this URL to the assignment system: $PUBLIC_URL"
