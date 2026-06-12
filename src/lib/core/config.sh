# File: config.sh
# Description: Config utility functions for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

# Generate a default configuration file with example settings.
default_config() {
    local cfg_file="$1"

    # Check mandatory parameters
    if [[ -z "$cfg_file" ]]; then
        log_error "default_config: missing required parameter: config_file" "print"
        return 1
    fi

    # Create and write default config
    cat <<"EOF" > "$cfg_file"
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
    local cfg_file="$1"
    local key value
    local valid=true

    # Check mandatory parameters
    if [[ -z "$cfg_file" ]]; then
        log_error "read_config: missing required parameter: config_file" "print"
        return 1
    fi

    # Ensure cfg dir
    if [[ ! -d "$(dirname $cfg_file)" ]]; then
        mkdir -p "$(dirname $cfg_file)"
    fi

    # Check if config file exists
    if [[ ! -f "$cfg_file" ]]; then
        log_info "generating default configuration" "print"
        default_config "$cfg_file"
    fi

    # Check if config file is readable
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
                log_error "unknown config key: $key"
                valid=false
            ;;
        esac
    done < "$cfg_file"

    # Required parameters
    if [[ -z "$StartCommand" ]]; then
        log_error "missing required parameter: StartCommand" "print"
        valid=false
    fi

    # Optional defaults
    CrashHandle="${CrashHandle:-true}"
    MaxRestart="${MaxRestart:-3}"

    # Validation
    if [[ ! "$CrashHandle" =~ ^(true|false)$ ]]; then
        log_warn "invalid CrashHandle value '$CrashHandle' (expected true|false)" "print"
    fi

    if [[ ! "$MaxRestart" =~ ^[0-9]+$ ]]; then
        log_warn "invalid MaxRestart value '$MaxRestart' (expected integer)" "print"
    fi

    if [[ "$valid" != true ]]; then
        log_error "configuration validation failed" "print"
        return 1
    fi

    # Result
    log_info "configuration loaded successfully"
    return 0
}
