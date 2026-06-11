# File: logger.sh
# Description: Logger utility functions for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ===============================[ Function map ]=============================== #

# Map log levels to numeric values for comparison.
loglevel_map() {
    case "${1,,}" in
        trace) printf -- "%s\n" 0 ;;
        debug) printf -- "%s\n" 1 ;;
        info)  printf -- "%s\n" 2 ;;
        warn)  printf -- "%s\n" 3 ;;
        error) printf -- "%s\n" 4 ;;
        fatal) printf -- "%s\n" 5 ;;
        done)  printf -- "%s\n" 6 ;;
        *)     printf -- "%s\n" 0 ;;
    esac
}

# Map log levels to ANSI color codes for terminal output.
logcolor_map() {
    case "${1,,}" in
        trace) printf -- "\033[90m" ;;
        debug) printf -- "\033[37m" ;;
        info)  printf -- "\033[94m" ;;
        warn)  printf -- "\033[33m" ;;
        error) printf -- "\033[31m" ;;
        fatal) printf -- "\033[35m" ;;
        done)  printf -- "\033[32m" ;;
        *)     printf -- "\033[0m" ;;
    esac
}

# ================================[ Function ]================================ #

should_log() {
    # Check if the log level of the message is greater than or equal to the global minimum log level.
    (( $(loglevel_map "$1") >= $(loglevel_map "$global_minlevel") ))
}

# Set global log file paths and logging settings.
log_setting() {
    global_logfile="${1:-}"
    global_minlevel="${2:-info}"
    global_print="${3:-noprint}"
    local separate_logs="${4:-separate}"

    # If global_logfile is set, create log file paths with date suffixes for organized logging.
    if [[ -n "$global_logfile" ]]; then
        local logdate="$(date +%F)"
        local logname="$(basename "$global_logfile")"
        local logdir="$(dirname "$global_logfile")"

        # Set global log file paths with date suffixes for different log levels.
        global_logfile="${logdir}/${logname}_${logdate}.log"
        if [[ "${separate_logs,,}" == "separate" ]]; then
            global_logfile_warn="${logdir}/${logname}_${logdate}_warn.log"
            global_logfile_error="${logdir}/${logname}_${logdate}_error.log"
            global_logfile_fatal="${logdir}/${logname}_${logdate}_fatal.log"
        fi
    fi
}

# main log function that handles log level checking, terminal output, and file output based on the provided parameters.
log() {
    local level="$1"
    local message="$2"
    local print="${3:-$global_print}"
    local path="${4:-$global_logfile}"

    # log level check
    should_log "$level" || return 0

    # terminal output
    if [[ ${print,,} == "print" ]]; then
        printf -- "%b%s%b: %s\n" \
        "$(logcolor_map "$level")" \
        "${level,,}" \
        "\033[0m" \
        "$message"
    fi

    ## terminal output
    #if [[ ${print,,} == "print" ]]; then
    #    printf -- "[%b%s%b]: %s\n" \
    #    "$(logcolor_map "$level")" \
    #    "$level" \
    #    "\033[0m" \
    #    "$message"
    #fi

    # file output
    if [[ -n "$path" ]]; then
        if [[ ! -d "$(dirname "$path")" ]]; then
            mkdir -p "$(dirname "$path")"
        fi

        # Write log on file
        printf -- "%s %s %s\n" \
        "$(date "+%Y-%m-%d %H:%M:%S")" \
        "${level,,}" \
        "$message" >> "$path"
    fi

    # file output og
    #if [[ -n "$path" ]]; then
    #    printf -- "[%s] [%s]: %s\n" \
    #    "$(date "+%Y-%m-%d %H:%M:%S")" \
    #    "$level" \
    #    "$message" >> "$path"
    #fi
}

# Convenience functions for each log level that call the main log function with the appropriate parameters.

log_trace() {
    # DarkGray TRACE log level.
    log "TRACE" "${1:-}" "${2:-}" "${3:-}"
}

log_debug() {
    # Gray DEBUG log level.
    log "DEBUG" "${1:-}" "${2:-}" "${3:-}"
}

log_info() {
    # Blue INFO log level.
    log "INFO" "${1:-}" "${2:-}" "${3:-}"
}

log_warn() {
    # DarkYellow WARN log level.
    log "WARN" "${1:-}" "${2:-}" "${3:-}"

    # Print on warn file log
    if [[ -n "${global_logfile_warn:-}" ]]; then
        log "WARN" "${1:-}" "noprint" "$global_logfile_warn"
    fi
}

log_error() {
    # DarkRed ERROR log level.
    log "ERROR" "${1:-}" "${2:-}" "${3:-}"

    # Print on error file log
    if [[ -n "${global_logfile_error:-}" ]]; then
        log "ERROR" "${1:-}" "noprint" "$global_logfile_error"
    fi
}

log_fatal() {
    # Magenta FATAL log level.
    log "FATAL" "${1:-}" "${2:-}" "${3:-}"

    # Print on fatal file log
    if [[ -n "${global_logfile_fatal:-}" ]]; then
        log "FATAL" "${1:-}" "noprint" "$global_logfile_fatal"
    fi
}

log_done() {
    # Green DONE log level.
    log "DONE" "${1:-}" "${2:-}" "${3:-}"
}
