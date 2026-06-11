# File: start.sh
# Description: Start command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

start_server() {
    local session="$1"
    local console="$2"

    # Check mandatory parameter
    if [[ -z "$session" ]]; then
        log_error "start_server: missing required parameter: session" "print"
        return 1
    fi

    if [[ -z "$console" ]]; then
        log_error "start_server: missing required parameter: console" "print"
        return 1
    fi

    # Load command module
    load_module "$core_dir/command.sh" || return 1
    check_command "tmux" || return 1
    check_command "java" "warn" || true

    # Load tmux module
    load_module "$core_dir/tmux.sh" || return 1

    # Check if the tmux session already exists
    # If it does, log a warning and return with a specific code
    if ! tmux_exists "$session"; then
        local runtime_dir="$mcsl_dir/src/runtime"
        local restartctl="$runtime_dir/restartctl"

        mkdir -p "$runtime_dir"

        # ensure restart/keep-alive flag exists
        printf -- "%s\n" "Starting server at $(date '+%F %T')" >> "$restartctl"
        log_info "starting server at $(date '+%F %T')"

        # Create a new detached tmux session that runs the mcslctl script
        tmux new-session -d -s "$session" -n "mcslctl" \
        bash "$mcslctl" "$mcsl_dir"

        # Connect to tmux session
        if [[ ${console,,} == "true" ]]; then
            tmux_attach "$session"
        fi
    else
        log_warn "tmux session $session already exists" "print"
        return 0
    fi
}