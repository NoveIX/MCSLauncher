# File: command.sh
# Description: Command utility functions for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

call_mcsl() {
    local session="$1"
    local cmd="$2"
    shift 2

    local print="print"
    if [[ ${cmd,,} == "status" ]]; then
        print="noprint"
    fi

    # Check mandatory parameters
    if [[ -z "$session" ]]; then
        log_error "call_mcsl: missing required parameter: session" "$print"
        return 1
    fi

    if [[ -z "$cmd" ]]; then
        log_error "call_mcsl: missing required parameter: cmd" "$print"
        return 1
    fi

    local mcslsh="$server_container/$session/mcsl/$mcsl_name"

    # Check if the mcsl command exists in the specified session
    if [[ ! -f "$mcslsh" ]]; then
        log_error "mcsl not found for session $session: $mcslsh" "$print"
        return 1
    fi

    log_info "executing command $cmd in session $session" "$print"

    # Call mcsl with all remaining args
    if ! bash "$mcslsh" "$cmd" "$@"; then
        log_error "command $cmd failed in session $session" "$print"
        return 1
    fi

    return 0
}