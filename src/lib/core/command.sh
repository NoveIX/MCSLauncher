# File: command.sh
# Description: Command utility functions for bash scripts
# Usage: . ./command.sh
# Author: NoveIX
# Created: 2026-05-29
# Last Updated: 2026-06-03
# Version: 1.0.0
# Requires: logger.sh
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

check_command() {
    local cmd=$1

    # Check if the command argument is provided. If not, log a fatal error and exit.
    if [[ -z "$cmd" ]]; then
        log_fatal "check_command: missing argument"
        exit 1
    fi

    # Check if a required command is available in the system. If not, log a fatal error and exit.
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_fatal "missing required command: $cmd"
        exit 1
    fi
}
