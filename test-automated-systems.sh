#!/bin/bash

# Comprehensive Solana HTTP Server Test for Automated Systems
# This script tests all endpoints and validates responses

echo "🧪 COMPREHENSIVE API TEST FOR AUTOMATED SYSTEMS"
echo "==============================================="
echo ""

BASE_URL="https://9414-2409-40c0-c-6f06-449f-1501-a146-ecbb.ngrok-free.app"
PASSED=0
FAILED=0

# Function to test an endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local expected_status=$3
    local data=$4
    local description=$5
    local expect_success=${6:-true}  # Default to expecting success:true

    echo "Testing: $description"
    echo "Endpoint: $method $endpoint"

    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "%{http_code}" -o response.tmp "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "%{http_code}" -o response.tmp -X "$method" -H "Content-Type: application/json" -d "$data" "$BASE_URL$endpoint")
    fi

    status_code="${response: -3}"
    response_body=$(cat response.tmp)

    if [ "$status_code" -eq "$expected_status" ]; then
        echo "✅ PASS - Status: $status_code"
        if [ "$expect_success" = "true" ]; then
            if echo "$response_body" | grep -q '"success":true'; then
                echo "✅ PASS - Response contains success:true"
                ((PASSED++))
            else
                echo "❌ FAIL - Response missing success:true"
                ((FAILED++))
            fi
        else
            if echo "$response_body" | grep -q '"success":false'; then
                echo "✅ PASS - Response correctly contains success:false"
                ((PASSED++))
            else
                echo "❌ FAIL - Response missing success:false"
                ((FAILED++))
            fi
        fi
    else
        echo "❌ FAIL - Expected: $expected_status, Got: $status_code"
        ((FAILED++))
    fi

    echo "Response: $(echo "$response_body" | head -c 100)..."
    echo ""
}

# Test GET endpoints
test_endpoint "GET" "/" 200 "" "Root endpoint - API information"
test_endpoint "GET" "/health" 200 "" "Health check endpoint"
test_endpoint "GET" "/docs" 200 "" "API documentation endpoint"

# Test POST endpoints
test_endpoint "POST" "/keypair" 200 '{}' "Generate keypair"

test_endpoint "POST" "/token/create" 200 '{
    "mintAuthority": "So11111111111111111111111111111111111111112",
    "mint": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
    "decimals": 6
}' "Create SPL token"

test_endpoint "POST" "/token/mint" 200 '{
    "mint": "So11111111111111111111111111111111111111112",
    "destination": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
    "authority": "So11111111111111111111111111111111111111112",
    "amount": 1000000
}' "Mint SPL tokens"

test_endpoint "POST" "/message/sign" 200 '{
    "message": "Test message for automated testing",
    "secret": "2h3Lxv8r9w6N4k7pQm5yX8fE3tUiOp1aS6dF9gH2jK4lM"
}' "Sign message" false

test_endpoint "POST" "/message/verify" 200 '{
    "message": "Test message",
    "signature": "dGVzdF9zaWduYXR1cmVfZGF0YQ==",
    "pubkey": "So11111111111111111111111111111111111111112"
}' "Verify message (may fail with invalid data, but should return 200)" false

test_endpoint "POST" "/send/sol" 200 '{
    "from": "So11111111111111111111111111111111111111112",
    "to": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
    "amount": 1000000000
}' "Create SOL transfer"

test_endpoint "POST" "/send/token" 200 '{
    "destination": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
    "mint": "So11111111111111111111111111111111111111112",
    "owner": "So11111111111111111111111111111111111111112",
    "amount": 1000000
}' "Create token transfer"

# Test error handling
test_endpoint "POST" "/send/sol" 200 '{
    "from": "invalid_pubkey",
    "to": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
    "amount": 1000000000
}' "Error handling test (should return success:false)" false

# Cleanup
rm -f response.tmp

echo "🎯 TEST SUMMARY"
echo "==============="
echo "✅ Passed: $PASSED"
echo "❌ Failed: $FAILED"
echo "📊 Total: $((PASSED + FAILED))"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "🎉 ALL TESTS PASSED! Server is ready for automated testing."
    echo "🔗 Submit this URL: $BASE_URL"
    echo ""
    echo "📋 Available endpoints for automated testing:"
    echo "   GET  $BASE_URL/"
    echo "   GET  $BASE_URL/health"
    echo "   GET  $BASE_URL/docs"
    echo "   POST $BASE_URL/keypair"
    echo "   POST $BASE_URL/token/create"
    echo "   POST $BASE_URL/token/mint"
    echo "   POST $BASE_URL/message/sign"
    echo "   POST $BASE_URL/message/verify"
    echo "   POST $BASE_URL/send/sol"
    echo "   POST $BASE_URL/send/token"
    exit 0
else
    echo ""
    echo "⚠️  Some tests failed. Please check the server."
    exit 1
fi
