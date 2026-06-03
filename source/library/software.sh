#!/usr/bin/env bash

# ================================[ Validate software ]================================= #

# Check if Java is installed
java_installed() {
    if command -v java &>/dev/null; then
        local java_ver=$(java -version 2>&1 | awk -F[\".] '/version/ {print $2}')
        if (( java_ver < 17 )); then
            log_error_cli "Java major version too old: $java_ver. Java 17 or higher is required"
            exit 1
        else
            log_info "Java installation detected. Detected major version: $java_ver"
        fi
    else
        log_error_cli "Java is not installed. Please install Java 17 or higher"
        exit 1
    fi
}

# Check if tmux is installed
tmux_installed() {
    if command -v tmux &>/dev/null; then
        local tmux_ver=$(tmux -V 2>&1 | awk '{print $2}')
        log_info "Tmux installation detected. Detected version: $tmux_ver"
    else
        log_error_cli "Tmux is not installed. Please install Tmux to run the server"
        exit 1
    fi
}

# Validate software
validate_software() {
    java_installed
    tmux_installed
}

check_software() {
    if [[ ! -f $SOFTWARE_TEMP_FILE ]]; then
        log_info "Validating software prerequisite..."
        validate_software
        echo "Validation software completed on $(date)" > "$SOFTWARE_TEMP_FILE"
        log_info "Validation software completed on $(date)"
    else
        log_info "Software already validated. No action required"
    fi
}

# ==================================[ Tmux function ]=================================== #

# Validate tmux session name
check_session_name() {
    if [[ ! "$SESSION_NAME" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
        log_error_cli "Tmux session name  $SESSION_NAME contain a invalid characters"
        echo
        echo "Allowed characters:"
        echo "  Letters: a-z e A-Z"
        echo "  Numbers: 0-9"
        echo "  Symbols: -, _, "
        echo
        exit 1
    else
        log_info "Tmux session name $SESSION_NAME is valid"
    fi
}

# Check if a tmux session exists
session_exist() {
    tmux has-session -t "$SESSION_NAME" 2>/dev/null
}

# Exit if the tmux session exists
exit_if_session_exists() {
    if session_exist; then
        log_warn_cli "Tmux session name $SESSION_NAME already exists"
        exit 3
    fi
}

# Exit if the tmux session is missing
exit_if_session_missing() {
    if ! session_exist; then
        log_warn_cli "Tmux session name $SESSION_NAME not found"
        exit 3
    fi
}

# Wait until the tmux session is closed
wait_closing_session() {
    while session_exist "$SESSION_NAME"; do
        sleep 1
    done

    log_info_cli "Minecraft server $SESSION_NAME closed"
    sleep 5
}

# =============================[ Tmux server interaction ]============================== #

# Start the server in a new tmux session
tmux_server_start() {
    echo "Starting server on date $(date)" > "$RESTART_TEMP_FILE"

    # Check if run.sh exist
    cd "$MODPACK_DIR"
    SERVER_RUN_FILE="$MODPACK_DIR/$RUN_FILE"
    if [[ ! -f "$SERVER_RUN_FILE" ]]; then
        log_error_cli "Minecraft server run file not found $SERVER_RUN_FILE"
        rm -f "$RESTART_TEMP_FILE"
        exit 1
    fi

    tmux new-session -d -s "$SESSION_NAME" -n "mcsm" \
    "bash \"$SERVER_LAUNCHER_FILE\" \"$SERVER_RUN_FILE\" \"$CRASH_HANDLE\" \"$CRASH_RETRY\" \"$RESTART_TEMP_FILE\" \"$MCSM_DIR\""
    log_info_cli "Minecraft server $SESSION_NAME is starting..."
}

# Stop the server by sending "stop" command to the tmux session
tmux_server_stop() {
    if [ -f "$RESTART_TEMP_FILE" ]; then
        rm -f "$RESTART_TEMP_FILE"
        log_info "Deleted file to prevent restart: $RESTART_TEMP_FILE"
    fi

    tmux send-keys -t "$SESSION_NAME" "stop" ENTER
    log_info_cli "Minecraft server $SESSION_NAME is stopping..."
}

# Warn players that the server will stop in 30 seconds
tmux_server_shutdown_player_warn() {
    tmux send-keys -t "$SESSION_NAME" "say Server will shutdown in 30 seconds. Please prepare to disconnect." ENTER
    log_info_cli "Minecraft server $SESSION_NAME will shutdown in 30 seconds"
}

# Warn players that the server will restart in 30 seconds
tmux_server_restart_player_warn() {
    tmux send-keys -t "$SESSION_NAME" "say Server will restart in 30 seconds. Please prepare to disconnect." ENTER
    log_info_cli "Minecraft server $SESSION_NAME will restart in 30 seconds"
}

# Enter the tmux session (send ENTER key)
tmux_server_enter() {
    tmux send-keys -t "$SESSION_NAME" ENTER
    log_info "Sent ENTER in session name $SESSION_NAME"
}

# Attach tmux session
tmux_attach_server() {
    log_info "Connect to session name $SESSION_NAME"
    tmux attach -t "$SESSION_NAME"
}

