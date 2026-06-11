# File: help.sh
# Description: Help command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

print_help() {
    # Load mcsl commands
    load_module "$commands_dir/version.sh" || return 1
    local version=$(get_version)
#TODO Fix help message
    cat <<EOF
Script Name:          mcsl.sh - Minecraft Server Launcher
Description:          Runtime bash script for managing Minecraft servers.
                      Provides start, stop, restart, and console access functionalities.
                      Uses tmux for process management to keep the server running.

Usage:                mcsl.sh Commands --param|-p <options>

Options:
  -s, --start         Start the server.
  -e, --exit          Stop the server with a in-game warning seconds before shutdown.
  -r, --restart       Restart the server gracefully with an in-game warning.
  -c, --console       Attach to the server console (tmux session).
  -h, --help          Display this help information.
  --selfupdate        Update MCSL from the official Git repository.
  --version           Show the currently installed MCSL version.

Examples:
  ./mcsl.sh -c        Connect to tmux console
  ./mcsl.sh -r        Restart Minecraft server after 30 second and warn player
  ./mcsl.sh -rn       Restart Minecraft server in-game warning
  ./mcsl.sh -snc      Launch Minecraft server in-game warning and connect to tmux
  ./mcsl.sh --stop    Shutdown Minecraft server after 30 second and warn player
  ./mcsl.sh --start   Start Minecraft server

Features:
  - Start, stop, and restart the server (graceful or immediate)
  - Access server console
  - Update MCSM from official repository
  - Logs management and configuration parsing

Notes:
  - Requires Bash 4.4+ for associative arrays
  - Requires tmux for encapsulation of the Java process
  - Tested on Ubuntu 24.04 and Debian 13
  - Make sure you have write permission in the output directory

More info:
  - GitHub:           https://github.com/NoveIX/MCSLauncher

License:              GPL-3.0-or-later
Author:               NoveIX
Version:              $version
Date:                 2026-10-06
EOF
}