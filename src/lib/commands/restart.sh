# File: restart.sh
# Description: Restart command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

restart_server() {
    local session="$1"
    local time="$2"
    local console="$3"
    local all="$4"

    # Check mandatory parameters
    if [[ -z "$session" ]]; then
        log_error "restart_server: missing required parameter: session" "print"
        return 1
    fi

    if [[ -z "$time" ]]; then
        log_error "restart_server: missing required parameter: time" "print"
        return 1
    fi

    if [[ -z "$console" ]]; then
        log_error "restart_server: missing required parameter: console" "print"
        return 1
    fi

    if [[ -z "$all" ]]; then
        log_error "restart_server: missing required parameter: all" "print"
        return 1
    fi

    # Remote session delegation - ALL MODE (priority)
    if [[ "${all,,}" == "true" ]]; then
        load_module "$core_dir/caller.sh"

        local args=()

        # Only pass the --console flag if console is set to true (case-insensitive)
        [[ "${console,,}" == "true" ]] && args+=(--console)

        for dir in "$server_container"/*/; do
            [[ -d "$dir" ]] || continue

            session="${dir%/}"
            session="${session##*/}"

            call_mcsl "$session" restart --time "$time" "${args[@]}" || true
        done

        return 0
    fi

    # Remote session delegation - SINGLE SESSION
    if [[ "$session" != "$session_name" ]]; then
        load_module "$core_dir/caller.sh"

        local args=()

        # Only pass the --console flag if console is set to true (case-insensitive)
        [[ "${console,,}" == "true" ]] && args+=(--console)

        # Call command in the specified session
        call_mcsl "$session" restart --time "$time" "${args[@]}" || true

        return 0
    fi

    # RESTART COMMAND EXECUTION

    # Load required modules
    load_module "$core_dir/command.sh" || return 1
    load_module "$core_dir/tmux.sh" || return 1
    load_module "$commands_dir/start.sh" || return 1
    load_module "$commands_dir/stop.sh" || return 1

    # Check required dependencies
    check_command tmux || return 1

    # Restart server
    if tmux_exists "$session"; then
        stop_server "$session" "$time" "restart"
        tmux_wait "$session"
        sleep 10
    fi
    start_server "$session" "$console"
}