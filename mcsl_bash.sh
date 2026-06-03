#!/usr/bin/env bash

version_file="$(dirname "$0")/version"
mcslver=$(<"$version_file")
mcslver="${mcslver//[$'\t\r\n ']}"

# ---
# Script Name:          mcsl.sh - Minecraft Server Launcher
# Description:          Runtime bash script for managing Minecraft servers.
#                       Provides start, stop, restart, and console access functionalities.
#                       Uses tmux for process management to keep the server running.
#
# Usage:                mcsl.sh [options]
#
# Options:
#   -s, --start         Start the server.
#   -e, --exit          Stop the server with a in-game warning seconds before shutdown.
#   -r, --restart       Restart the server gracefully with an in-game warning.
#   -c, --console       Attach to the server console (tmux session).
#   -n, --now           Stop or restart the server immediately without warning.
#   -h, --help          Display this help information.
#   --selfupdate        Update MCSL from the official Git repository.
#   --version           Show the currently installed MCSL version.
#
# Examples:
#   ./mcsl.sh -c        Connect to tmux console
#   ./mcsl.sh -r        Restart Minecraft server after 30 second and warn player
#   ./mcsl.sh -rn       Restart Minecraft server in-game warning
#   ./mcsl.sh -snc      Launch Minecraft server in-game warning and connect to tmux
#   ./mcsl.sh --stop    Shutdown Minecraft server after 30 second and warn player
#   ./mcsl.sh --start   Start Minecraft server
#
# Features:
#   - Start, stop, and restart the server (graceful or immediate)
#   - Access server console
#   - Update MCSM from official repository
#   - Logs management and configuration parsing
#
# Notes:
#   - Requires Bash 4.4+ for associative arrays
#   - Requires tmux for encapsulation of the Java process
#   - Tested on Ubuntu 24.04 and Debian 13
#   - Make sure you have write permission in the output directory
#
# More info:
#   - GitHub:           https://github.com/NoveIX/mcsm
#
# License:              GPL v3
# Author:               NoveIX
# Version:              $version
# Date:                 2025-10-15
# ---

# =====================================[ Function ]===================================== #

show_full_help() {
    sed -n '/^# ---$/,/^# ---$/p' "$0" |
    sed '/^# ---$/d; s/^# \{0,1\}//' |
    while IFS= read -r line; do
        printf '%s\n' "${line//\$version/$mcslver}"
    done
}

show_help() {
    cat << EOF
Usage: $0 [options]

Available Options:
  -s, --start         Launch the server.
  -e, --exit          Stop the server gracefully with an in-game warning.
  -r, --restart       Restart the server gracefully with an in-game warning.
  -c, --console       Attach to the server console (tmux session).
  -n, --now           Stop or restart the server immediately without warning.
  -h, --help          Display this help information.
  --mcsm-update       Update MCSM from the official Git repository.
  --version           Show the currently installed MCSM version.
EOF
}

show_version() {
    echo "Minecraft Server Manager (MCSM)"
    echo "Version: $VERSION"
}

# ================================[ Control variables ]================================= #

START=false
EXIT=false
RESTART=false
CONSOLE=false
NOW=false
MCSMUPDATE=false

# =================================[ Parsing options ]================================== #

if [[ -z "$1" ]]; then
    show_full_help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    arg="$1"
    case "$arg" in
        -s|--start) START=true; shift ;;
        -e|--exit) EXIT=true; shift ;;
        -r|--restart) RESTART=true; shift ;;
        -c|--console) CONSOLE=true; shift ;;
        -n|--now) NOW=true; shift ;;
        --mcsm-update) MCSMUPDATE=true; shift ;;
        --version) show_version; exit 0 ;;
        -h|--help) show_help; exit 0 ;;
        -*)
            # gestione combinazioni tipo -rn
            opts="${arg:1}"
            for (( i=0; i<${#opts}; i++ )); do
                o="${opts:$i:1}"
                case "$o" in
                    s) START=true ;;
                    e) EXIT=true ;;
                    r) RESTART=true ;;
                    c) CONSOLE=true ;;
                    n) NOW=true ;;
                    h) show_help; exit 0 ;;
                    *) echo -e "ERROR: unknown option -$o\n"; show_help; exit 1 ;;
                esac
            done
            shift
        ;;
        *)
        echo -e "ERROR: unknown argument: $arg\n"; show_help; exit 1;;
    esac
