use std::net::SocketAddr;
use tempfile::NamedTempFile;
use tokio::net::TcpListener;

#[tokio::test]
async fn test_sync() {
    // 1. Setup DB
    let db_file = NamedTempFile::new().expect("Failed to create temp db file");
    let db_path = db_file.path().to_str().unwrap();
    let database_url = format!("sqlite://{}", db_path);

    // 2. Start UqServer
    let server = uq::UqServer::new(&database_url)
        .await
        .expect("Failed to create UqServer");
    let router = server.into_router();

    // 3. Bind to a random port
    let listener = TcpListener::bind("127.0.0.1:0")
        .await
        .expect("Failed to bind");
    let addr = listener.local_addr().expect("Failed to get local addr");
    println!("Listening on {}", addr);

    // 4. Spawn the server
    tokio::spawn(async move {
        axum::serve(listener, router).await.unwrap();
    });

    // 5. Run client test
    let client = reqwest::Client::new();
    let url = format!("http://{}/uq.v1.UqService/Sync", addr);

    let res = client
        .post(&url)
        .header("Content-Type", "application/json")
        .body(r#"{ "sinceTimestampMs": "0" }"#)
        .send()
        .await
        .expect("Failed to send request");

    assert!(res.status().is_success(), "Status: {}", res.status());
    let body = res.text().await.expect("Failed to read body");
    println!("Body: {}", body);
    assert!(body.contains("serverTimestampMs"));
}
