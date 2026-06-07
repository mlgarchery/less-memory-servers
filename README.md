#

Simplest code for the lightest http server that returns "Hello World" on route `/hello`, using standard libraries only.

| Server | Port | Type        |
| ------ | ---- | ----------- |
| rust   | 8080 | compiled    |
| python | 8081 | interpreted |
| node   | 8082 | interpreted |
| zig    | 8083 | compiled    |
| go     | 8084 | compiled    |

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
```

The script auto-builds compiled servers if needed.
