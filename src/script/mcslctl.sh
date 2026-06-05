#!/usr/bin/env bash

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
    printf -- "%s\n" "Server closed"

    # End timestamp
    ets=$(date +%s)
    
    # Calculate uptime timestamp
    uts=$(( ets - sts ))
    huts=$(format_duration "$uts")
    log_info "Minecraft server stopped after $huts"

    # Little delay before restart
    sleep 5

    # Crash handling
    if [[ "${CrashHandle,,}" == "false" ]]; then
        log_info "Crash handle disabled. Exit from tmux session"
        ctlstate="stop"; continue
    fi

    # Received stop command
    if [[ -f "$ctlrestart" ]]; then
        log_error "Minecraft server crashed. restarting"
    else
        ctlstate="stop"; continue
    fi

    # Infinite loop protection
    if (( uts < RetryDelay )); then
        (( ctlcrash++ ))
        log_warn "Server crashed $ctlcrash times under $(format_duration "$RetryDelay")"
    fi

    # Exit from infinite loop
    if (( ctlcrash >= CrashRetry )); then
        log_error "the
    fi
done