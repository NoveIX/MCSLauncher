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
readonly log_dir="$mcsl_dir/logs"
readonly cfg_dir="$mcsl_dir/cfg"
readonly data_dir="$mcsl_dir/src/data"
readonly core_dir="$mcsl_dir/src/lib/core"
readonly commands_dir="$mcsl_dir/src/lib/commands"
readonly runtime_dir="$mcsl_dir/src/runtime"
readonly mcslctl="$mcsl_dir/src/script/mcslctl.sh"
readonly uptimectl="$runtime_dir/uptimectl"
readonly restartctl="$runtime_dir/restartctl"

# Data
readonly version_file="$data_dir/version"

# Server root
readonly server_root="$(dirname "$mcsl_dir")"
readonly server_container="$(dirname "$server_root")"

# tmux parameter
session_name="$(basename "$server_root" | tr -d '[[:space:]]' | tr -c '[[:alnum:]]_.-' '_')"
session_name="${session_name:0:16}"
readonly session_name

# ==============================[ Import module ]============================= #

# Check if loader module exists
if [[ ! -f "$core_dir/loader.sh" ]]; then
    printf 'fatal: module loader.sh not found. required to execute script %s.\n' "$mcsl_name"
    exit 1
fi

# Load loader module
source "$core_dir/loader.sh"

# Load required module
load_module "$core_dir/logger.sh"
load_module "$core_dir/parameter.sh"

# Generate log setting behavior
log_setting "$log_dir/mcsl" "info" "" "combined"

# ================================[ Function ]================================ #

main() {
    local cmd="${1:-}"

    # Validate command parameter
    if [[ -z "$cmd" ]]; then
        log_error "missing command. Use $0 -h to display the available commands." "print"
        return 1
    fi

    # If the command is help, print help immediately and skip flag parsing.
    if [[ "${cmd,,}" =~ ^(help|--help|-h)$ ]]; then
        load_module "$commands_dir/help.sh"
        print_help
        return 0
    fi

    # If the command is version, print version immediately and skip flag parsing.
    if [[ "${cmd,,}" =~ ^(version|--version|-v)$ ]]; then
        load_module "$commands_dir/version.sh"
        print_version
        return 0
    fi

    # Shift the command parameter to parse flags
    shift || true

    # Initialize variables for flags
    local session time console host port dest user key all confirm

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --session|-s)
                session="${2:-}"
                require_param "session" "$session" "mcsl.sh" || return 1
                validate_flags "session" "${3:-}" || return 1
                shift 2
            ;;

            --time|-t)
                time="${2:-}"
                require_param "time" "$time" "mcsl.sh" || return 1
                validate_flags "time" "${3:-}" || return 1
                shift 2
            ;;

            --console|-c)
                console="true"
                validate_flags "console" "${2:-}" || return 1
                shift
            ;;

            --host|-h)
                host="${2:-}"
                require_param "host" "$host" "mcsl.sh" || return 1
                validate_flags "host" "${3:-}" || return 1
                shift 2
            ;;

            --port|-p)
                port="${2:-}"
                require_param "port" "$port" "mcsl.sh" || return 1
                validate_flags "port" "${3:-}" || return 1
                shift 2
            ;;

            --dest|-d)
                dest="${2:-}"
                require_param "dest" "$dest" "mcsl.sh" || return 1
                validate_flags "dest" "${3:-}" || return 1
                shift 2
            ;;

            --user|-u)
                user="${2:-}"
                require_param "user" "$user" "mcsl.sh" || return 1
                validate_flags "user" "${3:-}" || return 1
                shift 2
            ;;

            --key|-k)
                key="${2:-}"
                require_param "key" "$key" "mcsl.sh" || return 1
                validate_flags "key" "${3:-}" || return 1
                shift 2
            ;;

            --all|-a)
                all="true"
                validate_flags "all" "${2:-}" || return 1
                shift
            ;;

            --confirm-action)
                confirm="true"
                validate_flags "confirm" "${2:-}" || return 1
                shift
            ;;

            *)
                log_error "unknown argument: $1" "print"
                return 1
            ;;
        esac
    done

    # Set default values for optional parameters
    session=${session:-$session_name}
    time=${time:-0}
    console=${console:-false}
    host=${host:-}
    port=${port:-}
    dest=${dest:-}
    user=${user:-}
    key=${key:-}
    all=${all:-false}
    confirm=${confirm:-false}

    # Validate parameter
    validate_param session "$session" || return 1
    validate_param time "$time" || return 1
    validate_param host "$host" || return 1
    validate_param port "$port" || return 1
    validate_param dest "$dest" || return 1
    validate_param user "$user" || return 1
    validate_param key "$key" || return 1

    case "${cmd,,}" in
        # Start command. Starts the server.
        start)
            load_module "$commands_dir/start.sh"
            start_server "$session" "$console" "$all"
        ;;

        # Stop command. Stops the server with an optional delay before stopping.
        stop)
            load_module "$commands_dir/stop.sh"
            stop_server "$session" "$time" "shutdown" "$all"
        ;;

        # Restart command. Stops and then starts the server with a optional delay before stopping.
        restart)
            load_module "$commands_dir/restart.sh"
            restart_server "$session" "$time" "$console" "$all"
        ;;

        # Console command. Attaches to the tmux session of the server.
        console|--console|-c)
            load_module "$core_dir/tmux.sh"
            attach_tmux "$session"
        ;;

        # Status command. Prints the status of the server.
        status)
            load_module "$commands_dir/status.sh"
            status_server "$session" "${host:-localhost}" "${port:-25565}" "$all"
        ;;

        # Migration command. Migrates the server to another location or host.
        migrate)
            load_module "$commands_dir/migrate.sh"
            migrate_server "$dest" "$host" "$user" "$key" "$port" "$time"
        ;;

        # Kill command. Kill the tmux session of the server immediately without a graceful shutdown.
        # Use with caution as it may cause data loss or corruption.
        # This command does not support remote delegation and will only kill the session on the local machine.
        kill)
            load_module "$commands_dir/kill.sh"
            kill_server "$session" "$confirm"
        ;;

        # SelfUpdate command. Updates the mcsl script itself.
        selfupdate)
            load_module "$commands_dir/selfupdate.sh"
            selfupdate "$session" "$all"
        ;;

        # Default case. Prints the help message for mcsl.
        *)
            log_error "unknown command: $cmd" "print"
        ;;
    esac
}

# ==================================[ Main ]================================== #

main $@
