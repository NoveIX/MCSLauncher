# File: start.sh
# Description: start command functions for mcsl
# Usage: . ./start.sh
# Author: NoveIX
# Created: 2026-06-03
# Last Updated: 2026-06-06
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

start_server() {
    local session_name="$1"
    local mcsl_dir="$2"
    local core_dir="$mcsl_dir/src/lib/core"
    local mcslctl="$mcsl_dir/src/script/mcslctl.sh"

    # Check mandatory parameter
    if [[ -z "$session_name" ]]; then
        log_error "mcsl_start: missing required parameter: session_name"
        return 1
    fi

    if [[ -z "$mcsl_dir" ]]; then
        log_error "mcsl_start: missing required parameter: mcsl_dir"
        return 1
    fi

    # Load command module
    load_module "$core_dir/command.sh"
    check_command "tmux" || exit 1
    check_command "java" "warn"

    # Load tmux module
    load_module "$core_dir/tmux.sh"

    # Check if the tmux session already exists
    # If it does, log a warning and return with a specific code
    if ! tmux_exists "$session_name"; then
        local runtime_dir="$mcsl_dir/src/runtime"
        local ctlrestart="$runtime_dir/mcslctl.restart"

        mkdir -p "$runtime_dir"

        # ensure restart/keep-alive flag exists
        printf -- "%s\n" "Starting server at $(date '+%F %T')" >> "$ctlrestart"
        log_info "Starting server at $(date '+%F %T')"

        # Create a new detached tmux session that runs the mcslctl script
        tmux new-session -d -s "$session_name" -n "mcslctl" \
        bash -c '"$0" "$@"' "$mcslctl" "$mcsl_dir"
    else
        log_warn "tmux session $session_name already exists" "print"
        return 2
    fi
}