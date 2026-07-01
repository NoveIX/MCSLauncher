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

    # Function var
    local address="$host"
    local tmux=""
    local tcp=""
    local uptime="N/A"

    # Color var
    local red="\033[31m"
    local blue="\033[94m"
    local green="\033[32m"
    local reset="\033[0m"

    # Status var
    local online="${green}Online${reset}"
    local offline="${red}Offline${reset}"

    # Local server information
    if [[ "$host" == "127.0.0.1" || "$host" == "localhost" ]]; then
        # Load required modules
        load_module "$core_dir/server.sh" || return 1
        load_module "$core_dir/common.sh" || return 1
        load_module "$core_dir/command.sh" || return 1
        load_module "$core_dir/tmux.sh" || return 1

        # Check required dependencies
        check_command "tmux" "fatal" || return 1

        # Check if the tmux session exists
        if exists_tmux "$session"; then
            tmux="$online"
        else
            tmux="$offline"
        fi

        # Get server port
        port=$(get_port "$server_root/server.properties") || true
        address="localhost"

        # Get server uptime
        if [[ -f "$uptimectl" ]]; then
            local sts

            read -r sts < "$uptimectl"
            uptime="${blue}$(format_duration "$(( $(date +%s) - sts ))")${reset}"
        else
            uptime="${red}Not Running${reset}"
        fi
    fi

    # Address display port
    [[ "$port" != "25565" ]] && address="$address:$port"

    # TCP connectivity
    if timeout 3 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        tcp="$online"
    else
        tcp="$offline"
    fi

    # Output
    printf '\n'

    if [[ "$host" == "127.0.0.1" || "$host" == "localhost" ]]; then
        printf 'Session:  %s\n' "$session"
    fi

    [[ -n "$tmux" ]] && printf 'Tmux:     %b\n' "$tmux"

    printf 'Address:  %s\n' "$address"
    printf 'tcp/ip:   %b\n' "$tcp"
    printf 'Uptime:   %b\n' "$uptime"

    printf '\n'
}

# Rework systemctl style output for better readability
#Session:  minecraft
#Tmux:     Online
#TCP/IP:   Online
#Uptime:   2d 14h 32m
