# cli/version.py

from core.context import Context


# get mcsl version from file
def get_current_version(ctx: Context) -> str:
    """
    Read and return the current mcsl version from the VERSION file.

    Args:
        ctx (Context): Application context containing the path to the version file.

    Returns:
        str: The version string read from the file.
    """

    with open(ctx.version_file, "r") as f:
        return f.read().strip()


# print mcsl version
def print_current_version(ctx: Context) -> None:
    """
    Print the current mcsl version to the console.

    Retrieves the version using the application context and outputs it
    in a human-readable format.
    """

    version = get_current_version(ctx)
    print(f"MCSLauncher version: {version}")
