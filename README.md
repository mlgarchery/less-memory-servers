#

Simplest code for the lightest http server that returns "Hello World" on route `/hello`, using standard libraries only.

| Server | Port | Type        |
| ------ | ---- | ----------- |
| rust   | 8080 | compiled    |
| python | 8081 | interpreted |
| node   | 8082 | interpreted |
| zig    | 8083 | compiled    |
| go     | 8084 | compiled    |

## Build notes

The Go server is built with `CGO_ENABLED=0 -ldflags="-s -w" -trimpath` to produce a static, stripped binary. This reduces VSZ from ~1.6 GB (default dynamic build with glibc) to ~1.2 GB. The remaining VSZ is Go's runtime heap address space reservation, not actual memory (RSS stays ~5 MB).

## Quick start

```bash
# Run a single server
./run.sh rust
./run.sh python
./run.sh node
./run.sh zig
./run.sh go

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
