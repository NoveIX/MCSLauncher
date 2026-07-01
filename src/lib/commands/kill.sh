# File: kill.sh
# Description: Kill command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

kill_server() {
    local session="$1"
    local confirm="$2"

    # Check mandatory parameters
    require_param "session" "$session" "kill_server" || return 1

    # Block external tmux session kill attempts
    if [[ "$session" != "$session_name" ]]; then
        log_error "external tmux session not allowed. use kill without -s" "print"
        return 1
    fi

    # Check confirm is a valid boolean value (true/false)
    if [[ ! "${confirm,,}" =~ ^(true|false)$ ]]; then
        log_error "invalid confirm value $confirm (expected true|false)" "print"
        return 1
    fi

    # Check for confirmation flag
    if [[ "${confirm,,}" == "false" ]]; then
        log_fatal "destructive operation blocked: --confirm-action required" "print"
        return 1
    fi

    # Load required modules
    load_module "$core_dir/command.sh" || return 1
    load_module "$core_dir/tmux.sh" || return 1

    # Check required dependencies
    check_command "tmux" "fatal" || return 1

    # Check if the tmux session exists.
    if exists_tmux "$session"; then
        kill_tmux "$session" || return 1
        return 0
    fi

    log_info "tmux session $session does not exist" "print"
    return 0
}
