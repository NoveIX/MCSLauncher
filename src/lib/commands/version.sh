# File: version.sh
# Description: Version command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

get_version() {
    local file="${1:-$version_file}"

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
    local file="${1:-$version_file}"
    
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