done

# =================================[ Global parameter ]================================= #

# Self defined parameter
CURRENT_DATE=$(date '+%Y-%m-%d')                        # today
SCRIPT_ROOT=$(dirname "$(realpath "$0")")               # $HOME/modpack/mcsm

# Path
MODPACK_DIR=$(dirname "$SCRIPT_ROOT")                   # $HOME/modpack
MCSM_DIR="$SCRIPT_ROOT"                                 # $HOME/modpack/mcsm
LOG_DIR="$MCSM_DIR/logs"                                # $HOME/modpack/mcsm/logs
CONFIG_DIR="$MCSM_DIR/config"                           # $HOME/modpack/mcsm/config
SOURCE_DIR="$MCSM_DIR/source"                           # $HOME/modpack/mcsm/source
LIBRARY_DIR="$SOURCE_DIR/library"                       # $HOME/modpack/mcsm/source/library
SCRIPT_DIR="$SOURCE_DIR/script"                         # $HOME/modpack/mcsm/source/script
KEY_DIR="$MCSM_DIR/key"                                 # $HOME/modpack/mcsm/key
TEMP_DIR="$MCSM_DIR/temp"                               # $HOME/modpack/mcsm/temp

#File
MCSM_FILE="$MCSM_DIR/mcsm.sh"                           # $HOME/modpack/mcsm/mcsm.sh
LOG_FILE="$LOG_DIR/mcsm_$CURRENT_DATE.log"              # $HOME/modpack/mcsm/logs/mcsm_YYYY-MM-DD.log
CONFIG_FILE="$CONFIG_DIR/mcsm-common.conf"              # $HOME/modpack/mcsm/config/mcsm-common.conf
LOADER_FILE="$SOURCE_DIR/loader.sh"                     # $HOME/modpack/mcsm/source/loader.sh
SERVER_LAUNCHER_FILE="$SCRIPT_DIR/server_launcher.sh"   # $HOME/modpack/mcsm/source/script/run_server.sh
KEY_PUBLIC_FILE="$KEY_DIR/modpack_readonly.pub"         # $HOME/modpack/mcsm/keys/modpack_readonly.pub
KEY_PRIVATE_FILE="$KEY_DIR/modpack_readonly"            # $HOME/modpack/mcsm/keys/modpack_readonly
SOFTWARE_TEMP_FILE="$TEMP_DIR/validate.txt"             # $HOME/modpack/mcsm/temp/validate.txt
RESTART_TEMP_FILE="$TEMP_DIR/restart.txt"               # $HOME/modpack/mcsm/temp/restart.txt
CONFIG_TEMP_FILE="$TEMP_DIR/config.txt"               # $HOME/modpack/mcsm/temp/restart.txt

# Minecraft file
EULA_FILE="$MODPACK_DIR/eula.txt"                       # $HOME/modpack/eula.txt
SESSION_NAME=$(basename "$MODPACK_DIR" | tr -d '[:space:]' | tr -c '[:alnum:]_.-' '_') # Session name for tmux (es. modpack)

# ================================[ Check installation ]================================ #

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "ERROR: source directory not found: $SOURCE_DIR"
    exit 1
fi

if [[ ! -d "$LIBRARY_DIR" ]]; then
    echo "ERROR: library directory not found: $LIBRARY_DIR"
    exit 1
fi

if [[ ! -d "$SCRIPT_DIR" ]]; then
    echo "ERROR: script directory not found: $SCRIPT_DIR"
    exit 1
fi

if [[ ! -f $LOADER_FILE ]]; then
    echo "ERROR: loader file not found: $LOADER_FILE"
    exit 1
fi

source "$LOADER_FILE"
load_all_libraries
ensure_directory

check_software
check_config

# =================================[ Execution logic ]================================== #

if [[ "$MCSMUPDATE" == true ]]; then
    mcsm_update
fi

if [[ "$START" == true ]]; then
    start_minecraft_server
fi

if [[ "$EXIT" == true ]]; then
    if [[ "$NOW" == true ]]; then
        stop_minecraft_server_now
    else
        stop_minecraft_server
    fi
fi

if [[ "$RESTART" == true ]]; then
    if [[ "$NOW" == true ]]; then
        restart_minecraft_server_now
    else
        restart_minecraft_server
    fi
fi

if [[ "$CONSOLE" == true ]]; then
    open_minecraft_server_console
fi
