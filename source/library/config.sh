#!/usr/bin/env bash

# ===================================[ Lib function ]=================================== #

write_default_config() {
    cat <<'EOF' > "$CONFIG_FILE"
# =================================[ Server settings ]================================== #

# Server startup file provided by the JAR installer
RUN_FILE="run.sh"

# Automatic restart in case of crash
CRASH_HANDLE=true

# Number of restart attempts before stopping to avoid infinite loop
CRASH_RETRY=10

# =================================[ Git integration ]================================== #

# Enable Git integration
GIT_ENABLE=false

# Repository SSH keys (provide URLs or local paths)
GIT_SSH_PUBLIC_KEY_LINK=""
GIT_SSH_PRIVATE_KEY_LINK=""
EOF
}

check_config() {
    # If the file does not exist, create a default configuration and validate it
    if [[ ! -f $CONFIG_FILE ]]; then
        log_info "Config not found. Creating default file"
        write_default_config
        validate_config
        return
    fi

    # Get modification timestamps for both files
    local config_mtime
    local validation_mtime

    config_mtime=$(stat -c %Y "$CONFIG_FILE")
    if [[ -f "$CONFIG_TEMP_FILE" ]]; then
        config_temp_mtime=$(stat -c %Y "$CONFIG_TEMP_FILE")
    else
        config_temp_mtime=0
    fi

    # Compare dates
    if (( config_mtime > config_temp_mtime )); then
        log_info "Config file modified after last validation. Revalidate"
        validate_config
    else
        log_info "Config already validated. No action required"
        source "$CONFIG_FILE"
    fi
}

validate_config() {
    local valid=true

    log_info "Validating config file..."

    # load config
    source "$CONFIG_FILE"

    # Check parameter
    [[ -n "$RUN_FILE" ]] || { log_error_cli "RUN_FILE not set"; valid=false; }
    [[ "$CRASH_HANDLE" =~ ^(true|false)$ ]] || { log_error_cli "CRASH_HANDLE must be true or false"; valid=false; }
    [[ "$CRASH_RETRY" =~ ^[0-9]+$ ]] || { log_error_cli "CRASH_RETRY must be a number"; valid=false; }
    [[ "$GIT_ENABLE" =~ ^(true|false)$ ]] || { log_error_cli "GIT_ENABLE must be true or false"; valid=false; }

    # Result
    if [[ $valid == true ]]; then
        echo "Validation config completed on $(date)" > "$CONFIG_TEMP_FILE"
        log_info "Validation config completed on $(date)"
    else
        log_error "Validation config failed. Correct the configuration file"
        exit 1
    fi
}
