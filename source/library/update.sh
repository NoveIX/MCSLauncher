#!/usr/bin/env bash

# ===================================[ Lib function ]=================================== #

mcsm_update() {
    local version_file="$SCRIPT_ROOT/VERSION"
    local old_version="$VERSION"
    local new_version
    local git_output

    log_info "Checking for MCSM updates..."

    # Restore local changes before update
    git -C "$SCRIPT_ROOT" restore . >/dev/null 2>&1

    # Get repository update
    git_output=$(git -C "$SCRIPT_ROOT" pull 2>&1)
    local exit_code=$?

    # Return if update failed
    if [[ $exit_code -ne 0 ]]; then
        log_error_cli "MCSM update failed, no changes were applied"
        return 1
    fi

    # Reload version from file
    if [[ -f "$version_file" ]]; then
        new_version=$(<"$version_file")
        new_version="${new_version//[$'\t\r\n ']/}"
    else
        log_error_cli "VERSION file not found after update"
        return 1
    fi

    # Write update status
    #if git -C "$SCRIPT_ROOT" diff --quiet HEAD@{1} HEAD 2>/dev/null; then
    if ! git -C "$SCRIPT_ROOT" rev-parse @ >/dev/null 2>&1 && ! git -C "$SCRIPT_ROOT" rev-parse @{u} >/dev/null 2>&1; then
        log_info_cli "MCSM is already up to date (version $old_version)"
    elif [[ "$old_version" == "$new_version" ]]; then
        log_info_cli "MCSM update completed, but version unchanged ($old_version)"
    else
        echo -e "\n# ====================[ Git log message ]==================== #\n"
        echo "$git_output"
        echo -e "\n# =========================================================== #\n"
        log_info_cli "MCSM updated successfully: $old_version => $new_version"
    fi

    # Restore file executable
    chmod +x "$MCSM_FILE"
}