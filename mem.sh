#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

PIDFILE="$DIR/.server_pids"

if [ ! -f "$PIDFILE" ]; then
    echo "No servers running. Start them with: ./run.sh all"
    exit 1
fi

LEADER=$(cat "$PIDFILE")

if ! kill -0 "$LEADER" 2>/dev/null; then
    echo "No servers running. Start them with: ./run.sh all"
    rm -f "$PIDFILE"
    exit 1
fi

PIDS=$(ps --ppid "$LEADER" -o pid= 2>/dev/null || true)

pid_list=$(echo $PIDS | tr ' ' ',')

echo "Memory usage of running servers:"
echo ""
ps -p "$pid_list" -o pid,%mem,rss:8,vsz:8,comm --sort=-%mem
echo ""
echo "Columns:"
echo "  PID   - Process ID"
echo "  %MEM  - Percentage of total physical RAM used"
echo "  RSS   - Resident Set Size in KB (actual physical memory held in RAM)"
echo "  VSZ   - Virtual Size in KB (total virtual memory address space allocated)"
echo "  COMM  - Process command name"
