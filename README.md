# Solana HTTP Server

This is a Rust HTTP server built with Axum that provides REST API endpoints for common Solana blockchain operations. I built this as part of a fellowship assignment, focusing on clean code and ease of use.

## 🚀 What it does

- **7 REST endpoints** covering the main Solana operations you'd need
- **Ed25519 digital signatures** with proper base64 encoding
- **Base58 encoding** for public keys and addresses (standard Solana format)
- **Clean, modular code** that's easy to understand and extend
- **Direct JSON responses** - no unnecessary wrapper objects
- **CORS enabled** so you can call it from web apps
- **Proper error handling** with meaningful HTTP status codes

## 📦 What's under the hood

I chose these dependencies for good reasons:

- `axum` - Modern, fast web framework that's actually enjoyable to use
- `tokio` - The async runtime that makes Rust web servers blazingly fast
- `serde` - JSON serialization that just works
- `solana-sdk` - Official Solana SDK for blockchain operations
- `spl-token` - SPL Token program for token operations
- `ed25519-dalek` - Solid cryptographic library for signatures
- `base64` & `bs58` - Encoding utilities for the different formats Solana uses

## 🔧 Getting it running

1. **Grab the code:**
   ```bash
   git clone https://github.com/DeepanshuYadav-code/superdevs-assignment-final.git
   cd superdevs-assignment-final
   ```

2. **Build it:**
   ```bash
   cargo build --release
   ```

3. **Start the server:**
   ```bash
   cargo run
   ```

The server will start on `http://127.0.0.1:3000` and you'll see a friendly message telling you it's ready.

## 🌐 API Endpoints

Just a heads up - the API returns direct JSON responses (no wrapped `success/data/error` objects). This keeps things simple and works better with automated testing tools.

### 1. **POST /keypair** - Generate a new keypair

Creates a fresh Solana keypair for you.

**How to use:**
```bash
curl -X POST http://127.0.0.1:3000/keypair
```

**What you get back:**
```json
{
  "pubkey": "7M8E8rsBEmgJa6Ak2Zk7uXpA3WkA8LUpeMajppGHmP9G",
  "secret": "2jPKK7WJJ4vCYCKjJbYGdH43UET3azCFA2e3ryq24Dok"
}
```

### 2. **POST /token/create** - Create a new SPL token

Sets up a new SPL token with the parameters you specify.

**How to use:**
```bash
curl -X POST http://127.0.0.1:3000/token/create \
  -H "Content-Type: application/json" \
  -d '{
    "mintAuthority": "11111111111111111111111111111112",
    "mint": "11111111111111111111111111111113",
    "decimals": 9
  }'
```

**What you get back:**
```json
{
  "transaction": "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA...",
  "message": "Token creation transaction created successfully"
}
```

### 3. **POST /token/mint** - Mint tokens

Mint tokens to a destination account.

**How to use:**
```bash
curl -X POST http://127.0.0.1:3000/token/mint \
  -H "Content-Type: application/json" \
  -d '{
    "mint": "11111111111111111111111111111113",
    "destination": "11111111111111111111111111111114",
    "authority": "11111111111111111111111111111112",
    "amount": 1000000
  }'
```

**What you get back:**
```json
{
  "transaction": "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA...",
  "message": "Token mint transaction created successfully"
}
```

### 4. **POST /message/sign** - Sign a message

Signs any message with Ed25519 using your private key.

**How to use:**
```bash
curl -X POST http://127.0.0.1:3000/message/sign \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello Solana!",
    "secret": "your_base58_private_key"
  }'
```

**What you get back:**
```json
{
  "signature": "JIkJ+ZHFEUUTBfgmacSCQmKiaRfwo9BLN9njsc62ex7K710YhpaJLViAXr7fNmdegyzISKpjsDWooWG5EX4fAA==",
  "pubkey": "7M8E8rsBEmgJa6Ak2Zk7uXpA3WkA8LUpeMajppGHmP9G"
}
```

### 5. **POST /message/verify** - Verify a signature

Checks if a signature is valid for a given message and public key.

**How to use:**
```bash
curl -X POST http://127.0.0.1:3000/message/verify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello Solana!",
    "signature": "JIkJ+ZHFEUUTBfgmacSCQmKiaRfwo9BLN9njsc62ex7K710YhpaJLViAXr7fNmdegyzISKpjsDWooWG5EX4fAA==",
    "pubkey": "7M8E8rsBEmgJa6Ak2Zk7uXpA3WkA8LUpeMajppGHmP9G"
  }'
```

**What you get back:**
```json
{
  "valid": true
}
```

