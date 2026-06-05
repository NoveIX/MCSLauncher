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

    [[ -z "$session" ]] && return 1

    if tmux has-session -t "$session" 2>/dev/null; then
        log_trace "Tmux session '$session' exists"
        return 0
    fi

    log_trace "Tmux session '$session' does not exist"
    return 1
}

#
tmux_attach() {
    local session="$1"

    if [[ -z "$session" ]]; then
        log_error "tmux_attach: missing session name"
        return 1
    fi

    if ! tmux_exists "$session"; then
        log_error "Session $session not found"
        return 1
    fi

    log_info "Attaching to tmux session $session"

    tmux attach-session -t "$session"
}

#
tmux_enter() {
    local session="$1"

    if [[ -z "$session" ]]; then
        log_error "tmux_enter: missing session name"
        return 1
    fi

    if ! tmux_exists "$session"; then
        log_error "Session $session not found"
        return 1
    fi

    if tmux send-keys -t "$session" C-m; then
        log_info "Sent ENTER to tmux session $session"
        return 0
    else
        log_error "Failed to send ENTER to tmux session $session"
        return 1
    fi
}

tmux_send() {
    local session="$1"
    shift

    if [[ -z "$session" || $# -eq 0 ]]; then
        log_error "tmux_send: missing session or command"
        return 1
    fi

    if ! tmux_exists "$session"; then
        log_error "Session $session not found"
        return 1
    fi

    if tmux send-keys -t "$session" "$*" C-m; then
        log_info "Sent command to tmux $session: $*"
        return 0
    else
        log_error "Failed to send command to tmux $session: $*"
        return 1
    fi
}