#!/usr/bin/env bash

# File: mcsl.sh
# Description: Minecraft Server Launcher
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

# ===============================[ Parameter ]================================ #

# Path and name variables
readonly mcsl_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly mcsl_name="$(basename -- "${BASH_SOURCE[0]}")"
readonly core_dir="$mcsl_dir/src/lib/core"
readonly commands_dir="$mcsl_dir/src/lib/commands"
readonly mcslctl="$mcsl_dir/src/script/mcslctl.sh"

# Data
readonly version_file="$mcsl_dir/version"

# Server root
readonly server_root="$(dirname "$mcsl_dir")"

# tmux parameter
session_name="$(basename "$server_root" | tr -d '[:space:]' | tr -c '[:alnum:]_.-' '_')"
session_name="${session_name:0:32}"
readonly session_name

# ==============================[ Import module ]============================= #


# Load loader module
if [ -f "$core_dir/loader.sh" ]; then
    source "$core_dir/loader.sh"
else
    printf -- "%s.\n" "fatal: module loader.sh not found. required to execute script $mcsl_name" >&2
    exit 1
fi

# Load required module
load_module "$core_dir/logger.sh"

# Generate log setting behavior
log_setting "" "info" "print"

# ================================[ Function ]================================ #

main() {
    local cmd="${1:-}"
    shift || true

    local session=""
    local time=""
    local console=false

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --session|-s)
                session="$2"
                shift 2
            ;;
            --time|-t)
                time="$2"
                shift 2
            ;;
            --console|-c)
                console=true
                shift
            ;;
            *)
                log_error "Unknown argument: $1"
                return 1
            ;;
        esac
    done

    # Validate command parameter
    if [[ -z "${cmd:-}" ]]; then
        log_error "Missing command. Use '$0 -h' to display the available commands."
        return 1
    fi

    # Set default values for optional parameters
    session=${session:-$session_name}
    time=${time:-0}
    
    case "${cmd,,}" in
        # Start command. Starts the server.
        start)
            load_module "$commands_dir/start.sh"
            start_server "$session" $console
        ;;
        
        # Stop command. Stops the server with an optional delay before stopping.
        stop)
            load_module "$commands_dir/stop.sh"
            stop_server "$session" "$time" "shutdown"
        ;;
        
        # Restart command. Stops and then starts the server with a optional delay before stopping.
        restart)
            load_module "$commands_dir/restart.sh"
            restart_server "$session" "$time" $console
        ;;
        
        # Console command. Attaches to the tmux session of the server.
        console|--console|-c)
            load_module "$core_dir/tmux.sh"
            tmux_attach "$session"
        ;;
        
        # Status command. Prints the status of the server.
        status)
            load_module "$commands_dir/status.sh"
            status_server "$session"
        ;;
        
        # Version command. Prints the version of mcsl.
        version|--version|-v)
            load_module "$commands_dir/version.sh"
            print_version
        ;;
        
        # Help command. Prints the help message for mcsl.
        help|--help|-h)
            load_module "$commands_dir/help.sh"
            print_help
        ;;
        
        # Default case. Prints the help message for mcsl.
        *)
            log_error "unknown command: $cmd"
        ;;
    esac
}

# ==================================[ Main ]================================== #

main $@