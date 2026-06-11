# File: restart.sh
# Description: Restart command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

restart_server() {
    local session="$1"
    local wait="$2"
    local console="$3"

    # Check mandatory parameter
    if [[ -z "$session" ]]; then
        log_error "restart_server: missing required parameter: session" "print"
        return 1
    fi
    
    if [[ -z "$wait" ]]; then;
        log_error "restart_server: missing required parameter: wait" "print"
        return 1
    fi
    
    if [[ -z "$console" ]]; then;
        log_error "restart_server: missing required parameter: console" "print"
        return 1
    fi

    # Load command module
    load_module "$core_dir/command.sh" || return 1
    check_command "tmux" || return 1

    # Load tmux module
    load_module "$core_dir/tmux.sh" || return 1

    # Load mcsl commands
    load_module "$commands_dir/stop.sh" || return 1
    load_module "$commands_dir/start.sh" || return 1

    # Restart Server
    if tmux_exists "$session"; then
        stop_server "$session" "$wait" "restart"
        tmux_wait "$session"
        sleep 10
    fi

    start_server "$session" $console
}