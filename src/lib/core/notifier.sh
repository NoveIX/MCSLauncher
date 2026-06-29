# File: notifier.sh
# Description: notifier utility functions for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

send_discord() {
    local webhook_url="$1"
    local title="$2"
    local message="$3"
    local color="${4:-2326507}" # blu default

    # Check mandatory parameters
    require_param "webhook_url" "$webhook_url" "send_discord" || return 1
    require_param "title" "$title" "send_discord" || return 1
    require_param "message" "$message" "send_discord" || return 1

    local payload
    payload=$(cat <<EOF
{
  "embeds": [
    {
      "title": "$title",
      "description": "$message",
      "color": $color
    }
  ]
}
EOF
)

    # Prefer curl
    if command -v curl >/dev/null 2>&1; then
        if curl -fsS \
            -H "Content-Type: application/json" \
            -X POST \
            -d "$payload" \
            "$webhook_url"; then

            log_info "Discord notification sent"
            return 0
        fi

        log_error "curl: failed to send Discord notification" "print"
        return 1
    fi

    # Fallback wget
    if command -v wget >/dev/null 2>&1; then
        if wget -q \
            --header="Content-Type: application/json" \
            --post-data="$payload" \
            -O /dev/null \
            "$webhook_url"; then

            log_info "Discord notification sent"
            return 0
        fi

        log_error "wget: failed to send Discord notification" "print"
        return 1
    fi

    log_error "neither curl nor wget is installed" "print"
    return 1
}

send_telegram() {
    local bot_token="$1"
    local chat_id="$2"
    local message=$(printf %b "$3")

    # Check mandatory parameters
    require_param "bot_token" "$bot_token" "send_telegram" || return 1
    require_param "chat_id" "$chat_id" "send_telegram" || return 1
    require_param "message" "$message" "send_telegram" || return 1

    local url="https://api.telegram.org/bot${bot_token}/sendMessage"

    # Prefer curl
    if command -v curl >/dev/null 2>&1; then
        if curl -fsS \
            -X POST \
            -d "chat_id=${chat_id}" \
            --data-urlencode "text=${message}" \
            -d "parse_mode=HTML" \
            "$url" >/dev/null; then

            log_info "Telegram notification sent"
            return 0
        fi

        log_error "curl: failed to send Telegram notification" "print"
        return 1
    fi

    # Fallback wget
    if command -v wget >/dev/null 2>&1; then
        if wget -q \
            --header="Content-Type: application/x-www-form-urlencoded" \
            --post-data="chat_id=${chat_id}&text=${message}&parse_mode=HTML" \
            -O /dev/null \
            "$url"; then

            log_info "Telegram notification sent"
            return 0
        fi

        log_error "wget: failed to send Telegram notification" "print"
        return 1
    fi

    log_error "neither curl nor wget is installed" "print"
    return 1
}
