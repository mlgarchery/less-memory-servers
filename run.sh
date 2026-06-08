#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

build_rust() {
    if [ ! -f ./rust/target/release/rust-server ]; then
        echo "[build] cargo build --release (rust)"
        cargo build --release --manifest-path rust/Cargo.toml
    fi
}

build_go() {
    if [ ! -f ./go/go_server ]; then
        echo "[build] go build go"
        CGO_ENABLED=0 go build -ldflags="-s -w" -trimpath -o go/go_server go/main.go
    fi
}

build_zig() {
    if [ ! -f ./zig/zig-out/bin/zig-server ]; then
        echo "[build] zig build (zig)"
        zig build --prefix zig/zig-out --build-file zig/build.zig
    fi
}

build_tinygo() {
    if [ ! -f ./tinygo/tinygo_server ]; then
        echo "[build] tinygo build tinygo"
        # TinyGo 0.37.0 supports Go 1.19–1.24; find a compatible Go version
        local go124=""
        for candidate in go1.24 go1.24.4 "$HOME/go/bin/go1.24.4" "$HOME/sdk/go1.24.4/bin/go"; do
            if command -v "$candidate" &>/dev/null; then
                go124="$candidate"
                break
            fi
        done
        if [ -n "$go124" ]; then
            local goroot
            goroot=$("$go124" env GOROOT)
            PATH="$goroot/bin:$PATH" GOROOT="$goroot" tinygo build -o tinygo/tinygo_server -no-debug tinygo/main.go
        else
            tinygo build -o tinygo/tinygo_server -no-debug tinygo/main.go
        fi
    fi
}

usage() {
    cat <<EOF
Usage: $0 <server>

Servers:
  rust       port 8080  (compiled)
  python     port 8081  (interpreted)
  node       port 8082  (interpreted)
  zig        port 8083  (compiled)
  go         port 8084  (compiled)
  tinygo     port 8085  (compiled)
  all        run all servers in background
EOF
}

run_rust() {
    build_rust
    echo "[run] rust    http://localhost:8080/hello"
    exec ./rust/target/release/rust-server
}

run_python() {
    echo "[run] python  http://localhost:8081/hello"
    exec python3 python/server.py
}

run_node() {
    echo "[run] node    http://localhost:8082/hello"
    exec node node/server.js
}

run_zig() {
    build_zig
    echo "[run] zig     http://localhost:8083/hello"
    exec ./zig/zig-out/bin/zig-server
}

run_go() {
    build_go
    echo "[run] go      http://localhost:8084/hello"
    exec ./go/go_server
}

run_tinygo() {
    build_tinygo
    echo "[run] tinygo  http://localhost:8085/hello"
    exec ./tinygo/tinygo_server
}

PIDFILE="$DIR/.server_pids"

record_pids() {
    echo "$$" > "$PIDFILE"
}

cleanup() {
    trap - SIGINT SIGTERM
    echo ""
    echo "[stop] killing all servers..."
    rm -f "$PIDFILE"
    kill 0 2>/dev/null
    wait 2>/dev/null
    echo "[stop] done."
    exit 0
}
trap cleanup SIGINT SIGTERM

run_all() {
    build_rust
    build_go
    build_zig
    build_tinygo

    record_pids

    echo "[run] rust    http://localhost:8080/hello"
    ./rust/target/release/rust-server &
    echo "[run] python  http://localhost:8081/hello"
    python3 python/server.py &
    echo "[run] node    http://localhost:8082/hello"
    node node/server.js &
    echo "[run] zig     http://localhost:8083/hello"
    ./zig/zig-out/bin/zig-server &
    echo "[run] go      http://localhost:8084/hello"
    ./go/go_server &
    echo "[run] tinygo  http://localhost:8085/hello"
    ./tinygo/tinygo_server &

    echo "All servers running. Press Ctrl+C to stop."
    wait
}

case "${1:-}" in
    rust)   run_rust   ;;
    python) run_python ;;
    node)   run_node   ;;
    zig)    run_zig    ;;
    go)     run_go     ;;
    tinygo) run_tinygo ;;
    all)    run_all    ;;
    *)      usage      ;;
esac
