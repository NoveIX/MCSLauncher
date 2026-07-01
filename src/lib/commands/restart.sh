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
    require_param "session" "$session" "restart_server" || return 1
    require_param "time" "$time" "restart_server" || return 1
    require_param "console" "$console" "restart_server" || return 1
    require_param "all" "$all" "restart_server" || return 1

    # REMOTE DELEGATION

    if [[ "${all,,}" == "true" || "$session" != "$session_name" ]]; then
        load_module "$core_dir/caller.sh" || return 1

        local -a args=()
        [[ "${console,,}" == "true" ]] && args+=(--console)

        # Call command in the specified session or all sessions
        if [[ "${all,,}" == "true" ]]; then
            call_sessions restart --time "$time" "${args[@]}" || return 1
        else
            call_session "$session" restart --time "$time" "${args[@]}" || return 1
        fi

        return 0
    fi

    # RESTART COMMAND EXECUTION

    # Load required modules
    load_module "$core_dir/command.sh" || return 1
    load_module "$core_dir/tmux.sh" || return 1
    load_module "$commands_dir/start.sh" || return 1
    load_module "$commands_dir/stop.sh" || return 1

    # Check required dependencies
    check_command "tmux" "fatal" || return 1

    # Restart server
    if exists_tmux "$session"; then
        stop_server "$session" "$time" "restart" "$all" || return 1
        wait_tmux "$session"
    fi

    start_server "$session" "$console" "$all" || return 1
}
