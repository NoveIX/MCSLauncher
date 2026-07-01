#!/usr/bin/env bash

# File: mcsl-backup.sh
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
readonly runtime_dir="$mcsl_dir/runtime"
readonly mcslctl="$runtime_dir/mcslctl"

# Backup configuration variables
readonly backup_dir="$server_root/backups"

# Runtime state variables
statectl="run"

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

# Generate log setting
log_setting "$logs_dir/mcsl-backup" "info" "print" "$log_mode"

# Read mcsl backup config
log_info "read mcsl backup config"
read_config_backup "$cfg_dir/mcsl-backup.conf" || exit 1

# Read world directory from server.properties
log_info "read world directory from server.properties"
world_dir=$(get_property "$server_root/server.properties" "level-name" ) || true

# Change dir to Minecraft server
cd "$server_root"
log_info "changing working directory to the Minecraft server root"

# ============================[ mcsl backup core ]============================ #

start_time=$(date +%s)

while [[ ! -f "$mcslctl" ]]; do
    now=$(date +%s)
    if (( now - start_time >= 60 )); then
        log_fatal "timeout waiting for $mcslctl"
        statectl="stop"
        break
    fi

    sleep 1
done

while [[ "${statectl,,}" != "stop" ]]; do

    # Ensure directory
    if ! mkdir -p "$backup_dir"; then
        log_error "failed to create directory: $backup_dir" "print"
        statectl="stop"
        continue
    fi

    sleep 60
    ts=$(date +%Y-%m-%d-%H-%M-%S)
    send_tmux "${session_name}:0" "save-all flush"
    wait_save "$server_root/logs/latest.log" "Saved the game"
    zip -r "$backup_dir/${ts}.zip" "$world_dir"
    #sleep $BACKUP_DELAY

    if [[ ! -f "$mcslctl" ]]; then
        statectl="stop"
        continue
    fi
done

# sleep to read logs before tmux session is closed
sleep 5
