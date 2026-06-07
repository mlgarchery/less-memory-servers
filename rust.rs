use std::{
    io::{Read, Write},
    net::TcpListener,
};

fn main() {
    let listener = TcpListener::bind("0.0.0.0:8080").unwrap();

    for stream in listener.incoming() {
        let mut stream = stream.unwrap();
        let mut buffer = [0; 1024];
        stream.read(&mut buffer).unwrap();

        let response = if buffer.starts_with(b"GET /hello ") {
            "HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello"
        } else {
            "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n"
        };

        stream.write_all(response.as_bytes()).unwrap();
    }
}
