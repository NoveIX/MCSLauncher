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

    # Check mandatory parameter
    if [[ -z "$cmd" ]]; then
        log_error "check_command: missing required parameter: cmd" "print"
        return 1
    fi

    # Check if command exists
    if ! command -v "$cmd" >/dev/null 2>&1; then
        local msg="Required command not found: $cmd"

        case "${mode,,}" in
            warn)
                log_warn "$msg" "print"
            ;;
            error)
                log_error "$msg" "print"
            ;;
            fatal)
                log_fatal "$msg" "print"
            ;;
            *)
                log_error "check_command: invalid mode '$mode' (defaulting to error): $msg" "print"
            ;;
        esac

        return 1
    fi

    return 0
}