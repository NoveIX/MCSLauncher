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
    require_param "session" "$session" "status_server" || return 1
    require_param "host" "$host" "status_server" || return 1
    require_param "port" "$port" "status_server" || return 1
    require_param "all" "$all" "status_server" || return 1

    # REMOTE DELEGATION

    # Remote session delegation - ALL MODE (priority)
    if [[ "${all,,}" == "true" ]]; then
        load_module "$core_dir/caller.sh"

        for dir in "$server_container"/*/; do
            [[ -d "$dir" ]] || continue

            # Extract the session name from the directory path
            session="${dir%/}"
            session="${session##*/}"

            # Call command in the specified session
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
    local address="$host"

    # Color var
    local red="\033[31m"
    local blue="\033[94m"
    local green="\033[32m"
    local reset="\033[0m"

    # Status var
    local online="${green}Online${reset}"
    local offline="${red}Offline${reset}"
    local uptime="${blue}Uptime${reset}: N/A"

    # If localhost -> read port from server.properties
    if [[ "$host" == "127.0.0.1" || "$host" == "localhost" ]]; then
        load_module "$core_dir/server.sh"
        load_module "$core_dir/common.sh"

        # Get server port
        port=$(get_port "$server_root/server.properties") || true
        address="$session"

        # Get server uptime
        if [[ -f "$uptimectl" ]]; then
            local sts

            read -r sts < "$uptimectl"
            uptime="${blue}Uptime${reset}: $(format_duration "$(( $(date +%s) - sts ))")"
        fi
    fi

    # Prepare message
    [[ "$port" != "25565" ]] && address="$address:$port"

    # Check TCP connectivity
    if timeout 3 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        printf '%b●%b %-25s %-10b %b\n' "$green" "$reset" "$address" "$online" "$uptime"
        return 0
    fi

    printf '%b●%b %-25s %-10b %b\n' "$red" "$reset" "$address" "$offline" "$uptime"
    return 0
}
