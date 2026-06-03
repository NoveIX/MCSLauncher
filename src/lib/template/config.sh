# File: config.sh
# Description: config utility functions for bash scripts
# Usage: . ./config.sh
# Author: NoveIX
# Created: 2026-06-3
# Last Updated: 2026-06-3
# Version: 1.0.0
# SPDX-License-Identifier: GPL-3.0-or-later

# ================================[ Function ]================================ #

default_config() {
    cat <<'EOF' > "$1"
# Minecraft Server Launcher Config

# Server startup file provided by the JAR installer or custom script
# In case of relative path, it will be resolved against the server directory
# Support commands like "java -jar server.jar" or "./start.sh"
StartServerCMD="run.sh"

# Automatic restart in case of crash
# Set to true to enable automatic restart, false to disable
CrashHandle="true"

# Number of restart attempts before stopping to avoid infinite loop
# Set to a positive integer to limit the number of restarts
# Set to 0 for unlimited retries
CrashRetry="3"
EOF
}