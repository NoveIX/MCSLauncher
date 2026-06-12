# File: status.sh
# Description: Status command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

status_server() {
    local session="$1"
    local host="$2"
    local port="$3"
    local all="$4"

    # Check mandatory parameters
    if [[ -z "$session" ]]; then
        log_error "server_status: missing required parameter: session" "print"
        return 1
    fi

    if [[ -z "$host" ]]; then
        log_error "server_status: missing required parameter: host" "print"
        return 1
    fi

    if [[ -z "$port" ]]; then
        log_error "server_status: missing required parameter: port" "print"
        return 1
    fi

    if [[ -z "$all" ]]; then
        log_error "server_status: missing required parameter: all" "print"
        return 1
    fi

    # Remote session delegation - ALL MODE (priority)
    if [[ "${all,,}" == "true" ]]; then
        load_module "$core_dir/caller.sh"

        for dir in "$server_container"/*/; do
            [[ -d "$dir" ]] || continue

            session="${dir%/}"
            session="${session##*/}"

            call_mcsl "$session" status || true
        done

        return 0
    fi

    # Remote session delegation - SINGLE SESSION
    if [[ "$session" != "$session_name" ]]; then
        load_module "$core_dir/caller.sh"

        # Call command in the specified session
        call_mcsl "$session" status --host "$host" --port "$port"

        return 0
    fi

    # STATUS COMMAND EXECUTION

    # Function var
    local address=""

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
        address="$session"
    else
        address="$host"
    fi

    # Prepare message
    [[ "$port" != "25565" ]] && address="$address:$port"

    # Check TCP connectivity
    if timeout 3 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        printf -- "%-25s %-10b\n" "$address" "$online"
        return 0
    else
        printf -- "%-25s %-10b\n" "$address" "$offline"
        return 0
    fi
}