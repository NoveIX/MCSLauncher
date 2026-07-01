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

    if [[ "${all,,}" == "true" || "$session" != "$session_name" ]]; then
        load_module "$core_dir/caller.sh" || return 1

        local -a args=()
        [[ "${console,,}" == "true" ]] && args+=(--console)

        # Call command in the specified session or all sessions
        if [[ "${all,,}" == "true" ]]; then
            call_sessions start "${args[@]}" || return 1
        else
            call_session "$session" start "${args[@]}" || return 1
        fi

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
        default_config_notify "$cfg_dir/mcslctl-notify.conf"

        # Log message to inform the user about the generated configuration file
        log_info "edit '$cfg_dir/mcslctl.conf' to configure mcslctl behavior" "print"
        log_info "edit '$cfg_dir/mcslctl-notify.conf' to configure mcslctl notification" "print"
        return 0
    fi

    # Load required modules
    load_module "$core_dir/command.sh" || return 1
    load_module "$core_dir/tmux.sh" || return 1
    load_module "$core_dir/server.sh" || return 1
    load_module "$core_dir/filesystem.sh" || return 1
    load_module "$core_dir/config.sh" || return 1

    # Check required dependencies
    check_command "tmux" "fatal" || return 1
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

    log_info "server $session is running" "print"
    return 0
}
