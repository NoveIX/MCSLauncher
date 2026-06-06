# File: common.sh
# Description: common utility functions for bash scripts
# Usage: . ./command.sh
# Author: NoveIX
# Created: 2026-06-05
# Last Updated: 2026-06-06
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

# Format a duration in seconds into a human-readable string (e.g., "1d 2h 3m 4s").
format_duration() {
    local total_seconds=${1:-0}

    local days=$(( total_seconds / 86400 ))
    local hours=$(( (total_seconds % 86400) / 3600 ))
    local minutes=$(( (total_seconds % 3600) / 60 ))
    local seconds=$(( total_seconds % 60 ))

    local result=""

    # Construct the formatted duration string based on non-zero time components
    (( days > 0 )) && result+="${days}d "
    (( hours > 0 )) && result+="${hours}h "
    (( minutes > 0 )) && result+="${minutes}m "
    result+="${seconds}s"

    # Remove trailing space and return the formatted duration string
    printf '%s\n' "${result%" "}"
}