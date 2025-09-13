# File: config.sh
# Description: Config utility functions for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

# Generate a default configuration file with example settings.
default_config() {
    local file="$1"

    # Check mandatory parameters
    require_param "file" "$file" "default_config" || return 1

    # Create and write default config
    cat <<"EOF" > "$file"
# Minecraft Server Launcher Controller Config

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

# Default log mode for mcslctl. Options: "separate" (default), "combined"
# "separate" mode creates additional log files for warnings, errors, and fatal messages.
# "combined" mode logs all messages into a single log file.
LogMode=separate
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
    local file="$1"
    local key value
    local valid=true

    # Check mandatory parameters
    require_param "file" "$file" "read_config" || return 1

    # Ensure cfg dir
    if [[ ! -d "$cfg_dir" ]]; then
        mkdir -p "$cfg_dir"
    fi

    # Check if config file exists
    if [[ ! -f "$file" ]]; then
        log_info "generating default configuration" "print"
        default_config "$file"
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

            LogMode)
                LogMode="$value"
            ;;

            *)
                log_error "unknown config key: $key"
                valid=false
            ;;
        esac
    done < "$file"

    # Required parameters
    require_param "StartCommand" "$StartCommand" "read_config" || return 1

    # Optional defaults
    CrashHandle="${CrashHandle:-true}"
    MaxRestart="${MaxRestart:-3}"
    LogMode="${LogMode:-separate}"

    # Validation
    if [[ ! "$CrashHandle" =~ ^(true|false)$ ]]; then
        log_warn "invalid CrashHandle value $CrashHandle (expected true|false)" "print"
    fi

    if [[ ! "$MaxRestart" =~ ^(-1|[0-9]+)$ ]]; then
        log_warn "invalid MaxRestart value $MaxRestart (expected integer or -1)" "print"
    fi

    if [[ ! "$LogMode" =~ ^(separate|combined)$ ]]; then
        log_warn "invalid LogMode value $LogMode (expected separate|combined)" "print"
    fi

    if [[ "$valid" != true ]]; then
        log_error "configuration validation failed" "print"
        return 1
    fi

    # Result
    log_info "configuration loaded successfully"
    return 0
}
