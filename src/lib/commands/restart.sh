# File: restart.sh
# Description: restart command functions for mcsl
# Usage: . ./restart.sh
# Author: NoveIX
# Created: 2026-06-03
# Last Updated: 2026-06-06
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

restart_server() {
    local session_name="$1"
    local mcsl_dir="$2"
    local wait="${3:-0}"
    local core_dir="$mcsl_dir/src/lib/core"
    local command_dir="$mcsl_dir/src/lib/commands"

    # Check mandatory parameter
    if [[ -z "$session_name" ]]; then
        log_error "mcsl_restart: missing required parameter: session_name" "print"
        return 1
    fi

    if [[ -z "$mcsl_dir" ]]; then
        log_error "mcsl_restart: missing required parameter: mcsl_dir" "print"
        return 1
    fi

    # Load command module
    load_module "$core_dir/command.sh"
    check_command "tmux" || exit 1

    # Load mcsl commands
    load_module "$command_dir/stop.sh" || exit 1
    load_module "$command_dir/start.sh" || exit 1

    # Restart Server
    log_info "Restarting server at $(date '+%F %T')" "print"
    mcsl_stop "$session_name" "$mcsl_dir" "$wait" "restart"

    sleep 10

    mcsl_start "$session_name" "$mcsl_dir"
}