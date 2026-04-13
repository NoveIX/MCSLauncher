#!/bin/sh

# Absolute path to the script's root directory
SCRIPT_ROOT="$(cd "$(dirname "$0")" && pwd)"
FSYNC_ROOT="$(cd "$SCRIPT_ROOT/.." && pwd)"

# Name venv directory
#VENV_NAME=".venv"

# List of Python packages to install (space-separated)
#PACKAGES="pyyaml" # Edit or add packages here

# Update os package list
sudo apt update -y

# Install Python venv and pip if not already installed
sudo apt install -y tmux

# Create the virtual environment
#python3 -m venv "$FSYNC_ROOT/$VENV_NAME"

# Activate the virtual environment
#. "$FSYNC_ROOT/$VENV_NAME/bin/activate"

# Update pip inside the venv
#python -m pip install --upgrade pip

# Install Python packages
#for pkg in $PACKAGES; do
#    pip install "$pkg"
#done

# Deactivate the virtual environment
#deactivate

# Set execute permissions for the main script
chmod 764 "$FSYNC_ROOT/mcsl.sh"