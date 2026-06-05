# File: start.sh
# Description: start command functions for mcsl
# Usage: . ./start.sh
# Author: NoveIX
# Created: 2026-06-03
# Last Updated: 2026-06-03
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

mcsl_start() {
    local session_name="$1"
    local mcsl_dir="$2"
    local core_dir="$mcsl_dir/src/lib/core"
    local mcslctl="$mcsl_dir/src/script/mcslctl.sh"
    
    # Load command module
    load_module "$core_dir/command.sh"
    check_command "tmux" || exit 1
    check_command "java" "warn"
    
    # Load tmux module
    load_module "$core_dir/tmux.sh"
    
    if tmux_exists "$session_name"; then
        log_warn "tmux session $session_name already exists" "print"
        return 2
    else
        tmux new-session -d -s "$session_name" -n "mcslctl" \
        bash -c '"$0" "$@"' "$mcslctl" "$mcsl_dir"
    fi
}