#!/usr/bin/env bash

# File: install.sh
# Description: Minecraft Server Launcher Installer
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

# ===============================[ Parameter ]================================ #

if [[ $# -lt 1 ]]; then
    printf "Usage: installer.sh <server_root>\n"
    exit 1
fi

readonly server_root="$1"
readonly mcsl_dir="$server_root/mcsl"

# ==================================[ Main ]================================== #

if ! command -v git >/dev/null 2>&1; then
    printf -- "%s\n" "git is not installed"
    exit 1
fi



git clone "https://github.com/NoveIX/MCSLauncher.git" "$server_root/mcsl"