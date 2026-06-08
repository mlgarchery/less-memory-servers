# Minimal HTTP "Hello World" Servers

Each server returns `"Hello World"` on `GET /hello` and `404` otherwise.

| Server | Port | Type        |
| ------ | ---- | ----------- |
| rust   | 8080 | compiled    |
| python | 8081 | interpreted |
| node   | 8082 | interpreted |
| zig    | 8083 | compiled    |
| go     | 8084 | compiled    |
| tinygo | 8085 | compiled    |

## Rust — `rust/src/main.rs` (axum + tokio)

```rust
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
```

## Python — `python/server.py`

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

## Node — `node/server.js`

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

## Zig — `zig/src/main.zig` (httpz)

```zig
const std = @import("std");
const httpz = @import("httpz");

pub fn main(init: std.process.Init) !void {
    var server = try httpz.Server(void).init(init.io, std.heap.smp_allocator, .{ .address = .all(8083) }, {});
    defer server.deinit();

    var router = try server.router(.{});
    router.get("/hello", hello, .{});

    try server.listen();
}

fn hello(_: *httpz.Request, res: *httpz.Response) !void {
    res.body = "Hello World";
}
```

## Go — `go/main.go`

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

## TinyGo — `tinygo/main.go`

Raw Linux syscalls (`socket`, `bind`, `listen`, `accept`, `read`, `write`). TinyGo's `net` package requires a hardware netdev driver not available on Linux, so HTTP stdlib is not usable.
