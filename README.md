# Minimal HTTP "Hello World" Servers

Each server returns `"Hello World"` on `GET /hello` and `404` otherwise.

| Server | Port | Type        | Source                  | Approach           |
| ------ | ---- | ----------- | ----------------------- | ------------------ |
| rust   | 8080 | compiled    | `rust/src/main.rs`      | axum + tokio       |
| python | 8081 | interpreted | `python/server.py`      | stdlib http.server |
| node   | 8082 | interpreted | `node/server.js`        | stdlib http        |
| zig    | 8083 | compiled    | `zig/src/main.zig`      | httpz              |
| go     | 8084 | compiled    | `go/main.go`            | stdlib net/http    |
| tinygo | 8085 | compiled    | `tinygo/main.go`        | raw syscalls       |

## Build notes

**Rust** uses [axum](https://github.com/tokio-rs/axum) + tokio via Cargo. Built with `cargo build --release`.

**Zig** uses [httpz](https://github.com/karlseguin/http.zig) via `zig build`. Dependencies are declared in `zig/build.zig.zon` and fetched automatically from `~/.cache/zig/` on first build.

**Go** is built with `CGO_ENABLED=0 -ldflags="-s -w" -trimpath` to produce a static, stripped binary. This reduces VSZ from ~1.6 GB (default dynamic build with glibc) to ~1.2 GB. The remaining VSZ is Go's runtime heap address space reservation, not actual memory (RSS stays ~5 MB).

**TinyGo** uses raw Linux syscalls (`socket`, `bind`, `listen`, `accept`, `read`, `write`) instead of the `net` or `net/http` packages. TinyGo's `net` package requires a hardware "netdev" driver — an abstraction designed for embedded targets (ESP32, Wiznet W5500, etc.) where networking goes through an external chip. There is no Linux netdev implementation in TinyGo, so `net/http` is not usable on Linux. The resulting binary is ~282 KB vs ~5.5 MB for standard Go.

**Go version compatibility:** TinyGo 0.37.0 only supports Go 1.19–1.24. If your system Go is newer (e.g. 1.26), install a compatible version alongside it:

```bash
go install golang.org/dl/go1.24.4@latest
go1.24.4 download
```

`run.sh` detects `go1.24.4` automatically and sets `GOROOT` accordingly when building the TinyGo server.

## Quick start

```bash
# Run a single server
./run.sh rust
./run.sh python
./run.sh node
./run.sh zig
./run.sh go
./run.sh tinygo

# Run all at once
./run.sh all

# Compare memory
./mem.sh

# Run stress test in another terminal
./stress.sh
```

`stress.sh` sends 1000 concurrent requests (50 at a time) to each server's `/hello` endpoint and reports:

| Column | Description                          |
| ------ | ------------------------------------ |
| TOTAL  | Total requests completed             |
| OK     | Responses with HTTP 200              |
| FAIL   | Curl errors (timeout, connection...) |
| 4XX    | Responses with HTTP 4xx status       |
| 5XX    | Responses with HTTP 5xx status       |
| TIME_S | Total elapsed time in seconds        |
| REQ/S  | Requests per second                  |
| AVG_MS | Average time per request in ms       |

You can tune `REQUESTS` and `CONCURRENCY` at the top of the script.

The script auto-builds compiled servers if needed.
