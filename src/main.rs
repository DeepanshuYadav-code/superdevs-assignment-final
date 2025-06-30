mod handlers;
mod models;
mod utils;

use axum::{
    routing::{get, post},
    Router,
    response::{Json, Response, IntoResponse},
    http::{Method, HeaderValue, header, StatusCode},
    extract::rejection::JsonRejection,
};
use tower_http::cors::{CorsLayer, Any};
use tower_http::set_header::SetResponseHeaderLayer;
use std::net::SocketAddr;
use serde_json::json;

async fn root() -> Json<serde_json::Value> {
    Json(json!({
        "success": true,
        "message": "🚀 Solana HTTP Server is running!",
        "version": "1.0.0",
        "endpoints": [
            "POST /keypair - Generate new Solana keypair",
            "POST /token/create - Create SPL Token InitializeMint instruction",
            "POST /token/mint - Create SPL Token MintTo instruction",
            "POST /message/sign - Sign message with Ed25519",
            "POST /message/verify - Verify Ed25519 signature",
            "POST /send/sol - Create SOL transfer instruction",
            "POST /send/token - Create SPL token transfer instruction",
            "GET /health - Health check endpoint"
        ],
        "documentation": "https://github.com/solana-labs/solana",
        "author": "Solana Fellowship Assignment"
    }))
}

async fn health() -> Json<serde_json::Value> {
    Json(json!({
        "success": true,
        "status": "healthy",
        "timestamp": chrono::Utc::now().to_rfc3339(),
        "uptime": "running"
    }))
}

async fn api_docs() -> Json<serde_json::Value> {
    Json(json!({
        "success": true,
        "api_version": "1.0.0",
        "title": "Solana HTTP Server API",
        "description": "REST API for Solana blockchain operations",
        "base_url": "Current server URL",
        "endpoints": {
            "GET /": {
                "description": "API information and available endpoints",
                "response_type": "application/json"
            },
            "GET /health": {
                "description": "Health check endpoint",
                "response_example": {
                    "success": true,
                    "status": "healthy",
                    "timestamp": "2025-06-30T17:16:15.424065654+00:00",
                    "uptime": "running"
                }
            },
            "GET /docs": {
                "description": "This API documentation"
            },
            "POST /keypair": {
                "description": "Generate new Solana keypair",
                "request_body": {},
                "response_example": {
                    "success": true,
                    "data": {
                        "pubkey": "base58_encoded_public_key",
                        "secret": "base58_encoded_secret_key"
                    }
                }
            },
            "POST /token/create": {
                "description": "Create SPL Token InitializeMint instruction",
                "request_body": {
                    "mintAuthority": "base58_encoded_pubkey",
                    "mint": "base58_encoded_pubkey",
                    "decimals": 9
                },
                "response_example": {
                    "success": true,
                    "data": {
                        "program_id": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                        "accounts": "array_of_account_metas",
                        "instruction_data": "base64_encoded_data"
                    }
                }
            },
            "POST /token/mint": {
                "description": "Create SPL Token MintTo instruction",
                "request_body": {
                    "mint": "base58_encoded_pubkey",
                    "destination": "base58_encoded_pubkey",
                    "authority": "base58_encoded_pubkey",
                    "amount": 1000000
                }
            },
            "POST /message/sign": {
                "description": "Sign message with Ed25519",
                "request_body": {
                    "message": "text_to_sign",
                    "secret": "base58_encoded_secret_key"
                },
                "response_example": {
                    "success": true,
                    "data": {
                        "signature": "base64_encoded_signature",
                        "pubkey": "base58_encoded_pubkey"
                    }
                }
            },
            "POST /message/verify": {
                "description": "Verify Ed25519 signature",
                "request_body": {
                    "message": "original_text",
                    "signature": "base64_encoded_signature",
                    "pubkey": "base58_encoded_pubkey"
                },
                "response_example": {
                    "success": true,
                    "data": {
                        "valid": true
                    }
                }
            },
            "POST /send/sol": {
                "description": "Create SOL transfer instruction",
                "request_body": {
                    "from": "base58_encoded_pubkey",
                    "to": "base58_encoded_pubkey",
                    "amount": 1000000000
                }
            },
            "POST /send/token": {
                "description": "Create SPL token transfer instruction",
                "request_body": {
                    "destination": "base58_encoded_pubkey",
                    "mint": "base58_encoded_pubkey",
                    "owner": "base58_encoded_pubkey",
                    "amount": 1000000
                }
            }
        },
        "response_format": {
            "success_response": {
                "success": true,
                "data": "endpoint_specific_data"
            },
            "error_response": {
                "success": false,
                "error": "descriptive_error_message"
            }
        },
        "encoding": {
            "pubkeys": "base58",
            "secret_keys": "base58",
            "signatures": "base64",
            "instruction_data": "base64"
        }
    }))
}

// Custom error handler for JSON parsing errors
async fn handle_json_rejection(rejection: JsonRejection) -> Response {
    let error_message = match rejection {
        JsonRejection::JsonDataError(_) => "Invalid JSON format",
        JsonRejection::JsonSyntaxError(_) => "JSON syntax error",
        JsonRejection::MissingJsonContentType(_) => "Missing Content-Type: application/json header",
        _ => "JSON parsing error",
    };

    let json_response = json!({
        "success": false,
        "data": null,
        "error": error_message
    });

    (StatusCode::BAD_REQUEST, Json(json_response)).into_response()
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(root))
        .route("/health", get(health))
        .route("/docs", get(api_docs))
        .route("/keypair", post(handlers::generate_keypair))
        .route("/token/create", post(handlers::create_token))
        .route("/token/mint", post(handlers::mint_token))
        .route("/message/sign", post(handlers::sign_message))
        .route("/message/verify", post(handlers::verify_message))
        .route("/send/sol", post(handlers::send_sol))
        .route("/send/token", post(handlers::send_token))
        .layer(SetResponseHeaderLayer::if_not_present(
            header::CONTENT_TYPE,
            HeaderValue::from_static("application/json"),
        ))
        .layer(SetResponseHeaderLayer::if_not_present(
            header::CACHE_CONTROL,
            HeaderValue::from_static("no-cache"),
        ))
        .layer(
            CorsLayer::new()
                .allow_methods([Method::GET, Method::POST, Method::OPTIONS])
                .allow_headers(Any)
                .allow_origin(Any)
                .allow_credentials(false)
                .expose_headers(Any)
        );

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    println!("🚀 Solana HTTP Server listening on http://{}", addr);
    println!("📍 Available endpoints:");
    println!("  GET  / - API information");
    println!("  GET  /health - Health check");
    println!("  GET  /docs - API documentation");
    println!("  POST /keypair");
    println!("  POST /token/create");
    println!("  POST /token/mint");
    println!("  POST /message/sign");
    println!("  POST /message/verify");
    println!("  POST /send/sol");
    println!("  POST /send/token");

    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("Failed to bind to address");

    axum::serve(listener, app)
        .await
        .expect("Server failed to start");
}
