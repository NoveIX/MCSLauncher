#!/usr/bin/env bash

# File: backup.sh
# Description: mcsl backup controller for Minecraft server
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

#set -euo pipefail

# ===============================[ Parameter ]================================ #

# Define the directory of the script and its name
readonly mcsl_dir="$1"
readonly session_name="$2"
readonly log_mode="$3"
readonly mcsl_name="$(basename -- "${BASH_SOURCE[0]}")"
readonly server_root="$(dirname "$mcsl_dir")"

# Source directories
readonly cfg_dir="$mcsl_dir/cfg"
readonly logs_dir="$mcsl_dir/logs"
readonly core_dir="$mcsl_dir/src/lib/core"

# Runtime directory and control files
readonly runtime_dir="$mcsl_dir/.runtime"
readonly mcslctl="$runtime_dir/mcslctl"
readonly crashctl="$runtime_dir/crashctl"

# Backup configuration variables
readonly backup_dir="$server_root/backups"

# Runtime state variables
runtime_status="run"

# ==============================[ Import module ]============================= #

# Check if loader module exists
if [[ ! -f "$core_dir/loader.sh" ]]; then
    printf 'fatal: module loader.sh not found. required to execute script %s.\n' "$mcsl_name" >&2
    read -r -n1 -t 30 -p "Press any key to exit..."
    exit 1
fi

# Load loader module
source "$core_dir/loader.sh"

# Load required module
load_module "$core_dir/logger.sh" || exit 1
load_module "$core_dir/parameter.sh" || exit 1
load_module "$core_dir/config.sh" || exit 1
load_module "$core_dir/server.sh" || exit 1
load_module "$core_dir/tmux.sh" || exit 1
load_module "$core_dir/filesystem.sh" || exit 1

# ============================[ backup bootstrap ]============================ #

# Generate log setting
log_setting "$logs_dir/backup" "info" "print" "$log_mode"

# Read mcsl backup config
read_config_backup "$cfg_dir/backup.conf" || exit 1

# Change dir to Minecraft server
cd "$mcsl_dir/.."
log_info "changing working directory to the Minecraft server root"

# Read world directory from server.properties
log_info "read world directory from server.properties"
world_dir=$(get_property "$server_root/server.properties" "level-name" ) || true

# Start backup process
log_info "starting mcsl backup core at $(date "+%F %T")"

# ==============================[ backup core ]=============================== #

sts=$(date +%s)

# Wait for mcslctl to be available
while [[ ! -f "$mcslctl" ]]; do
    now=$(date +%s)
    if (( now - sts >= 120 )); then
        log_fatal "timeout waiting for $mcslctl"
        runtime_status="stop"; break
    fi

    sleep 1
done

# Backup loop
while [[ "${runtime_status,,}" != "stop" ]]; do

    # Ensure directory
    [[ -d "$backup_dir" ]] || mkdir -p "$backup_dir"

    # Convert minutes in seconds
    delay=$((BACKUP_DELAY * 60))
    elapsed=0

    # Sleep loop with check every second
    while [[ $elapsed -lt $delay ]]; do
        # Check if mcslctl exists
        if [[ ! -f "$mcslctl" ]]; then
            log_info "mcsl runtime control file not found. stopping backup process"
            runtime_status="stop"; break
        fi

        # Check if crashctl exists
        if [[ -f "$crashctl" ]]; then
            log_info "crash detected. Skipping current backup"
            continue 2
        fi

        ((elapsed++)) || true
        sleep 1
    done

    # Performs the last backup before shutting down
    [[ "${runtime_status,,}" == "stop" ]] && sleep 10

    if [[ ! -d "$world_dir" ]]; then
        log_error "world directory not found: $world_dir" "print"
    fi

    # Backup execution
    ts=$(date +%Y-%m-%d-%H-%M-%S)

    send_tmux "$session_name" "save-all flush"
    wait_pattern "$server_root/logs/latest.log" "Saved the game"

    zip -r "$backup_dir/${ts}.zip" "$world_dir"
done

# Stop mcsl backup process
log_info "shutting down mcsl backup core at $(date "+%F %T")"

# sleep to read logs before tmux close
sleep 10
