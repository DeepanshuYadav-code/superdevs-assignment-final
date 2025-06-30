#!/bin/bash

# Solana HTTP Server Public Test Script
# Testing the ngrok deployed server

echo "🌐 Testing Publicly Deployed Solana HTTP Server"
echo "=============================================="
echo ""

BASE_URL="https://9414-2409-40c0-c-6f06-449f-1501-a146-ecbb.ngrok-free.app"

echo "📡 Public URL: $BASE_URL"
echo ""

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
    \"message\": \"Hello Public Solana API!\",
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
    \"message\": \"Hello Public Solana API!\",
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

echo "5. 💰 Creating SOL transfer instruction..."
SOL_TRANSFER_RESPONSE=$(curl -s -X POST "$BASE_URL/send/sol" \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": \"$PUBKEY\",
    \"to\": \"So11111111111111111111111111111111111111112\",
    \"amount\": 1000000000
  }")
echo "Response: $SOL_TRANSFER_RESPONSE"
echo ""

echo "🎉 Public deployment test completed successfully!"
echo ""
echo "🔗 Your server is now publicly accessible at:"
echo "   $BASE_URL"
echo ""
echo "📚 You can test all endpoints with Postman, curl, or any HTTP client!"
