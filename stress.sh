#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

REQUESTS=1000
CONCURRENCY=50
ENDPOINT="/hello"
CURL_TIMEOUT=3
CONNECT_TIMEOUT=2

SERVERS=(
  "rust:8080"
  "zig:8083"
  "python:8081"
  "node:8082"
  "go:8084"
  "tinygo:8085"
)

wait_for_server() {
  local port=$1
  for i in $(seq 1 20); do
    if curl -sf --connect-timeout 1 --max-time 2 "http://localhost:${port}${ENDPOINT}" -o /dev/null 2>/dev/null; then
      return 0
    fi
    sleep 0.25
  done
  return 1
}

printf "%-10s %8s %8s %8s %8s %8s %10s %12s %12s\n" \
  "SERVER" "TOTAL" "OK" "FAIL" "4XX" "5XX" "TIME_S" "REQ/S" "AVG_MS"
echo "------------------------------------------------------------------------------------"

for entry in "${SERVERS[@]}"; do
  name="${entry%%:*}"
  port="${entry##*:}"
  url="http://localhost:${port}${ENDPOINT}"

  if ! wait_for_server "$port"; then
    printf "%-10s %8s %8s %8s %8s %8s %10s %12s %12s\n" "$name" "SKIP" "" "" "" "" "" "" ""
    continue
  fi

  tmpdir=$(mktemp -d)
  start=$(date +%s%N)

  for i in $(seq "$REQUESTS"); do
    echo "$i"
  done | xargs -P "$CONCURRENCY" -I{} bash -c \
    "curl -so /dev/null -w '%{http_code}\n' --connect-timeout $CONNECT_TIMEOUT --max-time $CURL_TIMEOUT '$url' 2>/dev/null || echo 000" \
    > "$tmpdir/codes" &

  xargs_pid=$!
  max_wait=$(( REQUESTS / CONCURRENCY * CURL_TIMEOUT + CURL_TIMEOUT + 5 ))
  if ! wait "$xargs_pid" 2>/dev/null; then
    kill "$xargs_pid" 2>/dev/null
  fi

  end=$(date +%s%N)
  elapsed_ns=$(( end - start ))
  elapsed_ms=$(( elapsed_ns / 1000000 ))
  elapsed_s=$(awk "BEGIN {printf \"%.3f\", $elapsed_ms / 1000}")

  total=$(wc -l < "$tmpdir/codes" 2>/dev/null | tr -d '[:space:]') || total=0
  if [ "$total" -eq 0 ]; then
    rm -rf "$tmpdir"
    printf "%-10s %8d %8s %8s %8s %8s %10s %12s %12s\n" "$name" "$REQUESTS" "" "" "" "" "$elapsed_s" "0" "0"
    continue
  fi

  rps=$(awk "BEGIN {printf \"%.1f\", $total / ($elapsed_ms / 1000)}")
  avg_ms=$(awk "BEGIN {printf \"%.2f\", $elapsed_ms / $total}")
  ok=$(grep -c '^200' "$tmpdir/codes" 2>/dev/null | tr -d '[:space:]') || ok=0
  err_4xx=$(grep -cE '^4' "$tmpdir/codes" 2>/dev/null | tr -d '[:space:]') || err_4xx=0
  err_5xx=$(grep -cE '^5' "$tmpdir/codes" 2>/dev/null | tr -d '[:space:]') || err_5xx=0
  err_curl=$(( total - ok - err_4xx - err_5xx ))

  rm -rf "$tmpdir"

  printf "%-10s %8d %8d %8d %8d %8d %10s %12s %12s\n" \
    "$name" "$total" "$ok" "$err_curl" "$err_4xx" "$err_5xx" "$elapsed_s" "$rps" "$avg_ms"
done
