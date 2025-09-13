# File: command.sh
# Description: Command utility functions for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

call_mcsl() {
    local session="$1"
    local cmd="$2"
    shift 2

    # Check mandatory parameters
    require_param "session" "$session" "call_mcsl" || return 1
    require_param "cmd" "$cmd" "call_mcsl" || return 1

    # status command is special, it should not print the log message
    local print="print"
    [[ "${cmd,,}" == "status" ]] && print="noprint"

    # mcsl command path for the specified session
    local mcslsh="$server_container/$session/mcsl/$mcsl_name"

    # Check if the mcsl command exists in the specified session
    if [[ ! -f "$mcslsh" ]]; then
        log_error "mcsl not found for tmux session $session: $mcslsh" "print"
        return 1
    fi

    log_info "executing command $cmd in tmux session $session" "$print"

    # Call mcsl with all remaining args
    if ! bash "$mcslsh" "$cmd" "$@"; then
        log_error "command $cmd failed in tmux session $session" "print"
        return 1
    fi

    return 0
}
