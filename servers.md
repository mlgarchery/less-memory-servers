# Minimal HTTP "Hello World" Servers

Each server returns `"Hello World"` on `GET /hello` and `404` otherwise, using only the standard library.

| Server | Port | Type |
|--------|------|------|
| Rust | 8080 | compiled |
| Python | 8081 | interpreted |
| Node | 8082 | interpreted |
| Zig | 8083 | compiled |
| Go | 8084 | compiled |

## Rust — `rust.rs`

```rust
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
            "HTTP/1.1 200 OK\r\nContent-Length: 11\r\n\r\nHello World"
        } else {
            "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n"
        };

        stream.write_all(response.as_bytes()).unwrap();
    }
}
```

## Python — `python.py`

```python
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/hello":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"Hello World")
        else:
            self.send_response(404)
            self.end_headers()


HTTPServer(("0.0.0.0", 8081), Handler).serve_forever()
```

## Node — `node.js`

```js
const http = require("http");

http
  .createServer((req, res) => {
    if (req.url === "/hello") {
      res.writeHead(200);
            res.end("Hello World");
    } else {
      res.writeHead(404);
      res.end();
    }
  })
  .listen(8082, "0.0.0.0");
```

## Zig — `zig.zig`

```zig
const std = @import("std");
const net = std.Io.net;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const addr = try net.IpAddress.parse("0.0.0.0", 8083);

    var server = try addr.listen(io, .{});
    defer server.deinit(io);

    while (true) {
        var conn = try server.accept(io);
        defer conn.close(io);

        var read_buf: [1024]u8 = undefined;
        var reader = conn.reader(io, &read_buf);
        var writer = conn.writer(io, &.{});

        const line = reader.interface.takeDelimiterExclusive('\n') catch continue;

        const response =
            if (std.mem.startsWith(u8, line, "GET /hello "))
                "HTTP/1.1 200 OK\r\nContent-Length: 11\r\n\r\nHello World"
            else
                "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n";

        try writer.interface.writeAll(response);
    }
}
```

## Go — `go.go`

```go
package main

import (
	"net/http"
)

func main() {
	http.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
		w.Write([]byte("Hello World"))
	})
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(404)
	})
	http.ListenAndServe("0.0.0.0:8084", nil)
}
```
