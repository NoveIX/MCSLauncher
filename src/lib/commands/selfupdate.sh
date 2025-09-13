# File: selfupdate.sh
# Description: Selfupdate command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

selfupdate() {
    local session="$1"
    local all="$2"

    # Check mandatory parameters
    require_param "session" "$session" "selfupdate" || return 1
    require_param "all" "$all" "selfupdate" || return 1

    # REMOTE DELEGATION

    # Remote session delegation - ALL MODE (priority)
    if [[ "${all,,}" == "true" ]]; then
        load_module "$core_dir/caller.sh"

        for dir in "$server_container"/*/; do
            [[ -d "$dir" ]] || continue

            # Extract the session name from the directory path
            session="${dir%/}"
            session="${session##*/}"

            # Call command in the specified session
            call_mcsl "$session" selfupdate || true
        done

        return 0
    fi

    # Remote session delegation - SINGLE SESSION
    if [[ "$session" != "$session_name" ]]; then
        load_module "$core_dir/caller.sh"

        # Call command in the specified session
        call_mcsl "$session" selfupdate || true

        return 0
    fi

    # SELFUPDATE COMMAND EXECUTION

    # Load required modules
    load_module "$core_dir/command.sh" || return 1
    load_module "$commands_dir/version.sh" || return 1

    # Check required dependencies
    check_command "git" || return 1

    # Get mcsl current version
    local old_version=$(get_version)

    # restore mcsl dir
    log_info "check for mcsl updates" "print"
    git -C "$mcsl_dir" restore -- .

    local output=$(git -C "$mcsl_dir" pull 2>&1)
    local status=$?

    # Check git pull exit code
    if [[ "${status:-1}" -eq 0 ]]; then

        # Check if version file exists
        if [[ -f "$version_file" ]]; then
            local new_version
            new_version=$(get_version)

            # Check different version
            if [[ "$old_version" != "$new_version" ]]; then
                log_info "mcsl update completed" "print"
                printf '\n'
                print_version
            else
                log_info "mcsl is already running the latest version" "print"
            fi
        fi
    else
        log_error "mcsl update failed" "print"
        printf '%s\n' "$output"
    fi

    chmod u+rwx,g+rw,o+r "$mcsl_dir/$mcsl_name"
}
