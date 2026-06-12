# File: help.sh
# Description: Help command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

print_help() {
    # Load mcsl commands
    load_module "$commands_dir/version.sh" || return 1
    local version
    version=$(get_version)

    cat <<EOF
Script Name:              ${mcsl_name:-mcsl.sh} - Minecraft Server Launcher
Description:              Runtime bash script for managing Minecraft servers.
                          Provides start, stop, restart, status, console, and update actions.
                          Uses tmux to manage the Minecraft server process.

Usage:                    ${mcsl_name:-mcsl.sh} <command> [options]

Commands:
  help, -h, --help        Show this help message.
  version, -v, --version  Show the installed MCSL version.
  start                   Start the Minecraft server.
  stop                    Stop the Minecraft server.
  restart                 Restart the Minecraft server.
  console                 Attach to the server tmux console.
  status                  Display the server status.
  selfupdate              Update MCSL from the Git repository.

Options:
  -s, --session <name>    Name of the tmux session to use (default: derived from server root).
  -t, --time <seconds>    Delay in seconds for stop/restart operations.
  -c, --console           Attach to the tmux session after starting or restarting.
  -a, --all               Apply the command to all servers in the parent container directory.
  -h, --host <host>       Host to query for status (default: localhost).
  -p, --port <port>       Port to query for status (default: 25565).

Examples:
  ./mcsl.sh start
  ./mcsl.sh stop --time 30
  ./mcsl.sh restart --time 60 --console
  ./mcsl.sh console
  ./mcsl.sh status --host localhost --port 25565
  ./mcsl.sh --help

Features:
  - Start, stop, and restart the server with graceful warnings.
  - Attach to the Minecraft server console through tmux.
  - Query server online/offline status.
  - Self-update MCSL from the Git repository.

Notes:
  - Requires Bash 4.4+ for associative arrays and shell features.
  - Requires tmux for server process management.
  - Tested on Ubuntu 24.04 and Debian 13.
  - Ensure write permission in the output and runtime directories.

More info:
  - GitHub:           https://github.com/NoveIX/MCSLauncher

License:              GPL-3.0-or-later
Author:               NoveIX
Version:              $version
Date:                 2026-06-10
EOF
}