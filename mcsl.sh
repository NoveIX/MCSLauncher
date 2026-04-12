#!/bin/sh

# Absolute path to the script's root directory
SCRIPT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Path to the Python binary in the virtual environment
PYTHON_BIN="$SCRIPT_ROOT/.venv/bin/python"
if [ ! -x "$PYTHON_BIN" ]; then
    PYTHON_BIN=python
fi

# Run the Python script using absolute paths
"$PYTHON_BIN" "$SCRIPT_ROOT/src/main.py" "$@"