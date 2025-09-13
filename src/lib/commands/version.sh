# File: version.sh
# Description: Version command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

get_version() {
    # Check mandatory parameters
    if [[ -z "$version_file" ]]; then
        log_error "get_version: missing version file" "print" "err"
        return 1
    fi

    # Extract version by removing ONLY carriage returns, preserving all spaces
    local version
    IFS= read -r version < "$version_file"

    # Print the version string, stripping the \r if present
    printf '%s\n' "${version//$'\r'/}"
}

print_version() {
    # Get version from file
    local version=$(get_version)

    cat <<EOF
Minecraft Server Launcher (MCSL)
Version: $version
EOF
}
