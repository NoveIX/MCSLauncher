# File: stop.sh
# Description: stop command functions for mcsl
# Usage: . ./stop.sh
# Author: NoveIX
# Created: 2026-06-03
# Last Updated: 2026-06-03
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

mcsl_stop() {
    local session_name="$1"
    local mcsl_dir="$2"
    local wait="${3:-0}"
    local mode="${4:-shutdown}"
    local core_dir="$mcsl_dir/src/lib/core"

    # Load command module
    load_module "$core_dir/command.sh"
    check_command "tmux" || exit 1

    # Load tmux module
    load_module "$core_dir/tmux.sh"
    load_module "$core_dir/common.sh"

    # Check if the tmux session exists. If it does, proceed with the shutdown process. If not, simply return without doing anything.
    if tmux_exists "$session_name"; then
        local runtime_dir="$mcsl_dir/src/runtime"
        local ctlrestart="$runtime_dir/mcslctl.restart"

        # Remove any existing restart/keep-alive flag to ensure a clean shutdown process.
        rm -f "$ctlrestart"

        # Stop the server with a warning message if the wait time is greater than 30 seconds, otherwise send the stop command immediately
        if (( wait > 30 )); then
            local prewarn=$((wait - 30))
            tmux_send "$session_name" "say Server will $mode in $wait seconds. Please prepare to disconnect."
            sleep "$prewarn"
            tmux_send "$session_name" "say Server will $mode in 30 seconds. Please prepare to disconnect."
            sleep 30
        else
            tmux_send "$session_name" "say Server will $mode in $wait seconds. Please prepare to disconnect."
            sleep "$wait"
        fi

        # Send the stop command to the tmux session to initiate server shutdown and log the stopping time.
        log_info "Stopping server at $(date '+%F %T')"
        tmux_send "$session_name" "stop"
    fi
}