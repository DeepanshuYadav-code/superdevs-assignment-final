use axum::{
    response::Json,
    http::{HeaderMap, StatusCode},
    extract::{Json as JsonExtractor, Query},
    body::Body,
};
use serde_json::{json, Value};
use std::collections::HashMap;

pub async fn debug_request(
    headers: HeaderMap,
    query: Query<HashMap<String, String>>,
    body: Option<JsonExtractor<Value>>,
) -> Result<Json<Value>, StatusCode> {
    let headers_map: HashMap<String, String> = headers
        .iter()
        .map(|(k, v)| (k.to_string(), v.to_str().unwrap_or("").to_string()))
        .collect();

    let response = json!({
        "success": true,
        "data": {
            "headers": headers_map,
            "query": query.0,
            "body": body.map(|b| b.0),
            "timestamp": chrono::Utc::now().to_rfc3339()
        },
        "error": null
    });

    Ok(Json(response))
}
