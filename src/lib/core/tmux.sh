# File: tmux.sh
# Description: tmux utility functions for bash scripts
# Usage: . ./tmux.sh
# Author: NoveIX
# Created: 2026-05-29
# Last Updated: 2026-06-06
# Version: 1.0.0
# Requires: logger.sh
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

# Check if a tmux session exists
tmux_exists() {
    local session="$1"

    # Check if the session name is provided
    [[ -z "$session" ]] && return 1

    # Check if the tmux session exists
    if tmux has-session -t "$session" 2>/dev/null; then
        log_trace "Tmux session '$session' exists"
        return 0
    fi

    # Session does not exist
    log_trace "Tmux session '$session' does not exist"
    return 1
}

# Attach to a tmux session
tmux_attach() {
    local session="$1"

    # Check if the session name is provided
    if [[ -z "$session" ]]; then
        log_error "tmux_attach: missing session name"
        return 1
    fi

    # Check if the tmux session exists
    if ! tmux_exists "$session"; then
        log_error "Session $session not found"
        return 1
    fi

    # Attach to the tmux session
    log_info "Attaching to session $session"
    tmux attach-session -t "$session"
}

# Send an ENTER key to a tmux session
tmux_enter() {
    local session="$1"

    # Check if the session name is provided
    if [[ -z "$session" ]]; then
        log_error "tmux_enter: missing session name"
        return 1
    fi

    # Check if the tmux session exists
    if ! tmux_exists "$session"; then
        log_error "Session $session not found"
        return 1
    fi

    # Send an ENTER key to the tmux session
    if tmux send-keys -t "$session" C-m; then
        log_info "Sent ENTER to session $session"
        return 0
    else
        log_error "Failed to send ENTER to session $session"
        return 1
    fi
}

# Send a command to a tmux session
tmux_send() {
    local session="$1"

    # Shift the command arguments to get the actual command to send
    shift

    # Check if the session name and command are provided
    if [[ -z "$session" || $# -eq 0 ]]; then
        log_error "tmux_send: missing session or command"
        return 1
    fi

    # Check if the tmux session exists
    if ! tmux_exists "$session"; then
        log_error "Session $session not found"
        return 1
    fi

    # Send the command to the tmux session
    if tmux send-keys -t "$session" "$*" C-m; then
        log_info "Sent command to $session: $*"
        return 0
    else
        log_error "Failed to send command to $session: $*"
        return 1
    fi
}