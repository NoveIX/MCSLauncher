# File: loader.sh
# Description: Module loader for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

write_restartctl() {
    local file="$1"

    # Check mandatory parameters
    require_param "file" "$file" "write_restartctl" || return 1

    # Ensure cfg dir
    if [[ ! -d "$(dirname $file)" ]]; then
        mkdir -p "$(dirname $file)"
    fi

    # ensure restart/keep-alive file exists
    if ! printf 'starting server at %s\n' "$(date '+%F %T')" > "$file"; then
        log_error "write restartctl failed: $file" "print"
        return 1
    fi

    log_info "created restartctl: $file"
    return 0
}

remove_restartctl() {
    local file="$1"

    # Check mandatory parameters
    require_param "file" "$file" "remove_restartctl" || return 1

    # Remove restartctl file
    if ! rm -f "$file"; then
        log_error "remove restartctl failed: $file" "print"
        return 1
    fi

    log_info "removed restartctl: $file"
    return 0
}

wait_save() {
    local file="$1"
    local pattern="$2"

    tail -F "$file" | while read -r line; do
        echo "$line"
        if [[ "$line" == *"$pattern"* ]]; then
            break
        fi
    done
}
