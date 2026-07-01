# File: server.sh
# Description: server utility functions for bash scripts
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ===============================[ Function map ]=============================== #

default_eula() {
    local file="$1"

    # Check mandatory parameters
    require_param "file" "$file" "default_eula" || return 1

    cat <<EOF > "$file"
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).
#$(date "+%a %b %d %T %Z %Y")
eula=false
EOF
}

read_eula() {
    local file="$1"

    # Check mandatory parameters
    require_param "file" "$file" "read_eula" || return 1

    # Check if eula file exists
    if [[ ! -f "$file" ]]; then
        log_info "generating default eula" "print"
        default_eula "$file"
    fi

    local value
    value=$(grep -E '^[[:space:]]*eula[[:space:]]*=' "$file" \
        | tail -n 1 \
        | cut -d'=' -f2 \
        | tr -d '[:space:]')

    # Default if missing
    [[ -z "$value" ]] && value="false"

    if [[ "$value" != "true" ]]; then
        local answer
        read -r -p "The EULA is not accepted. Accept it now? [y/N]: " answer

        if [[ "${answer,,}" == "y" ]]; then
            # ensure file exists
            touch "$file"

            # Update or add eula=true in the file
            if grep -q '^[[:space:]]*eula[[:space:]]*=' "$file"; then
                sed -i 's/^[[:space:]]*eula[[:space:]]*=.*/eula=true/' "$file"
            else
                printf '%s\n' "eula=true" >> "$file"
            fi

            # Log acceptance and return success
            log_info "EULA accepted by user"
            return 0
        fi

        # Log rejection and return failure
        log_warn "EULA not accepted by user, server will not start" "print"
        return 1
    fi

    log_info "EULA already accepted"
    return 0
}

get_port() {
    local file="$1"

    # Check mandatory parameters
    require_param "file" "$file" "get_port" "err" || return 1

    # Check server.properties exists
    if [[ ! -f "$file" ]]; then
        log_error "get_port: file not found: $file" "print" "err"
        return 1
    fi

    # Extract the server-port value from the server.properties file
    local port=$(grep -E '^server-port=' "$file" | head -n1 | cut -d'=' -f2)

    # Check if the port value was found
    if [[ -z "$port" ]]; then
        log_error "get_port: server-port not found in $file" "print" "err"
        return 1
    fi

    # Output the port value
    printf '%s\n' "$port"
}
