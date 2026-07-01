# File: version.sh
# Description: Version command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

get_version() {
    # Check mandatory parameters
    require_param "version_file" "$version_file" "get_version" "err" || return 1

    # Extract version by removing ONLY carriage returns, preserving all spaces
    local version
    if ! IFS= read -r version < "$version_file";then
        log_error "failed to read version from $version_file" "print" "err"
        printf '%s\n' "unknown"
        return 0
    fi

    # Print the version string, stripping the \r if present
    printf '%s\n' "${version//$'\r'/}"
    return 0
}

print_version() {
    # Get version from file
    local version=$(get_version)

    cat <<EOF
Minecraft Server Launcher (MCSL)
Version: $version
EOF
}
