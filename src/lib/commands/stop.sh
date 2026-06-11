# File: stop.sh
# Description: Stop command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

stop_server() {
    local session="$1"
    local wait="${2:-0}"
    local mode="${3:-shutdown}"

    # Check mandatory parameter
    if [[ -z "$session" ]]; then
        log_error "stop_server: missing required parameter: session" "print"
        return 1
    fi

    if [[ -z "$wait" ]]; then
        log_error "stop_server: missing required parameter: wait" "print"
        return 1
    fi

    if [[ -z "$mode" ]]; then
        log_error "stop_server: missing required parameter: mode" "print"
        return 1
    fi

    # Load command module
    load_module "$core_dir/command.sh" || return 1
    check_command "tmux" || return 1

    # Load tmux module
    load_module "$core_dir/tmux.sh" || return 1
    load_module "$core_dir/common.sh" || return 1

    # Check if the tmux session exists. If it does, proceed with the shutdown process. If not, simply return without doing anything.
    if tmux_exists "$session"; then
        local runtime_dir="$mcsl_dir/src/runtime"
        local restartctl="$runtime_dir/restartctl"

        # Remove any existing restart/keep-alive flag to ensure a clean shutdown process.
        rm -f "$restartctl"

        # Stop the server with a warning message if the wait time is greater than 30 seconds, otherwise send the stop command immediately
        if (( wait > 30 )); then
            local prewarn=$((wait - 30))
            tmux_send "$session" "say Server will $mode in $wait seconds. Please prepare to disconnect." "print"
            sleep "$prewarn"

            # 30 Seconds - cit. Lester
            tmux_send "$session" "say Server will $mode in 30 seconds. Please prepare to disconnect." "print"
            sleep 30
        else
            tmux_send "$session" "say Server will $mode in $wait seconds. Please prepare to disconnect." "print"
            sleep "$wait"
        fi

        # Send the stop command to the tmux session to initiate server shutdown and log the stopping time.
        log_info "stopping server $session at $(date '+%F %T')" "print"
        tmux_send "$session" "stop"
    fi
}