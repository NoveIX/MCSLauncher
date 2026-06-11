# File: selfupdate.sh
# Description: Selfupdate command functions for mcsl
# Author: NoveIX
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Command ]================================= #

selfupdate() {
    # Load mcsl commands
    load_module "$commands_dir/version.sh" || return 1
    local old_version=$(get_version)

    # restore mcsl dir
    log_info "check for mcsl updates" "print"
    git -C "$mcsl_dir" restore -- .

    local output=$(git -C "$mcsl_dir" pull 2>&1)
    local status=$?

    # Check git pull exit code
    if [[ "${status:-1}" -eq 0 ]]; then

        # Check if version file exists
        if [[ -f "$version_file" ]]; then
            local new_version
            new_version=$(get_version)

            # Check different version
            if [[ "$old_version" != "$new_version" ]]; then
                log_info "mcsl update completed successfully" "print"
                print_version
            else
                log_info "no changes were applied" "print"
            fi
        fi
    else
        log_error "mcsl update failed" "print"
        printf -- "%s\n" "$output"
    fi

    chmod u+rwx,g+rw,o+r "$mcsl_dir/$mcsl_name"
}

#mcsm_update() {
#    local version_file="$SCRIPT_ROOT/VERSION"
#    local old_version="$VERSION"
#    local new_version
#    local git_output
#
#    log_info "Checking for MCSM updates..."
#
#    # Restore local changes before update
#    git -C "$SCRIPT_ROOT" restore . >/dev/null 2>&1
#
#    # Get repository update
#    git_output=$(git -C "$SCRIPT_ROOT" pull 2>&1)
#    local exit_code=$?
#
#    # Return if update failed
#    if [[ $exit_code -ne 0 ]]; then
#        log_error_cli "MCSM update failed, no changes were applied"
#        return 1
#    fi
#
#    # Reload version from file
#    if [[ -f "$version_file" ]]; then
#        new_version=$(<"$version_file")
#        new_version="${new_version//[$'\t\r\n ']/}"
#    else
#        log_error_cli "VERSION file not found after update"
#        return 1
#    fi
#
#    # Write update status
#    #if git -C "$SCRIPT_ROOT" diff --quiet HEAD@{1} HEAD 2>/dev/null; then
#    if ! git -C "$SCRIPT_ROOT" rev-parse @ >/dev/null 2>&1 && ! git -C "$SCRIPT_ROOT" rev-parse @{u} >/dev/null 2>&1; then
#        log_info_cli "MCSM is already up to date (version $old_version)"
#    elif [[ "$old_version" == "$new_version" ]]; then
#        log_info_cli "MCSM update completed, but version unchanged ($old_version)"
#    else
#        echo -e "\n# ====================[ Git log message ]==================== #\n"
#        echo "$git_output"
#        echo -e "\n# =========================================================== #\n"
#        log_info_cli "MCSM updated successfully: $old_version => $new_version"
#    fi
#
#    # Restore file executable
#    chmod +x "$MCSM_FILE"
#}