# File: help.sh
# Description: help command functions for mcsl
# Usage: . ./help.sh
# Author: NoveIX
# Created: 2026-06-03
# Last Updated: 2026-06-06
# Version: 1.0.0
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