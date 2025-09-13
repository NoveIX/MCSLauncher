#!/usr/bin/env bash

# File: mcslctl.sh
# Description: mcsl controller for Minecraft server
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

# ===============================[ Parameter ]================================ #

readonly mcsl_dir="$1"
readonly log_mode="$2"
readonly mcslctl_name="$(basename -- "${BASH_SOURCE[0]}")"
readonly cfg_dir="$mcsl_dir/cfg"
readonly log_dir="$mcsl_dir/logs"
readonly core_dir="$mcsl_dir/src/lib/core"
readonly runtime_dir="$mcsl_dir/src/runtime"
readonly uptimectl="$runtime_dir/uptimectl"
readonly restartctl="$runtime_dir/restartctl"

# mcslctl state
statectl="run"
crashctl=0

# Check if loader module exists
if [[ ! -f "$core_dir/loader.sh" ]]; then
    printf 'fatal: module loader.sh not found. required to execute script %s.\n' "$mcslctl_name" >&2
    read -r -n1 -t 30 -p "Press any key to exit..."
    exit 1
fi

# Load loader module
source "$core_dir/loader.sh"

# Load required module
load_module "$core_dir/logger.sh" || exit 1
load_module "$core_dir/parameter.sh" || exit 1
load_module "$core_dir/config.sh" || exit 1
load_module "$core_dir/common.sh" || exit 1

# Generate log setting behavior
log_setting "$log_dir/mcslctl" "info" "print" "$log_mode"

# Read mcslctl config behavior
log_info "read mcslctl config"
read_config "$cfg_dir/mcslctl.conf" || exit 1

# Change dir to Minecraft server
cd "$mcsl_dir/.."
log_info "changing working directory to the Minecraft server root"

# ==============================[ mcslctl core ]============================== #

while [[ ${statectl,,} != "stop" ]]; do
    # Start timestamp
    sts=$(date +%s)
    log_debug "server start timestamp registered: $sts"
    printf "%s\n" "$sts" > "$uptimectl"

    # set return code for server start command
    rc=0

    # Start Minecraft server
    if [[ -f "$StartCommand" ]]; then
        log_info "starting Minecraft server using script: $StartCommand"
        bash "$StartCommand" || rc=$?
    else
        log_info "starting Minecraft server using configured command: $StartCommand"
        bash -c "$StartCommand" || rc=$?
    fi

    # Log Minecraft server error
    if (( rc != 0 )); then
        log_error "Minecraft server start failed (cmd: $StartCommand, exit code: $rc)"
    fi

    # End timestamp
    ets=$(date +%s)
    log_debug "server end timestamp registered: $ets"

    # Calculate uptime timestamp
    uts=$(( ets - sts ))
    log_info "Minecraft server uptime: $(format_duration "$uts")"
    rm -f "$uptimectl"

    # Check crash handling setting
    if [[ "${CrashHandle,,}" == "false" ]]; then
        log_info "crash handling disabled. Exiting from tmux session"
        statectl="stop"
        continue
    fi

    # Stop requested
    if [[ ! -f "$restartctl" ]]; then
        statectl="stop"
        continue
    fi

    # Server crashed
    (( crashctl++ )) || true
    log_warn "Minecraft server crashed. Restarting (attempt $crashctl)"

    # Check crash retry limit
    if (( MaxRestart >= 0 && crashctl >= MaxRestart )); then
        log_warn "crash limit reached (crash=$crashctl, max=$MaxRestart). Stopping server"
        statectl="stop"
        continue
    fi

    # Little delay before restart to prevent cpu saturation in case of instant crash loop
    sleep 5
done

# sleep to read logs before tmux session is closed
sleep 5
