# File: stop.sh
# Description: stop command functions for mcsl
# Usage: . ./stop.sh
# Author: NoveIX
# Created: 2026-06-03
# Last Updated: 2026-06-06
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

stop_server() {
    local session="$1"
    local wait="${2:-0}"
    local mode="${3:-shutdown}"

    # Check mandatory parameter
    if [[ -z "$session" ]]; then
        log_error "mcsl_stop: missing required parameter: session"
        return 1
    fi

    # Load command module
    load_module "$core_dir/command.sh"
    check_command "tmux" || return 1

    # Load tmux module
    load_module "$core_dir/tmux.sh"
    load_module "$core_dir/common.sh"

    # Check if the tmux session exists. If it does, proceed with the shutdown process. If not, simply return without doing anything.
    if tmux_exists "$session"; then
        local runtime_dir="$mcsl_dir/src/runtime"
        local ctlrestart="$runtime_dir/mcslctl.restart"

        # Remove any existing restart/keep-alive flag to ensure a clean shutdown process.
        rm -f "$ctlrestart"

        # Stop the server with a warning message if the wait time is greater than 30 seconds, otherwise send the stop command immediately
        if (( wait > 30 )); then
            local prewarn=$((wait - 30))
            tmux_send "$session" "say Server will $mode in $wait seconds. Please prepare to disconnect."
            sleep "$prewarn"
            tmux_send "$session" "say Server will $mode in 30 seconds. Please prepare to disconnect."
            sleep 30
        else
            tmux_send "$session" "say Server will $mode in $wait seconds. Please prepare to disconnect."
            sleep "$wait"
        fi

        # Send the stop command to the tmux session to initiate server shutdown and log the stopping time.
        log_info "Stopping server at $(date '+%F %T')"
        tmux_send "$session" "stop"
    fi
}