# File: stop.sh
# Description: stop command functions for mcsl
# Usage: . ./stop.sh
# Author: NoveIX
# Created: 2026-06-03
# Last Updated: 2026-06-03
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

mcsl_stop() {
    local session_name="$1"
    local mcsl_dir="$2"
    local core_dir="$mcsl_dir/src/lib/core"
    local mcslctl="$mcsl_dir/src/script/mcslctl.sh"

    # Load command module
    load_module "$core_dir/command.sh"
    check_command "tmux" || exit 1

    # Load tmux module
    load_module "$core_dir/tmux.sh"
}