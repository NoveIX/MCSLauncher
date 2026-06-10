# File: tmux.sh
# Description: Tmux utility functions for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

# Check if a tmux session exists
tmux_exists() {
    local session="$1"

    # Check mandatory parameter
    if [[ -z "$session" ]]; then
        log_error "tmux_exists: missing required parameter: session" "print"
        return 1
    fi

    # Check if the tmux session exists
    if tmux has-session -t "$session" 2>/dev/null; then
        log_trace "session $session exists"
        return 0
    fi

    # Session does not exist
    log_trace "session $session does not exist"
    return 1
}

# Attach to a tmux session
tmux_attach() {
    local session="$1"

    # Check mandatory parameter
    if [[ -z "$session" ]]; then
        log_error "tmux_attach: missing required parameter: session" "print"
        return 1
    fi

    # Check if the tmux session exists
    if ! tmux_exists "$session"; then
        log_error "session $session not found" "print"
        return 1
    fi

    # Attach to the tmux session
    log_info "attaching to session $session"
    tmux attach-session -t "$session"
}

# Send an ENTER key to a tmux session
tmux_enter() {
    local session="$1"

    # Check mandatory parameter
    if [[ -z "$session" ]]; then
        log_error "tmux_enter: missing required parameter: session" "print"
        return 1
    fi

    # Check if the tmux session exists
    if ! tmux_exists "$session"; then
        log_error "session $session not found" "print"
        return 1
    fi

    # Send an ENTER key to the tmux session
    if tmux send-keys -t "$session" C-m; then
        log_info "sent ENTER to session $session"
        return 0
    else
        log_error "failed to send ENTER to session $session" "print"
        return 1
    fi
}

# Send a command to a tmux session
tmux_send() {
    local session="$1"
    
    # Check mandatory parameter
    if [[ -z "$session" ]]; then
        log_error "tmux_send: missing required parameter: session" "print"
        return 1
    fi

    # Shift the command arguments to get the actual command to send
    shift

    # Check if command is provided
    if [[ $# -eq 0 ]]; then
        log_error "tmux_send: missing command" "print"
        return 1
    fi

    # Check if the tmux session exists
    if ! tmux_exists "$session"; then
        log_error "session $session not found" "print"
        return 1
    fi

    # Send the command to the tmux session
    if tmux send-keys -t "$session" "$*" C-m; then
        log_info "sent command to $session: $*"
        return 0
    else
        log_error "failed to send command to $session: $*" "print"
        return 1
    fi
}

tmux_wait() {
    local session="$1"
    local timeout="${2:-600}"   # default: 10 minutes
    local elapsed=0

    # Check mandatory parameter
    if [[ -z "$session" ]]; then
        log_error "tmux_wait: missing required parameter: session" "print"
        return 1
    fi

    log_info "waiting for session $session to stop (timeout: ${timeout}s)"

    # Wait until the tmux session no longer exists
    while tmux_exists "$session"; do
        sleep 1
        ((elapsed++)) || true

        # Check for timeout
        if (( elapsed >= timeout )); then
            log_error "timeout waiting for session $session to stop (${timeout}s)"
            return 1
        fi
    done

    log_info "session $session stopped"
    return 0
}