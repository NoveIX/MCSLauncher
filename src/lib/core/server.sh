# File: server.sh
# Description: server utility functions for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ===============================[ Function map ]=============================== #

get_port() {
    local file="$1"

    # Check mandatory parameters
    if [[ -z "$file" ]]; then
        log_error "get_port: missing required parameter: file" "print"
        return 1
    fi

    # Check server.properties exists
    if [[ ! -f "$file" ]]; then
        log_error "get_port: file not found: $file" "print"
        return 1
    fi

    # Extract the server-port value from the server.properties file
    local port=$(grep -E '^server-port=' "$file" | head -n1 | cut -d'=' -f2)

    # Check if the port value was found
    if [[ -z "$port" ]]; then
        log_error "get_port: server-port not found in $file" "print"
        return 1
    fi

    # Output the port value
    printf -- "%s\n" "$port"
}