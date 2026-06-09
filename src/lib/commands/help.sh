# File: help.sh
# Description: Help command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

print_help() {
    # Load mcsl commands
    load_module "$commands_dir/version.sh" || return 1

    local version="$(get_version)"

    cat <<EOF
version: $version
EOF
}