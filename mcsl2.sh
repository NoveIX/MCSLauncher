#!/usr/bin/env bash

# set -euo pipefail

# Path
mcsl_path="$(realpath "$0")"
mcsl_name="$(basename "$mcsl_path")"
mcsl_dir="$(dirname "$mcsl_path")"
log_dir="$mcsl_dir/logs"
core_dir="$mcsl_dir/src/lib/core"
commands_dir="$mcsl_dir/src/lib/commands"

# tmux parameter
session_name="$(basename "$server_root" | tr -d '[:space:]' | tr -c '[:alnum:]_.-' '_')"

# Server root
server_root="$(dirname "$mcsl_dir")"

# ==============================[ Import module ]============================= #


# Load loader module
if [ -f "$core_dir/loader.sh" ]; then
    source "$core_dir/loader.sh"
else
    printf -- "%s.\n" "fatal: module loader.sh not found. required to execute script " >&2
    exit 1
fi

# Load required module
load_module "$core_dir/logger.sh"

# Generate log setting behavior
log_setting "$log_dir/mcsl" "info" "print"

# ================================[ Function ]================================ #

main() {
    local cmd="$1"
    shift || true

    local session=""
    local time=""
    local console=false

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --session|-s)
                session="${2:-$session_name}"
                shift 2
            ;;
            --time|-t)
                time="${2:-0}"
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
    
    case "${cmd,,}" in
        # Start command. Starts the server.
        start)
            load_module "$commands_dir/start.sh"
            start_server "$session" $console
        ;;
        
        # Stop command. Stops the server with an optional delay before stopping.
        stop)
            load_module "$commands_dir/stop.sh"
            stop_server "$session" "$time" $console
        ;;
        
        # Restart command. Stops and then starts the server with a optional delay before stopping.
        restart)
            load_module "$commands_dir/restart.sh"
            restart_server "$session" "$time" $console
        ;;
        
        # Console command. Attaches to the tmux session of the server.
        console)
            load_module "$commands_dir/console.sh"
            tmux_attach "$session_name"
        ;;
        
        # Status command. Prints the status of the server.
        status)
            load_module "$commands_dir/status.sh"
            status_server "$session_name"
        ;;
        
        # Version command. Prints the version of mcsl.
        version)
            load_module "$commands_dir/version.sh"
            print_version
        ;;
        
        # Help command. Prints the help message for mcsl.
        help)
            load_module "$commands_dir/help.sh"
            print_help
        ;;
        
        # Default case. Prints the help message for mcsl.
        *)
            load_module "$commands_dir/help.sh"
            print_help
        ;;
    esac
}

main $@
