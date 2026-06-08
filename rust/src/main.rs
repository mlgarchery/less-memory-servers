use axum::{routing::get, Router};

async fn hello() -> &'static str {
    "Hello World"
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/hello", get(hello));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await
        .expect("failed to bind port 8080 (already in use?)");
    axum::serve(listener, app).await.unwrap();
}
