# File: tmux.sh
# Description: tmux utility functions for bash scripts
# Usage: . ./tmux.sh
# Author: NoveIX
# Created: 2026-05-29
# Last Updated: 2026-06-03
# Version: 1.0.0
# Requires: logger.sh
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

tmux_exists() {
    local session="$1"

    if tmux has-session -t "$session" 2>/dev/null; then
        log_trace "Tmux session '$session' exists"
        return 0
    else
        log_trace "Tmux session '$session' does not exist"
        return 1
    fi
}

#
tmux_attach() {
    local session="$1"

    if tmux has-session -t "$session" 2>/dev/null; then
        log_info "Connecting to tmux session '$session'"
        tmux attach-session -t "$session"
    else
        log_error "Session '$session' not found"
        return 1
    fi
}

#
tmux_enter() {
    local session="$1"

    if tmux send-keys -t "$session" Enter; then
        log_info "Sent ENTER to tmux session '$session'"
        return 0
    else
        log_error "Failed to send ENTER to tmux session '$session'"
        return 1
    fi
}