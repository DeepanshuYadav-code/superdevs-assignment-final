# Solana HTTP Server

A production-ready Rust-based HTTP server using Axum that exposes REST API endpoints for interacting with Solana blockchain operations.

## 🚀 Features

- **7 REST API endpoints** for Solana operations
- **Ed25519 signature support** with base64 output
- **Base58 encoding** for keys and addresses
- **Modular architecture** with clean separation of concerns
- **Direct response format** compatible with automated testing systems
- **CORS support** for web applications
- **HTTP status code error handling**

## 📦 Dependencies

- `axum` - Modern web framework
- `tokio` - Async runtime
- `serde` - JSON serialization
- `solana-sdk` - Solana blockchain SDK
- `spl-token` - SPL Token program
- `ed25519-dalek` - Ed25519 signatures
- `base64` & `bs58` - Encoding utilities

## 🔧 Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd solana-http-server
   ```

2. **Build the project:**
   ```bash
   cargo build --release
   ```

3. **Run the server:**
   ```bash
   cargo run
   ```

The server will start on `http://127.0.0.1:3000`

## 🌐 API Endpoints

⚠️ **IMPORTANT**: The API now returns direct responses (not wrapped in `success/data/error`) to ensure compatibility with automated testing systems and Solana Actions/Pay API standards.

### 1. **POST /keypair** - Generate New Keypair

Generates a new Solana keypair.

**Request:**
```bash
curl -X POST http://127.0.0.1:3000/keypair \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "pubkey": "11111111111111111111111111111111",
  "secret": "base58_encoded_secret_key"
}
```

### 2. **POST /token/create** - Create SPL Token

Creates an InitializeMint instruction for SPL Token and returns a serialized transaction.

**Request:**
```bash
curl -X POST http://127.0.0.1:3000/token/create \
  -H "Content-Type: application/json" \
  -d '{
    "mintAuthority": "11111111111111111111111111111111",
    "mint": "22222222222222222222222222222222",
    "decimals": 6
  }'
```

**Response:**
```json
{
  "transaction": "base64_encoded_serialized_transaction",
  "message": "Token creation transaction created successfully"
}
```

### 3. **POST /token/mint** - Mint SPL Tokens

Creates a MintTo instruction for SPL Token and returns a serialized transaction.

**Request:**
```bash
curl -X POST http://127.0.0.1:3000/token/mint \
  -H "Content-Type: application/json" \
  -d '{
    "mint": "22222222222222222222222222222222",
    "destination": "33333333333333333333333333333333",
    "authority": "11111111111111111111111111111111",
    "amount": 1000000
  }'
```

**Response:**
```json
{
  "transaction": "base64_encoded_serialized_transaction",
  "message": "Token mint transaction created successfully"
}
```

### 4. **POST /message/sign** - Sign Message

Signs a message using Ed25519.

**Request:**
```bash
curl -X POST http://127.0.0.1:3000/message/sign \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello Solana!",
    "secret": "base58_encoded_secret_key"
  }'
```

**Response:**
```json
{
  "signature": "base64_encoded_signature",
  "pubkey": "11111111111111111111111111111111"
}
```

### 5. **POST /message/verify** - Verify Signature

Verifies an Ed25519 signature.

**Request:**
```bash
curl -X POST http://127.0.0.1:3000/message/verify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello Solana!",
    "signature": "base64_encoded_signature",
    "pubkey": "11111111111111111111111111111111"
  }'
```

**Response:**
```json
{
  "valid": true
}
```

### 6. **POST /send/sol** - Create SOL Transfer

Creates a SOL transfer instruction and returns a serialized transaction.

**Request:**
```bash
curl -X POST http://127.0.0.1:3000/send/sol \
  -H "Content-Type: application/json" \
  -d '{
    "from": "11111111111111111111111111111111",
    "to": "22222222222222222222222222222222",
    "amount": 1000000000
  }'
```

**Response:**
```json
{
  "transaction": "base64_encoded_serialized_transaction",
  "message": "SOL transfer transaction created successfully"
}
```

### 7. **POST /send/token** - Create Token Transfer

Creates an SPL token transfer instruction and returns a serialized transaction.

**Request:**
```bash
curl -X POST http://127.0.0.1:3000/send/token \
  -H "Content-Type: application/json" \
  -d '{
    "destination": "33333333333333333333333333333333",
    "mint": "22222222222222222222222222222222",
    "owner": "11111111111111111111111111111111",
    "amount": 1000000
  }'
```