### 6. **POST /send/sol** - Create a SOL transfer

Creates a transaction to send SOL from one account to another.

**How to use:**
```bash
curl -X POST http://127.0.0.1:3000/send/sol \
  -H "Content-Type: application/json" \
  -d '{
    "from": "11111111111111111111111111111112",
    "to": "11111111111111111111111111111113",
    "amount": 1000000000
  }'
```

**What you get back:**
```json
{
  "transaction": "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA...",
  "message": "Transaction created successfully"
}
```

### 7. **POST /send/token** - Transfer tokens

Creates a transaction to transfer SPL tokens between accounts.

**How to use:**
```bash
curl -X POST http://127.0.0.1:3000/send/token \
  -H "Content-Type: application/json" \
  -d '{
    "destination": "11111111111111111111111111111114",
    "mint": "11111111111111111111111111111113",
    "owner": "11111111111111111111111111111112",
    "amount": 500000
  }'
```

**What you get back:**
```json
{
  "transaction": "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA...",
  "message": "Token transfer transaction created successfully"
}
```

## 🌐 Try it live!

I've got the server running publicly so you can test it out:

**Public URL:**
```
https://c94c-2409-40c0-c-6f06-449f-1501-a146-ecbb.ngrok-free.app
```

Just replace `localhost:3000` with the ngrok URL in any of the examples above. For instance:
```bash
curl -X POST https://c94c-2409-40c0-c-6f06-449f-1501-a146-ecbb.ngrok-free.app/keypair
```

**All endpoints work the same way:**
- `/keypair` - Generate a keypair
- `/token/create` - Create SPL token
- `/token/mint` - Mint tokens
- `/message/sign` - Sign messages
- `/message/verify` - Verify signatures
- `/send/sol` - SOL transfers
- `/send/token` - Token transfers

**Want to see what's happening?**
Check the ngrok dashboard at http://127.0.0.1:4040 when you're running it locally.

## 🏗️ How it's organized

I tried to keep the code structure clean and easy to navigate:

```
src/
├── main.rs              # Server setup and routing
├── handlers/            # The actual endpoint logic
│   ├── keypair.rs       # Keypair generation
│   ├── token.rs         # SPL token stuff
│   ├── message.rs       # Message signing/verification
│   └── transfer.rs      # SOL and token transfers
├── models/              # Request/response types
│   ├── request.rs       # What the API expects
│   └── response.rs      # What the API returns
└── utils/               # Helper functions
    ├── crypto.rs        # Cryptographic operations
    └── solana.rs        # Solana-specific utilities
```

## 🔐 Security stuff

- Private keys are only kept in memory, never saved to disk
- Using well-tested crypto libraries (ed25519-dalek)
- All inputs are validated before processing
- No secret information leaks in error messages

## 🧪 Testing

I've included a few test scripts to make sure everything works:

```bash
# Test everything locally
./test-new-format.sh

# Test the public deployment
./test-public-new-format.sh
```

You can also test manually with curl using the examples above.

## 📚 When things go wrong

The API uses standard HTTP status codes:
- **200** - Everything worked
- **400** - You sent invalid data
- **422** - Valid JSON but invalid Solana data (like bad public keys)
- **500** - Something broke on my end

Error responses look like this:
```json
{
  "error": "Invalid pubkey format"
}
```

## � A few notes

This API returns direct JSON responses instead of wrapping everything in `{success: true, data: {...}}` objects. I found this approach works better with automated testing systems and feels more natural to use.

The transaction endpoints return base64-encoded serialized transactions that you can submit to the Solana network. The message endpoints work with any text you want to sign/verify.

For the examples, I used placeholder public keys that are obviously fake. In real usage, you'd use actual Solana public keys from your wallet or generated keypairs.

## 🛠️ Development

If you want to hack on this:

```bash
# Format the code nicely
cargo fmt

# Run any tests
cargo test

# Check for common issues
cargo clippy

# Build an optimized version
cargo build --release
```

## 📋 Assignment checklist

- ✅ **7 POST endpoints** - All implemented and working
- ✅ **Direct JSON responses** - No unnecessary wrappers
- ✅ **Base58/Base64 encoding** - Used where appropriate
- ✅ **Serialized transactions** - Ready for Solana submission
- ✅ **CORS enabled** - Works from web browsers
- ✅ **GET endpoints** - Health check and basic info
- ✅ **Public deployment** - Available via ngrok
- ✅ **Comprehensive testing** - Multiple test scripts included

## 📄 License

This was built for a Solana Fellowship assignment. Feel free to use it as a reference or starting point for your own projects!
