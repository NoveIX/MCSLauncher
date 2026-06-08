# File: config.sh
# Description: config utility functions for bash scripts
# Usage: . ./config.sh
# Author: NoveIX
# Created: 2026-06-3
# Last Updated: 2026-06-06
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

# Generate a default configuration file with example settings.
default_config() {
    cat <<'EOF' > "$1"
# Minecraft Server Launcher Config

# Server startup file provided by the JAR installer or custom script
# In case of relative path, it will be resolved against the server directory
# Support commands like "java -jar server.jar" or "./start.sh"
StartCommand=run.sh

# Automatic restart in case of crash
# Set to true to enable automatic restart, false to disable
CrashHandle=true

# Number of restart attempts before stopping to avoid infinite loop
# Set to a positive integer to limit the number of restarts
# Set to -1 for unlimited retries
MaxRestart=3
EOF
}

# Trim leading and trailing whitespace from a string.
trim() {
    local s="$1"

    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"

    printf '%s\n' "$s"
}

# Read configuration from a file and set global variables accordingly. Validates required parameters and applies defaults for optional ones.
read_config() {
    local config_file="$1"
    local key value
    local valid=true

    if [[ ! -f "$config_file" ]]; then
        log_info "Generating default configuration" "print"
        default_config "$config_file"
    fi

    while IFS='=' read -r key value; do
        key="$(trim "$key")"
        value="$(trim "$value")"

        # Skip empty lines and comments
        [[ -z "$key" || "$key" == \#* ]] && continue

        case "$key" in
            StartCommand)
                StartCommand="$value"
            ;;
            CrashHandle)
                CrashHandle="$value"
            ;;
            MaxRestart)
                MaxRestart="$value"
            ;;
            *)
                log_error "Unknown config key: $key"
                valid=false
            ;;
        esac
    done < "$config_file"

    # Required parameters
    if [[ -z "$StartCommand" ]]; then
        log_error "Missing required parameter: StartCommand" "print"
        valid=false
    fi

    # Optional defaults
    CrashHandle="${CrashHandle:-true}"
    MaxRestart="${MaxRestart:-3}"

    # Validation
    if [[ ! "$CrashHandle" =~ ^(true|false)$ ]]; then
        log_warn "Invalid CrashHandle value '$CrashHandle' (expected true|false)" "print"
    fi

    if [[ ! "$MaxRestart" =~ ^[0-9]+$ ]]; then
        log_warn "Invalid MaxRestart value '$MaxRestart' (expected integer)" "print"
    fi

    if [[ "$valid" != true ]]; then
        log_error "Configuration validation failed"
        return 1
    fi

    # Result
    log_info "Configuration loaded successfully"
    return 0
}
