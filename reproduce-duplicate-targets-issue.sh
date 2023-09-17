#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$BASH_SOURCE")"
cd "$SCRIPT_DIR"

LOG_FILE="duplicate-targets-issue.log"

swift package clean

ITERATION_COUNT=0
while swift build --very-verbose > "$LOG_FILE" 2>&1 ; do
   ITERATION_COUNT=$((ITERATION_COUNT + 1))

   swift package clean
done

echo "Reproduced after $ITERATION_COUNT iterations. See \`$LOG_FILE\`."
