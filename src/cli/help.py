# cli/help.py

from core.context import Context
from cli.version import print_current_version


# Print help
def print_help(ctx: Context) -> None:
    """
    Print the fsync command-line interface help message.

    Includes:
    - current version
    - general usage syntax
    - list of supported commands with brief descriptions

    This function serves as the main entry point for user-facing CLI documentation.
    """

    print_current_version(ctx)
    print("Usage: fsync <command> [options]\n")
    print("Commands:")
    print("  help                         Show this help message")
    print("  version                      Show fsync version")
    print("  start                        Start the server")
    print("  stop [now] [timer]           Stop the server (immediately or after N seconds)")
    print("  restart [now] [timer]        Restart the server (immediately or after N seconds)")
    print("  console                      Connect to the server console")
    print("  migrate                      Migrate the server to another host")
    print("  selfupdate                   Update fsync from the repository")
