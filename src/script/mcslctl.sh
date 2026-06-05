#!/usr/bin/env bash

# File: mcslctl.sh
# Description: mcslctl mcsl controller for minecraft server
# Usage: . ./mcslctl.sh
# Author: NoveIX
# Created: 2026-05-29
# Last Updated: 2026-06-06
# Version: 1.0.0
# Requires: logger.sh
# SPDX-License-Identifier: GPL-3.0-or-later

# ===============================[ Parameter ]================================ #

mcsl_dir="$1"
config_dir="$mcsl_dir/cfg"
runtime_dir="$mcsl_dir/src/runtime"
core_dir="$mcsl_dir/src/lib/core"
log_dir="$mcsl_dir/logs"

# mcslctl state
ctlstate="run"
ctlcrash=0
ctlrestart="$runtime_dir/mcslctl.restart"

# Load loader module
if [ -f "$core_dir/loader.sh" ]; then
    source "$core_dir/loader.sh"
else
    printf -- "fatal: module loader.sh not found. required to execute script %s.\n" "$(basename "$0")" >&2
    exit 1
fi

# Load required module
load_module "$core_dir/logger.sh"
load_module "$core_dir/config.sh"
load_module "$core_dir/common.sh"

# Generate log setting behavior
log_setting "$log_dir/mcslctl" "info" "print"

# Read mcsl config behavior
log_info "Read mcsl config"
read_config "$config_dir/mcsl-behavior.ini"

# Change dir to minecraft server
cd "$mcsl_dir/.."

# ==============================[ mcslctl core ]============================== #

while [[ ${ctlstate,,} != "stop" ]]; do
    # Start timestamp
    sts=$(date +%s)

    # Start minecraft server
    if [[ -f "$StartCommand" ]]; then
        bash "$StartCommand"
    else
        bash -c "$StartCommand"
    fi

    # End timestamp
    ets=$(date +%s)

    # Calculate uptime timestamp
    uts=$(( ets - sts ))
    log_info "Minecraft server stopped after $(format_duration "$uts")"

    # Little delay before restart
    sleep 5

    # Check crash handling setting
    if [[ "${CrashHandle,,}" == "false" ]]; then
        log_info "Crash handling disabled. Exiting from tmux session"
        ctlstate="stop"; continue
    fi

    # Stop requested
    if [[ ! -f "$ctlrestart" ]]; then
        ctlstate="stop"; continue
    fi

    # Server crashed
    (( ctlcrash++ ))
    log_error "Minecraft server crashed. Restarting"

    # Infinite restart loop protection
    if (( uts < RetryDelay )); then
        log_warn "Server crashed before running for $(format_duration "$RetryDelay")"
    fi

    # Check crash count
    if (( ctlcrash >= CrashRetry )); then
        log_error "Server exceeded the maximum number of crash retries"
        ctlstate="stop"; continue
    fi
done
