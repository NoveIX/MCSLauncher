# File: loader.sh
# Description: Module loader for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

write_restartctl() {
    local file="$1"

    # Ensure cfg dir
    [[ ! -d "$(dirname $file)" ]] && mkdir -p "$(dirname $file)"

    # ensure restart/keep-alive file exists
    if printf 'starting server at %s\n' "$(date '+%F %T')" > "$file"; then
        log_info "created restartctl: $file"
        return 0
    fi

    log_error "write restartctl failed: $file" "print"
    return 1
}

remove_restartctl() {
    local file="$1"

    # Remove restartctl file
    if rm -f "$file"; then
        log_info "removed restartctl: $file"
        return 0
    fi

    log_error "remove restartctl failed: $file" "print"
    return 1
}

wait_pattern() {
    local file="$1"
    local pattern="$2"

    tail -F "$file" 2>/dev/null | grep -q --line-buffered "$pattern"
}
