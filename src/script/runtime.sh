#!/usr/bin/env bash

# File: runtime.sh
# Description: mcsl runtime controller for Minecraft server
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

# ===============================[ Parameter ]================================ #

# Define the directory of the script and its name
readonly mcsl_dir="$1"
readonly log_mode="$2"
readonly mcsl_name="$(basename -- "${BASH_SOURCE[0]}")"

# Source directories
readonly cfg_dir="$mcsl_dir/cfg"
readonly logs_dir="$mcsl_dir/logs"
readonly core_dir="$mcsl_dir/src/lib/core"

# Runtime directory and control files
readonly runtime_dir="$mcsl_dir/.runtime"
readonly mcslctl="$runtime_dir/mcslctl"
readonly crashctl="$runtime_dir/crashctl"
readonly uptimectl="$runtime_dir/uptimectl"
readonly restartctl="$runtime_dir/restartctl"

# Runtime state variables
runtime_status="run"
crash_count=0

# ==============================[ Import module ]============================= #

# Check if loader module exists
if [[ ! -f "$core_dir/loader.sh" ]]; then
    printf 'fatal: module loader.sh not found. required to execute script %s.\n' "$mcsl_name" >&2
    read -r -n1 -t 30 -p "Press any key to exit..."; exit 1
fi

# Load loader module
source "$core_dir/loader.sh"

# Load required module
load_module "$core_dir/logger.sh" || exit 1
load_module "$core_dir/parameter.sh" || exit 1
load_module "$core_dir/config.sh" || exit 1
load_module "$core_dir/common.sh" || exit 1
load_module "$core_dir/notifier.sh" || exit 1

# ===========================[ runtime bootstrap ]============================ #

# Generate log setting
log_setting "$logs_dir/runtime" "info" "print" "$log_mode"

# Read mcsl runtime config
read_config_runtime "$cfg_dir/runtime.conf" || exit 1
read_config_notify "$cfg_dir/notify.conf" || true

# Change dir to Minecraft server
cd "$mcsl_dir/.."
log_info "changing working directory to the Minecraft server root"

# Start mcsl runtime process
printf 'Minecraft Server Launcher Runtime Up\n' > "$mcslctl"
log_info "starting mcsl runtime core"

# ==============================[ runtime core ]============================== #

while [[ "${runtime_status,,}" != "stop" ]]; do
    # Start timestamp
    sts=$(date +%s)
    log_debug "server start timestamp registered: $sts"
    printf "%s\n" "$sts" > "$uptimectl"

    # Notify on discord telegram
    runtime_notification "start"

    # set return code for server start command
    rc=0

    # Remove crash control file
    rm -f "$crashctl"

    # Start Minecraft server
    if [[ -f "$START_COMMAND" ]]; then
        log_info "starting Minecraft server using configured script: $START_COMMAND"
        bash "$START_COMMAND" || rc=$?
    else
        log_info "starting Minecraft server using configured command: $START_COMMAND"
        bash -c "$START_COMMAND" || rc=$?
    fi

    # Log Minecraft server error
    if (( rc != 0 )); then
        log_error "Minecraft server start failed (cmd: $START_COMMAND, exit code: $rc)"
        read -r -n1 -t 30 -p "Press any key to continue..."
    fi

    # End timestamp
    ets=$(date +%s)
    log_debug "server end timestamp registered: $ets"

    # Calculate uptime timestamp
    uts=$(( ets - sts ))
    log_info "Minecraft server uptime: $(format_duration "$uts")"
    rm -f "$uptimectl"

    # Stop requested
    if [[ ! -f "$restartctl" ]]; then
        runtime_notification "stop"
        runtime_status="stop"; continue
    fi

    # Check crash handling setting
    if [[ "${CRASH_HANDLE,,}" == "false" ]]; then
        log_info "crash handling disabled. Server will not restart"
        runtime_notification "handle"
        runtime_status="stop"; continue
    fi

    # Create crash control file
    printf 'Minecraft Server Launcher Runtime Crash Detected\n' > "$crashctl"

    # Server crashed
    (( crash_count++ )) || true
    log_warn "Minecraft server crashed. Restarting (attempt $crash_count)"
    runtime_notification "crash"

    # Check crash retry limit
    if (( MAX_RESTART >= 0 && crash_count >= MAX_RESTART )); then
        log_warn "crash limit reached (Max $MAX_RESTART). Server will not restart"
        runtime_notification "loop"
        runtime_status="stop"; continue
    fi

    # Little delay before restart to prevent cpu saturation in case of instant crash loop
    sleep 5
done

# Stop mcsl runtime process
log_info "shutting down mcsl runtime core"
rm -r "$mcslctl"

# sleep to read logs before tmux close
sleep 10
