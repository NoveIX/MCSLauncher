#!/usr/bin/env bash

# File: mcslctl.sh
# Description: mcsl controller for minecraft server
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

# ===============================[ Parameter ]================================ #

mcsl_dir="$1"
config_dir="$mcsl_dir/cfg"
runtime_dir="$mcsl_dir/src/runtime"
core_dir="$mcsl_dir/src/lib/core"
log_dir="$mcsl_dir/logs"

# mcslctl state
statectl="run"
crashctl=0
restartctl="$runtime_dir/restartctl"

# Load loader module
if [ -f "$core_dir/loader.sh" ]; then
    source "$core_dir/loader.sh"
else
    printf -- "fatal: module loader.sh not found. required to execute script %s.\n" "$(basename "$0")" >&2
    read -r -n1 -t 30 -p "Press any key to exit..."
    exit 1
fi

# Load required module
load_module "$core_dir/logger.sh"
load_module "$core_dir/config.sh"
load_module "$core_dir/common.sh"

# Generate log setting behavior
log_setting "$log_dir/mcslctl" "info" "print"

# Read mcsl config behavior
log_info "read mcsl config"
read_config "$config_dir/mcsl-behavior.ini" || exit 1

# Change dir to minecraft server
cd "$mcsl_dir/.."
log_info "changing working directory to the Minecraft server root"

# ==============================[ mcslctl core ]============================== #

while [[ ${statectl,,} != "stop" ]]; do
    # Start timestamp
    sts=$(date +%s)
    log_info "start timestamp set to $sts"

    # Start minecraft server
    if [[ -f "$StartCommand" ]]; then
        log_info "starting Minecraft server using script: $StartCommand"
        bash "$StartCommand"
    else
        log_info "starting Minecraft server using configured command"
        bash -c "$StartCommand"
    fi

    # End timestamp
    ets=$(date +%s)
    log_info "end timestamp set to $sts"

    # Calculate uptime timestamp
    uts=$(( ets - sts ))
    log_info "minecraft server stopped after $(format_duration "$uts")"

    # Little delay before restart
    sleep 5

    # Check crash handling setting
    if [[ "${CrashHandle,,}" == "false" ]]; then
        log_info "crash handling disabled. Exiting from tmux session"
        statectl="stop"; continue
    fi

    # Stop requested
    if [[ ! -f "$restartctl" ]]; then
        statectl="stop"; continue
    fi

    # Server crashed
    (( crashctl++ ))
    log_error "minecraft server crashed. Restarting"

    # Check crash retry limit
    if (( MaxRestart > 0 && crashctl >= MaxRestart )); then
        log_error "crash limit reached (crash=$crashctl, max=$MaxRestart). Stopping server"
        statectl="stop"; continue
    fi
done

# sleep to ready logs before tmux session is closed
sleep 5
