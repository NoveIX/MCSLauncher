# File: start.sh
# Description: Start command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

start_server() {
    local session="$1"
    local console="$2"
    local all="$3"

    # Check mandatory parameters
    require_param "session" "$session" "start_server" || return 1
    require_param "console" "$console" "start_server" || return 1
    require_param "all" "$all" "start_server" || return 1

    # REMOTE DELEGATION

    # Remote session delegation - ALL MODE (priority)
    if [[ "${all,,}" == "true" ]]; then
        load_module "$core_dir/caller.sh"

        local -a args=()

        # Only pass the --console flag if console is set to true (case-insensitive)
        [[ "${console,,}" == "true" ]] && args+=(--console)

        for dir in "$server_container"/*/; do
            [[ -d "$dir" ]] || continue

            # Extract the session name from the directory path
            session="${dir%/}"
            session="${session##*/}"

            # Call command in the specified session
            call_mcsl "$session" start "${args[@]}" || true
        done

        return 0
    fi

    # Remote session delegation - SINGLE SESSION
    if [[ "$session" != "$session_name" ]]; then
        load_module "$core_dir/caller.sh"

        local -a args=()

        # Only pass the --console flag if console is set to true (case-insensitive)
        [[ "${console,,}" == "true" ]] && args+=(--console)

        # Call command in the specified session
        call_mcsl "$session" start "${args[@]}" || true

        return 0
    fi

    # START COMMAND EXECUTION

    # Genereting default config
    if [[ ! -f "$cfg_dir/mcslctl.conf" ]]; then
        # Load required modules
        load_module "$core_dir/config.sh" || return 1

        mkdir -p "$cfg_dir"

        # Generate default configuration file
        log_info "generating default configuration" "print"
        default_config "$cfg_dir/mcslctl.conf"

        # Log message to inform the user about the generated configuration file
        log_info "edit '$cfg_dir/mcslctl.conf' to configure mcslctl behavior" "print"
        return 0
    fi

    # Load required modules
    load_module "$core_dir/command.sh" || return 1
    load_module "$core_dir/tmux.sh" || return 1
    load_module "$core_dir/server.sh" || return 1
    load_module "$core_dir/filesystem.sh" || return 1
    load_module "$core_dir/config.sh" || return 1

    # Check required dependencies
    check_command "tmux" || return 1
    check_command "java" "warn" || true

    # Check if the tmux session already exists
    # If it does, log a warning and return with a specific code
    if ! exists_tmux "$session"; then
        # Read mcslctl config behavior
        log_info "read mcslctl config"
        read_config "$cfg_dir/mcslctl.conf" || return 1

        # Read EULA to ensure it exists before starting the server
        read_eula "$server_root/eula.txt" || return 1

        # ensure restart/keep-alive flag exists
        write_restartctl "$restartctl" || return 1

        # Create a new detached tmux session that runs the mcslctl script
        log_info "starting server $session at $(date "+%F %T")" "print"
        tmux new-session -d -s "$session" -n "mcslctl" \
        bash "$mcslctl" "$mcsl_dir" "$LogMode"

        # Connect to tmux session
        [[ ${console,,} == "true" ]] && attach_tmux "$session"
        return 0
    fi

    log_info "Server $session is running" "print"
    return 0
}
