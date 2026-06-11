# File: status.sh
# Description: Status command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

status_server() {
    local host="$1"
    local port="$2"
    local session="$3"

    # Check mandatory parameter
    if [[ -z "$host" ]]; then
        log_error "server_status: missing required parameter: host" "print"
        return 1
    fi

    if [[ -z "$port" ]]; then
        log_error "server_status: missing required parameter: port" "print"
        return 1
    fi

    if [[ -z "$session" ]]; then
        log_error "server_status: missing required parameter: session" "print"
        return 1
    fi

    # Function var
    local server=""

    # Color var
    local green="\033[32m"
    local red="\033[31m"
    local reset="\033[0m"

    # Status var
    local online="${green}Online${reset}"
    local offline="${red}Offline${reset}"

    # If localhost -> read port from server.properties
    if [[ "$host" == "127.0.0.1" || "$host" == "localhost" ]]; then
        # Load command module
        load_module "$core_dir/server.sh"

        # Get Minecraft server port
        port=$(get_port "$server_root/server.properties")
        server="$session"
    else
        server="$host"
    fi

    # Prepare message
    if [[ "$port" != "25565" ]]; then
        server="$server:$port"
    fi

    # Check TCP connectivity
    if timeout 3 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        printf -- "%-20s %-10b\n" "$server" "$online"
        return 0
    fi

    printf -- "%-20s %-10b\n" "$server" "$offline"
    return 1
}