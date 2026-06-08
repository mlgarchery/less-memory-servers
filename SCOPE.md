# Project Scope

## Context

This project benchmarks minimal HTTP servers across languages to find the best fit for a specific deployment pattern: **short-lived, per-session API processes running in a cluster**.

Each process serves a single user session. It is spun up on demand, handles low-concurrency traffic (one request at a time in practice), and is terminated after **10 minutes of inactivity** or a **maximum lifetime of a few hours**.

Not every app session spawns one — this only activates for specific use cases.

## Goals

- **Low memory footprint** — many processes run in parallel in the cluster; every MB saved multiplies across instances
- **Fast startup** — processes are created on demand; boot time directly impacts user-perceived latency
- **Clean, maintainable code** — the server logic will evolve; readability matters

## Non-goals

- High concurrency — one active request per process at a time
- Long-lived connections — no websockets, no streaming
- Complex routing — a handful of endpoints at most

## Constraints

| Constraint         | Value                          |
| ------------------ | ------------------------------ |
| Concurrency        | ~1 request at a time           |
| Max lifetime       | few hours                      |
| Inactivity timeout | 10 minutes → process killed    |
| Deployment         | cluster, many parallel procs   |

## What we are measuring

| Metric        | Why it matters                                      |
| ------------- | --------------------------------------------------- |
| RSS           | Actual RAM consumed per process                     |
| Binary size   | Affects image pull time and cold-start in cluster   |
| Startup time  | Time from process spawn to first request served     |
