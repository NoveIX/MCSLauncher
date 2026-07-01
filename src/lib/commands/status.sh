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

    if [[ "${all,,}" == "true" || "$session" != "$session_name" ]]; then
        load_module "$core_dir/caller.sh" || return 1

        # Call command in the specified session or all sessions
        if [[ "${all,,}" == "true" ]]; then
            call_sessions status || return 1
        else
            call_session "$session" status || return 1
        fi

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
    local dot="${red}●${reset}"
    local online="${green}Online${reset}"
    local offline="${red}Offline${reset}"
    local uptime="${blue}Uptime${reset}: N/A"

    # If localhost -> read port from server.properties
    if [[ "$host" == "127.0.0.1" || "$host" == "localhost" ]]; then
        load_module "$core_dir/tmux.sh" || return 1
        load_module "$core_dir/server.sh" || return 1
        load_module "$core_dir/common.sh" || return 1

        # Check if session exist
        exists_tmux "$session_name" && dot="${green}●${reset}"

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
    [[ -n "$port" && "$port" != "25565" ]] && address="$address:$port"

    # Check TCP connectivity
    if timeout 3 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        printf '%b %-20s %-10b  | %b\n' "$dot" "$address" "$online" "$uptime"
        return 0
    fi

    printf '%b %-20s %-10b | %b\n' "$dot" "$address" "$offline" "$uptime"
    return 0
}
