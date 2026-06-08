#!/usr/bin/env bash

# File: loader.sh
# Description: Module loader for bash scripts
# Usage: . ./loader.sh
# Author: NoveIX
# Created: 2026-05-15
# Last Updated: 2026-06-06
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

# Declare an associative array to keep track of loaded modules
declare -A LOADED_MODULES

# Load a module by sourcing the specified file. Prevents multiple loads of the same module.
load_module() {
    local module=$1

    # Check mandatory parameter
    if [[ -z $module ]]; then
        printf -- "load_module: missing required parameter: module\n" >&2
        return 1
    fi

    # Check if the module file exists
    if [[ ! -f $module ]]; then
        printf -- "load_module: module not found: %s\n" "$module" >&2
        return 1
    fi

    # Check if the module has already been loaded
    if [[ "${LOADED_MODULES["$module"]:-}" == 1 ]]; then
        return 0
    fi

    # shellcheck source=/dev/null
    if ! source "$module"; then
        printf -- "load_module: failed to load: %s\n" "$module" >&2
        return 1
    fi

    LOADED_MODULES["$module"]=1
}

# Reset the loaded modules tracking array (useful for testing or reloading).
reset_loaded_modules() {
    unset LOADED_MODULES
    declare -gA LOADED_MODULES
}
