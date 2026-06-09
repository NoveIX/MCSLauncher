# File: restart.sh
# Description: Restart command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

restart_server() {
    local session="$1"
    local wait="${2:-0}"

    # Check mandatory parameter
    if [[ -z "$session" ]]; then
        log_error "mcsl_restart: missing required parameter: session" "print"
        return 1
    fi

    # Load command module
    load_module "$core_dir/command.sh"
    check_command "tmux" || exit 1

    # Load mcsl commands
    load_module "$command_dir/stop.sh" || exit 1
    load_module "$command_dir/start.sh" || exit 1

    # Restart Server
    log_info "restarting server at $(date '+%F %T')" "print"
    mcsl_stop "$session" "$mcsl_dir" "$wait" "restart"

    sleep 10

    mcsl_start "$session" "$mcsl_dir"
}