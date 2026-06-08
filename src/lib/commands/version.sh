# File: version.sh
# Description: version command functions for mcsl
# Usage: . ./version.sh
# Author: NoveIX
# Created: 2026-06-03
# Last Updated: 2026-06-06
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

get_version() {
    local file="$1"

    # Check mandatory parameter
    if [[ -z "$file" ]]; then
        log_error "get_version: missing required parameter: file"
        return 1
    fi

    # Check if file exists and is readable
    if [[ ! -r "$file" ]]; then
        return 1
    fi

    # Extract version by removing whitespace
    tr -d '[:space:]' < "$file"
}

print_version() {
    local file="$1"
    
    # Check mandatory parameter
    if [[ -z "$file" ]]; then
        log_error "print_version: missing required parameter: file"
        return 1
    fi

    local version="$(get_version "$file")"

    cat <<EOF
Minecraft Server Launcher (MCSL)
Version: $version
EOF
}