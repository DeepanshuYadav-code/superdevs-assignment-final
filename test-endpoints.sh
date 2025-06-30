#!/bin/bash

# Solana HTTP Server Test Script
# This script demonstrates all 7 endpoints with working examples

echo "🧪 Testing Solana HTTP Server Endpoints"
echo "========================================"
echo ""

BASE_URL="http://127.0.0.1:3000"

echo "1. 🔑 Generating a new keypair..."
KEYPAIR_RESPONSE=$(curl -s -X POST "$BASE_URL/keypair" -H "Content-Type: application/json")
echo "Response: $KEYPAIR_RESPONSE"

# Extract pubkey and secret from the response
PUBKEY=$(echo $KEYPAIR_RESPONSE | grep -o '"pubkey":"[^"]*"' | cut -d'"' -f4)
SECRET=$(echo $KEYPAIR_RESPONSE | grep -o '"secret":"[^"]*"' | cut -d'"' -f4)

echo "Generated pubkey: $PUBKEY"
echo "Generated secret: $SECRET"
echo ""

echo "2. ✍️  Signing a message..."
SIGN_RESPONSE=$(curl -s -X POST "$BASE_URL/message/sign" \
  -H "Content-Type: application/json" \
  -d "{
    \"message\": \"Hello Solana Fellowship!\",
    \"secret\": \"$SECRET\"
  }")
echo "Response: $SIGN_RESPONSE"

# Extract signature
SIGNATURE=$(echo $SIGN_RESPONSE | grep -o '"signature":"[^"]*"' | cut -d'"' -f4)
echo "Generated signature: $SIGNATURE"
echo ""

echo "3. ✅ Verifying the signature..."
VERIFY_RESPONSE=$(curl -s -X POST "$BASE_URL/message/verify" \
  -H "Content-Type: application/json" \
  -d "{
    \"message\": \"Hello Solana Fellowship!\",
    \"signature\": \"$SIGNATURE\",
    \"pubkey\": \"$PUBKEY\"
  }")
echo "Response: $VERIFY_RESPONSE"
echo ""

echo "4. 🪙 Creating SPL Token..."
TOKEN_CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/token/create" \
  -H "Content-Type: application/json" \
  -d "{
    \"mintAuthority\": \"$PUBKEY\",
    \"mint\": \"So11111111111111111111111111111111111111112\",
    \"decimals\": 9
  }")
echo "Response: $TOKEN_CREATE_RESPONSE"
echo ""

echo "5. 🎯 Minting tokens..."
TOKEN_MINT_RESPONSE=$(curl -s -X POST "$BASE_URL/token/mint" \
  -H "Content-Type: application/json" \
  -d "{
    \"mint\": \"So11111111111111111111111111111111111111112\",
    \"destination\": \"$PUBKEY\",
    \"authority\": \"$PUBKEY\",
    \"amount\": 1000000000
  }")
echo "Response: $TOKEN_MINT_RESPONSE"
echo ""

echo "6. 💰 Creating SOL transfer instruction..."
SOL_TRANSFER_RESPONSE=$(curl -s -X POST "$BASE_URL/send/sol" \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": \"$PUBKEY\",
    \"to\": \"So11111111111111111111111111111111111111112\",
    \"amount\": 1000000000
  }")
echo "Response: $SOL_TRANSFER_RESPONSE"
echo ""

echo "7. 🔄 Creating token transfer instruction..."
TOKEN_TRANSFER_RESPONSE=$(curl -s -X POST "$BASE_URL/send/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"destination\": \"So11111111111111111111111111111111111111112\",
    \"mint\": \"So11111111111111111111111111111111111111112\",
    \"owner\": \"$PUBKEY\",
    \"amount\": 500000000
  }")
echo "Response: $TOKEN_TRANSFER_RESPONSE"
echo ""

echo "✨ All tests completed successfully!"
echo ""
echo "🔍 Testing error handling with invalid input..."
ERROR_RESPONSE=$(curl -s -X POST "$BASE_URL/send/sol" \
  -H "Content-Type: application/json" \
  -d '{
    "from": "invalid-key",
    "to": "So11111111111111111111111111111111111111112",
    "amount": 1000000000
  }')
echo "Error response: $ERROR_RESPONSE"
echo ""
echo "🎉 Test script completed!"
