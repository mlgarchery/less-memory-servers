#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

build_rust() {
    if [ ! -f ./rust ]; then
        echo "[build] rustc rust.rs"
        rustc rust.rs -o rust
    fi
}

build_go() {
    if [ ! -f ./go_server ]; then
        echo "[build] go build go.go"
        go build -o go_server go.go
    fi
}

build_zig() {
    if [ ! -f ./zig_server ]; then
        echo "[build] zig build-exe zig.zig"
        zig build-exe zig.zig -fno-entry -OReleaseSmall -femit-bin=zig_server
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
  all        run all servers in background
EOF
}

run_rust() {
    build_rust
    echo "[run] rust on :8080"
    exec ./rust
}

run_python() {
    echo "[run] python on :8081"
    exec python3 python.py
}

run_node() {
    echo "[run] node on :8082"
    exec node node.js
}

run_zig() {
    build_zig
    echo "[run] zig on :8083"
    exec ./zig_server
}

run_go() {
    build_go
    echo "[run] go on :8084"
    exec ./go_server
}

run_all() {
    build_rust
    build_go
    build_zig

    echo "[run] rust on :8080"
    ./rust &
    echo "[run] python on :8081"
    python3 python.py &
    echo "[run] node on :8082"
    node node.js &
    echo "[run] zig on :8083"
    ./zig_server &
    echo "[run] go on :8084"
    ./go_server &

    echo "All servers running. Press Ctrl+C to stop."
    wait
}

case "${1:-}" in
    rust)   run_rust   ;;
    python) run_python ;;
    node)   run_node   ;;
    zig)    run_zig    ;;
    go)     run_go     ;;
    all)    run_all    ;;
    *)      usage      ;;
esac
