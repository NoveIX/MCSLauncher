#!/usr/bin/env bash

# ====================================[ Parameter ]===================================== #

server_run_file="$1"    # string
crash_handle="$2"       # bool
crash_retry="$3"        # int
restart_temp_file="$4"  # string
mcsm_dir="$5"           # string

# local var
exit_while=false        # bool
crash_handle_timeout=0  # int

# =====================================[ Function ]===================================== #

# Convert seconds to human-readable format
human_readable_runtime() {
    local total_seconds=$1
    local days=$(( total_seconds / 86400 ))
    local hours=$(( (total_seconds % 86400) / 3600 ))
    local minutes=$(( (total_seconds % 3600) / 60 ))
    local seconds=$(( total_seconds % 60 ))
    local formatted=""

    if (( days > 0 )); then
        formatted+="${days}d "
    fi
    if (( hours > 0 )); then
        formatted+="${hours}h "
    fi
    if (( minutes > 0 )); then
        formatted+="${minutes}m "
    fi
    formatted+="${seconds}s"

    echo "$formatted"
}

# ===================================[ Crash handle ]=================================== #

# Loading log library
logging_library="$mcsm_dir/source/library/logging.sh"
log_dir="$mcsm_dir/logs"
source "$logging_library"

while [[ "$exit_while" == false ]]; do
    # Loading log file
    current_date=$(date '+%Y-%m-%d')
    LOG_FILE="$log_dir/mcsm_$current_date.log"

    # Starting Minecraft
    log_tmux_info "Running $server_run_file"
    start_ts=$(date +%s)
    source $server_run_file
    echo "Server closed"
    end_ts=$(date +%s)

    # Reloading log time
    current_date=$(date '+%Y-%m-%d')
    LOG_FILE="$log_dir/mcsm_$current_date.log"

    # Calculate uptime
    runtime=$(( end_ts - start_ts ))
    human_runtime=$(human_readable_runtime "$runtime")
    log_tmux_info "Server process has exited. Runtime: ${human_runtime}"

    sleep 1

    # Crash handling
    if [[ "$crash_handle" == "false" ]]; then
        log_tmux_info "Crash handle disabled. Exit from tmux session"
        exit_while="true"
        continue
    fi

    # Received stop command
    if [[ -f "$restart_temp_file" ]]; then
        log_tmux_warn "Server has crashed. Restarting..."
    else
        exit_while=true
    fi

    # Infinite loop protection (if it crashes in <2 minutes)
    if (( runtime < 120 )); then
        ((crash_handle_timeout++))
        log_tmux_warn "Server has crashed $crash_handle_timeout times in under 2 minutes"
    else
        crash_handle_timeout=0
    fi

    # Exit from infinite loop
    if (( crash_handle_timeout >= crash_retry )); then
        log_tmux_error "The server crashes too frequently"
        log_tmux_info "Infinite loop protection activated. Exit from tmux session"
        exit_while=true
    fi
done