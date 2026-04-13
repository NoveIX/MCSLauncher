#!/bin/sh

# Absolute path to the script's root directory
SCRIPT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Run the Python script using absolute paths
python3 "$SCRIPT_ROOT/src/main.py" "$@"