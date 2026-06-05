# File: command.sh
# Description: Command utility functions for bash scripts
# Usage: . ./command.sh
# Author: NoveIX
# Created: 2026-05-29
# Last Updated: 2026-06-06
# Version: 1.0.0
# Requires: logger.sh
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

check_command() {
    local cmd="$1"
    local mode="${2:-fatal}"

    # Check if the command argument is provided. If not, log a fatal error and exit.
    if [[ -z "$cmd" ]]; then
        log_fatal "No command specified for dependency check" "print"
        return 1
    fi

    # Check if a required command is available in the system. If not, log a fatal error and exit.
    if ! command -v "$cmd" >/dev/null 2>&1; then
        case "${mode,,}" in
            warn)
                log_warn "Required command not found: $cmd" "print"
                ;;
            fatal)
                log_fatal "Required command not found: $cmd" "print"
                ;;
        esac

        return 1
    fi

    return 0
}
