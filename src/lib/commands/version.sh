# File: version.sh
# Description: Version command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

get_version() {
    # Check mandatory parameter

    if [[ -z "$version_file" ]]; then
        log_error "get_version: missing version file" "print"
        return 1
    fi

    # Extract version by removing whitespace
    tr -d '[:space:]' < "$version_file"
}

print_version() {
    # Get version from file
    local version=$(get_version)

    cat <<EOF
Minecraft Server Launcher (MCSL)
Version: $version
EOF
}