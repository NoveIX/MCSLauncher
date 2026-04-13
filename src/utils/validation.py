# utils/validation.py

import shutil


# Check installation of required software and dependencies
def check_command(cmd_name: str) -> bool:
    """
    Check whether a system command is available in the current environment.

    Uses shutil.which to determine if the given command exists in the system PATH.

    Args:
        cmd_name (str): Name of the command to check.

    Returns:
        bool: True if the command is found in PATH, False otherwise.
    """

    if shutil.which(cmd_name):
        return True
    return False


# Specific checks for required software
def validate_tmux() -> bool:
    """
    Check whether tmux is available in the system.

    Returns True if the 'tmux' command is found in the system PATH,
    otherwise returns False.
    """

    return check_command("tmux")
