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
# Minecraft Server Launcher Controller Configuration

# Command used to start the Minecraft server.
# The command is executed from the server root directory.
# Supports relative or absolute paths, as well as commands with arguments.
# Examples:
#   StartCommand=java -jar server.jar nogui
#   StartCommand=run.sh
StartCommand=run.sh

# Automatically restart the server if it crashes.
# Valid values: true, false
# Default: true
CrashHandle=true

# Maximum number of restart attempts before giving up.
# Use a positive integer to limit retries.
# Use -1 for unlimited restart attempts.
# Default: 3
MaxRestart=3

# Default log mode used by mcslctl.
# Valid values:
#   separate - Creates dedicated log files for warnings, errors, and fatal messages.
#   combined - Writes all log messages to a single file.
# Default: separate
LogMode=separate
EOF
}

default_config_notify() {
    local file="$1"

    # Check mandatory parameters
    require_param "file" "$file" "default_config_notify" || return 1

    # Create and write default config
    cat <<"EOF" > "$file"
# Minecraft Server Launcher Notification Configuration

# Enable or disable notifications for server events.
EnableNotification=false

# Name of the server shown in notifications
ServerName=My Minecraft Server

# Discord webhook URL for server events
DiscordWebHook=https://discord.com/api/webhooks/HooksId

# Telegram bot token
TelegramToken=TokenId

# Telegram chat ID (can be negative for groups)
TelegramChatID=ChatId
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
    if [[ ! "${CrashHandle,,}" =~ ^(true|false)$ ]]; then
        log_warn "invalid CrashHandle value $CrashHandle (expected true|false)" "print"
    fi

    if [[ ! "$MaxRestart" =~ ^(-1|[0-9]+)$ ]]; then
        log_warn "invalid MaxRestart value $MaxRestart (expected integer or -1)" "print"
    fi

    if [[ ! "$LogMode" =~ ^(separate|combined)$ ]]; then
        log_warn "invalid LogMode value $LogMode (expected separate|combined)" "print"
    fi

    if [[ "${valid,,}" != "true" ]]; then
        log_error "configuration validation failed" "print"
        return 1
    fi

    # Result
    log_info "configuration loaded successfully"
    return 0
}

read_config_notify() {
    local file="$1"
    local key value
    local valid=true

    # Check mandatory parameters
    require_param "file" "$file" "read_config_notify" || return 1

    # Ensure cfg dir
    if [[ ! -d "$cfg_dir" ]]; then
        mkdir -p "$cfg_dir"
    fi

    # Check if config file exists
    if [[ ! -f "$file" ]]; then
        log_info "generating default notify configuration" "print"
        default_config_notify "$file"
    fi

    # Check if config file is readable
    while IFS='=' read -r key value; do
        key="$(trim "$key")"
        value="$(trim "$value")"

        # Skip empty lines and comments
        [[ -z "$key" || "$key" == \#* ]] && continue

        case "$key" in
            EnableNotification)
                EnableNotification="$value"
            ;;

            ServerName)
                ServerName="$value"
            ;;

            DiscordWebHook)
                DiscordWebHook="$value"
            ;;

            TelegramToken)
                TelegramToken="$value"
            ;;

            TelegramChatID)
                TelegramChatID="$value"
            ;;

            *)
                log_error "unknown config key: $key"
                valid=false
            ;;
        esac
    done < "$file"

    #    # Validation (notify-specific)

    if [[ ! "$EnableNotification" =~ ^(true|false)$ ]]; then
        log_error "invalid EnableNotification value $EnableNotification (expected true|false)" "print"
        valid=false
    fi

    if [[ "${EnableNotification,,}" == "true" ]]; then

        if [[ -z "$ServerName" ]]; then
            log_warn "ServerName is empty"
        fi

        if [[ -z "$DiscordWebHook" ]]; then
            log_warn "DiscordWebHook is empty (Discord notifications disabled)"
        fi

        if [[ -z "$TelegramToken" || -z "$TelegramChatID" ]]; then
            log_warn "Telegram is not fully configured (missing token or chat ID)"
        fi

    fi

    if [[ "${valid,,}" != "true" ]]; then
        log_error "configuration validation failed" "print"
        return 1
    fi

    # Result
    log_info "notify configuration loaded successfully"
    return 0
}
