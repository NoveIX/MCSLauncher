# File: start.sh
# Description: Start command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

start_server() {
    local session="$1"
    local console="$2"

    # Check mandatory parameters
    if [[ -z "$session" ]]; then
        log_error "start_server: missing required parameter: session" "print"
        return 1
    fi

    if [[ -z "$console" ]]; then
        log_error "start_server: missing required parameter: console" "print"
        return 1
    fi

    # Remote session delegation
    if [[ "$session" != "$session_name" ]]; then
        load_module "$core_dir/caller.sh"

        local args=()

        # Only pass the --console flag if console is set to true (case-insensitive)
        if [[ "${console,,}" == "true" ]]; then
            args+=(--console)
        fi

        # Call command in the specified session
        if call_mcsl "$session" start "${args[@]}"; then
            return 0
        fi
    fi

    # Load required modules
    load_module "$core_dir/command.sh" || return 1
    load_module "$core_dir/tmux.sh" || return 1

    # Check required dependencies
    check_command "tmux" || return 1
    check_command "java" "warn" || true

    # Check if the tmux session already exists
    # If it does, log a warning and return with a specific code
    if ! tmux_exists "$session"; then
        local runtime_dir="$mcsl_dir/src/runtime"
        local restartctl="$runtime_dir/restartctl"

        mkdir -p "$runtime_dir"

        # ensure restart/keep-alive flag exists
        printf -- "%s\n" "Starting server at $(date '+%F %T')" >> "$restartctl"

        # Create a new detached tmux session that runs the mcslctl script
        log_info "starting server $session at $(date '+%F %T')" "print"
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