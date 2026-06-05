# File: logger.sh
# Description: Logging utility functions for bash scripts
# Usage: . ./logger.sh
# Author: NoveIX
# Created: 2026-05-15
# Last Updated: 2026-06-03
# Version: 3.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ===============================[ Function map ]=============================== #

loglevel_map() {
    case "${1,,}" in
        trace) printf -- '%s\n' 0 ;;
        debug) printf -- '%s\n' 1 ;;
        info)  printf -- '%s\n' 2 ;;
        warn)  printf -- '%s\n' 3 ;;
        error) printf -- '%s\n' 4 ;;
        fatal) printf -- '%s\n' 5 ;;
        done)  printf -- '%s\n' 6 ;;
        *)     printf -- '%s\n' 0 ;;
    esac
}

logcolor_map() {
    case "${1,,}" in
        trace) printf -- '\033[90m' ;;
        debug) printf -- '\033[37m' ;;
        info)  printf -- '\033[94m' ;;
        warn)  printf -- '\033[33m' ;;
        error) printf -- '\033[31m' ;;
        fatal) printf -- '\033[35m' ;;
        done)  printf -- '\033[32m' ;;
        *)     printf -- '\033[0m' ;;
    esac
}

# ================================[ Function ]================================ #

should_log() {
    # Check if the log level of the message is greater than or equal to the global minimum log level.
    (( $(loglevel_map "$1") >= $(loglevel_map "$global_minlevel") ))
}

log_setting() {
    global_logfile="$1"
    global_minlevel="${2:-info}"
    global_print="${3:-noprint}"

    # If global_logfile is set, create log file paths with date suffixes for organized logging.
    if [[ -n "$global_logfile" ]]; then
        local logdate=$(date +%F)
        local logname=$(basename "$global_logfile")
        local logdir=$(dirname "$global_logfile")

        mkdir -p "$logdir"

        global_logfile="${logdir}/${logname}_${logdate}.log"
        global_logfile_warn="${logdir}/${logname}_${logdate}_warn.log"
        global_logfile_error="${logdir}/${logname}_${logdate}_error.log"
        global_logfile_fatal="${logdir}/${logname}_${logdate}_fatal.log"
    fi
}

log() {
    local level="$1"
    local message="$2"
    local print="${3:-$global_print}"
    local path="${4:-$global_logfile}"

    # log level check
    should_log "$level" || return 0

    # terminal output
    if [[ ${print,,} == "print" ]]; then
        printf -- '[%b%s%b]: %s\n' \
        "$(logcolor_map "$level")" \
        "$level" \
        "\033[0m" \
        "$message"
    fi

    # file output
    if [[ -n "$path" ]]; then
        printf -- '[%s] [%s]: %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$level" \
        "$message" >> "$path"
    fi
}

log_trace() {
    # DarkGray TRACE log level.
    log "TRACE" "$1" "$2" "$3"
}

log_debug() {
    # Gray DEBUG log level.
    log "DEBUG" "$1" "$2" "$3"
}

log_info() {
    # Blue INFO log level.
    log "INFO" "$1" "$2" "$3"
}

log_warn() {
    # DarkYellow WARN log level.
    log "WARN" "$1" "$2" "$3"

    # Print on warn file log
    log "WARN" "$1" "noprint" "$global_logfile_warn"
}

log_error() {
    # DarkRed ERROR log level.
    log "ERROR" "$1" "$2" "$3"

    # Print on error file log
    log "ERROR" "$1" "noprint" "$global_logfile_error"
}

log_fatal() {
    # Magenta FATAL log level.
    log "FATAL" "$1" "$2" "$3"

    # Print on fatal file log
    log "FATAL" "$1" "noprint" "$global_logfile_fatal"
}

log_done() {
    # Green DONE log level.
    log "DONE" "$1" "$2" "$3"
}