**Response:**
```json
{
  "transaction": "base64_encoded_serialized_transaction",
  "message": "Token transfer transaction created successfully"
}
```

## 🌐 Public Deployment

**🎉 The server is now publicly accessible via ngrok!**

### **Public URL:**
```
https://c94c-2409-40c0-c-6f06-449f-1501-a146-ecbb.ngrok-free.app
```

**Note:** This URL has been updated with the new direct response format for automated testing compatibility.

### **Public Endpoints:**
All endpoints are available with the public URL prefix:
- `https://[ngrok-url]/keypair`
- `https://[ngrok-url]/token/create`
- `https://[ngrok-url]/token/mint`
- `https://[ngrok-url]/message/sign`
- `https://[ngrok-url]/message/verify`
- `https://[ngrok-url]/send/sol`
- `https://[ngrok-url]/send/token`

### **Testing Public Deployment:**
```bash
# Test the new format with all endpoints
./test-new-format.sh

# Or test individual endpoints
curl -X POST https://[ngrok-url]/keypair \
  -H "Content-Type: application/json"
```

### **Monitoring:**
- **ngrok Dashboard:** http://127.0.0.1:4040
- **Request Logs:** Visible in ngrok dashboard
- **Server Logs:** Check the local terminal

## 🏗️ Project Structure

```
src/
├── main.rs              # Main application entry point
├── handlers/            # HTTP request handlers
│   ├── mod.rs
│   ├── keypair.rs       # Keypair generation
│   ├── token.rs         # SPL Token operations
│   ├── message.rs       # Message signing/verification
│   └── transfer.rs      # SOL and token transfers
├── models/              # Request/Response models
│   ├── mod.rs
│   ├── request.rs       # Request structures
│   └── response.rs      # Response structures
└── utils/               # Utility functions
    ├── mod.rs
    ├── crypto.rs        # Cryptographic operations
    └── solana.rs        # Solana-specific utilities
```

## 🔐 Security Notes

- Secret keys are handled only in memory
- All cryptographic operations use industry-standard libraries
- Input validation is performed on all endpoints
- No private keys are persisted to disk

## 🧪 Testing

Test scripts are available for comprehensive endpoint validation:

1. **Test New Format (Current):**
   ```bash
   ./test-new-format.sh
   ```

2. **Test Public Deployment:**
   ```bash
   ./test-public-endpoints.sh
   ```

3. **Manual Testing with curl:**
   Use the provided curl commands in the endpoint documentation above.

## 📚 Error Handling

⚠️ **Updated Error Format**: The API now uses HTTP status codes for errors instead of wrapping errors in JSON.

- **400 Bad Request** - Invalid input data
- **422 Unprocessable Entity** - Valid JSON but invalid Solana data
- **500 Internal Server Error** - Server errors

Error responses return plain JSON with error details:
```json
{
  "error": "Descriptive error message"
}
```

## 🔄 Response Format Changes

### **CRITICAL UPDATE**: New Direct Response Format

The API has been updated to return **direct responses** (not wrapped in `success/data/error`) to ensure compatibility with:
- Automated testing systems
- Solana Actions/Pay API standards
- Industry-standard REST API practices

**Before (Old Format):**
```json
{
  "success": true,
  "data": { "pubkey": "...", "secret": "..." }
}
```

**After (New Format):**
```json
{
  "pubkey": "...",
  "secret": "..."
}
```

For detailed information about this change, see `API_FORMAT_UPDATE.md`.

## 🛠️ Development

1. **Format code:**
   ```bash
   cargo fmt
   ```

2. **Run tests:**
   ```bash
   cargo test
   ```

3. **Check for issues:**
   ```bash
   cargo clippy
   ```

4. **Build for production:**
   ```bash
   cargo build --release
   ```

## 📋 Assignment Status

- ✅ **7 POST endpoints implemented** with correct functionality
- ✅ **Direct response format** for automated testing compatibility
- ✅ **Base58/Base64 encoding** as specified
- ✅ **Serialized transactions** for blockchain operations
- ✅ **CORS and error handling** implemented
- ✅ **GET endpoints** for browser/health check compatibility
- ✅ **Public deployment** ready via ngrok
- 🔄 **Re-testing** with automated systems pending

## 📄 License

This project is part of a Solana Fellowship assignment.
