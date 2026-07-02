# File: tmux.sh
# Description: Tmux utility functions for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

exists_tmux() {
    local session="$1"

    # Check mandatory parameters
    require_param "session" "$session" "exists_tmux" || return 1

    # Check if the tmux session exists
    tmux has-session -t "$session" 2>/dev/null
}

attach_tmux() {
    local session="$1"
    local window="$2"

    # Check mandatory parameters
    require_param "session" "$session" "attach_tmux" || return 1

    # Check if the tmux session exists
    if ! exists_tmux "$session"; then
        log_error "tmux session $session not found" "print"
        return 1
    fi

    # Attach to the tmux session
    log_info "connecting to session $session"
    tmux attach-session -t "${session}:${window}"
}

# Send an ENTER key to a tmux session - NOT USED
#enter_tmux() {
#    local session="$1"
#    local window="${2:-0}"
#
#    # Check mandatory parameters
#    require_param "session" "$session" "enter_tmux" || return 1
#
#    # Check if the tmux session exists
#    if ! exists_tmux "$session"; then
#        log_error "tmux session $session not found" "print"
#        return 1
#    fi
#
#    # Send an ENTER key to the tmux session
#    if tmux send-keys -t "${session}:${window}" C-m; then
#        log_info "sent ENTER to tmux session $session"
#        return 0
#    fi
#
#    log_error "failed to send ENTER to tmux session $session" "print"
#    return 1
#}

send_tmux() {
    local session="$1"

    # Check mandatory parameters
    require_param "session" "$session" "send_tmux" || return 1

    # Shift the command arguments to get the actual command to send
    shift

    # Check if command is provided
    if [[ $# -eq 0 ]]; then
        log_error "send_tmux: missing command" "print"
        return 1
    fi

    # Check if the tmux session exists
    if ! exists_tmux "$session"; then
        log_error "tmux session $session not found" "print"
        return 1
    fi

    # Send the command to the tmux session
    if tmux send-keys -t "${session}:${window}" "$*" C-m; then
        log_info "sent command to $session: $*"
        return 0
    fi

    log_error "failed to send command to $session: $*" "print"
    return 1
}

kill_tmux() {
    local session="$1"

    # Check mandatory parameters
    require_param "session" "$session" "send_tmux" || return 1

    # Check if the tmux session exists
    if ! exists_tmux "$session"; then
        log_error "tmux session $session not found" "print"
        return 1
    fi

    # Kill tmux session
    if tmux kill-session -t "$session"; then
        log_info "tmux session $session killed"
        return 0
    fi

    log_error "failed to kill tmux session $session" "print"
    return 1
}

wait_tmux() {
    local session="$1"
    local timeout="${2:-600}" # default: 10 minutes
    local elapsed=0

    # Check mandatory parameters
    require_param "session" "$session" "wait_tmux" || return 1

    log_info "waiting for tmux session $session to stop (timeout: ${timeout}s)"

    # Wait until the tmux session no longer exists
    while exists_tmux "$session"; do
        sleep 1
        ((elapsed++)) || true

        # Check for timeout
        if (( elapsed >= timeout )); then
            log_error "timeout waiting for tmux session $session to stop (${timeout}s)" "print"
            return 1
        fi
    done

    sleep 2
    log_info "tmux session $session stopped"
    return 0
}
