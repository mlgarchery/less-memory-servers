use tiny_http::{Response, Server, StatusCode};

fn main() {
    let server = Server::http("0.0.0.0:8080").expect("failed to bind port 8080 (already in use?)");

    for request in server.incoming_requests() {
        let response = if request.url() == "/hello" {
            Response::from_string("Hello World")
        } else {
            Response::from_string("").with_status_code(StatusCode(404))
        };
        request.respond(response).ok();
    }
}
