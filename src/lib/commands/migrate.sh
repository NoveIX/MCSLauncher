# File: migrate.sh
# Description: Migrate command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

migrate_server() {
    local dest="$1"
    local host="$2"
    local user="$3"
    local key="$4"
    local port="$5"
    local time="$6"

    # Check mandatory parameters
    require_param "dest" "$dest" "migrate_server" || return 1

    [[ "$dest" == *:* ]] && host="${dest%%:*}"
    if [[ -z "$host" ]]; then
        migrate_local "$dest" "$time" || return 1
    else
        migrate_remote "$@" || return 1
    fi

    return 0
}

# Move server root - LOCAL MIGRATION

migrate_local() {
    local dest="$1"
    local time="$2"
    local answer

    # Load required modules
    load_module "$core_dir/command.sh" || return 1
    load_module "$commands_dir/stop.sh" || return 1

    # Check required dependencies
    check_command "rsync" || return 1

    # separate dest and host if dest contains ':'
    [[ "$dest" == *:* ]] && dest="${dest#*:}"

    # Log migration info
    printf '\n'
    log_info "local move: $dest/" "print"
    printf '\n'

    # Check if user wants to continue
    printf '%b●%b ' "\033[32m" "\033[0m"
    read -r -p "Server will be stopped if running. Proceed with migration? [y/N]: " answer
    if [[ "${answer,,}" != "y" ]]; then
        log_info "migration aborted by user" "print"
        return 0
    fi

    # Stop server
    stop_server "$session_name" "$time" "shutdown" "false" || return 1
    wait_tmux "$session_name" || return 1

    # OVERRIDE log setting to print only in console.
    log_setting

    # Ensure directory
    dest="${dest%/}"
    if ! mkdir -p "$dest"; then
        log_error "failed to create directory: $dest" "print"
        return 1
    fi

    # Check empty dir - NOTE: find+grep returns 0 if NOT empty, 1 if empty (inverted logic)
    if find "$dest" -mindepth 1 -print -quit | grep -q .; then
        log_error "destination directory is not empty: $dest" "print"
        return 1
    fi

    # Move server
    printf '\n'
    log_info "migration in progress" "print"
    if ! rsync -ah --info=progress2 --remove-source-files "$server_root/" "$dest/"; then
        log_error "rsync failed: $server_root/ -> $dest/" "print"
        return 1
    fi

    # Change dir to prevent this error:
    #shell-init: error retrieving current directory: getcwd: cannot access parent directories: No such file or directory
    cd $HOME

    # Remove server root
    if ! rm -rf "$server_root"; then
        log_error "failed to remove server root: $server_root" "print"
        return 1
    fi

    # Log migration completion
    log_info "local migration completed" "print"
    printf '\n'

    # Ask restart after migration
    printf '%b●%b ' "\033[32m" "\033[0m"
    read -r -p "Restart server now? [Y/n]: " ask

    # Restart server if user agrees (default is yes)
    [[ "${ask,,}" != "n" ]] && bash "$dest/mcsl/$mcsl_name" start || return 1

    return 0
}

# Move server root - REMOTE MIGRATION

migrate_remote() {
    local dest="$1"
    local host="$2"
    local user="$3"
    local key="$4"
    local port="$5"
    local time="$6"

    # Load required modules
    load_module "$core_dir/command.sh" || return 1
    load_module "$core_dir/remote.sh" || return 1
    load_module "$commands_dir/stop.sh" || return 1

    # Check required dependencies
    check_command "ssh" || return 1
    check_command "rsync" || return 1

    # separate dest and host if dest contains ':'
    if [[ "$dest" == *:* ]]; then
        host="${dest%%:*}"
        dest="${dest#*:}"
    fi

    # separate user and host if host contains '@'
    if [[ "$host" == *@* ]]; then
        user="${host%%@*}"
        host="${host#*@}"
    fi

    # Check SSH connectivity
    log_info "testing SSH connection to $host"

    if ! test_ssh "$host" "$user" "$key" "$port"; then
        log_error "SSH connection test failed: $host" "print"
        return 1
    fi

    log_info "SSH connection test successful: $host" "print"

    # Check required dependencies on remote host
    sshcheck_command "ssh" "$host" "" "$user" "$key" "$port" || return 1
    sshcheck_command "rsync" "$host" "" "$user" "$key" "$port" || return 1
    sshcheck_command "tmux" "$host" "" "$user" "$key" "$port" || return 1
    sshcheck_command "java" "$host" "warn" "$user" "$key" "$port" || true

    # Log migration info
    local login="${user:+$user@}$host"
    printf '\n'
    log_info "destination: $login:$dest/" "print"
    printf '\n'

    # Check if user wants to continue
    printf '%b●%b ' "\033[32m" "\033[0m"
    read -r -p "Server will be stopped if running. Proceed with migration? [y/N]: " answer
    if [[ "${answer,,}" != "y" ]]; then
        log_info "migration aborted by user" "print"
        return 0
    fi

    # Stop server
    stop_server "$session_name" "$time" "shutdown" "false" || return 1
    wait_tmux "$session_name" || return 1

    # OVERRIDE log setting to print only in console.
    log_setting

    # Ensure directory
    dest="${dest%/}"
    if ! call_ssh "$host" "$user" "$key" "$port" mkdir -p "$dest"; then
        log_error "failed to create remote directory: $login:$dest/" "print"
        return 1
    fi

    # Check empty dir - NOTE: find+grep returns 0 if NOT empty, 1 if empty (inverted logic)
    if call_ssh "$host" "$user" "$key" "$port" "find '$dest' -mindepth 1 -print -quit | grep -q ."; then
        log_error "destination directory is not empty: $login:$dest/" "print"
        return 1
    fi

    # Build SSH command for rsync
    local -a ssh_cmd=(
        ssh
        -o BatchMode=yes
        -o PasswordAuthentication=no
        -o KbdInteractiveAuthentication=no
    )

    # Add user, key, and port options if provided
    [[ -n "$key" ]] && ssh_cmd+=(-i "$key")
    [[ -n "$port" ]] && ssh_cmd+=(-p "$port")

    # Move server
    printf '\n'
    log_info "migration in progress" "print"
    if ! rsync -azh --info=progress2 --remove-source-files -e "${ssh_cmd[*]}" "$server_root/" "$login:$dest/"; then
        log_error "rsync failed: $server_root/ -> $login:$dest/" "print"
        return 1
    fi

    # Change dir to prevent this error:
    #shell-init: error retrieving current directory: getcwd: cannot access parent directories: No such file or directory
    cd $HOME

    # Remove server root
    if ! rm -rf "$server_root"; then
        log_error "failed to remove server root: $server_root" "print"
        return 1
    fi

    # Log migration completion
    log_info "remote migration completed" "print"
    printf '\n'

    # Ask restart after migration
    printf '%b●%b ' "\033[32m" "\033[0m"
    read -r -p "Restart server now? [Y/n]: " ask

    # Restart server if user agrees (default is yes)
    [[ "${ask,,}" != "n" ]] && call_ssh "$host" "$user" "$key" "$port" bash "$dest/mcsl/$mcsl_name" start || return 1

    return 0
}
