# cli/parser.py

import sys
import argparse
from core.context import Context


# Argument handler
class ArgumentHandler(argparse.ArgumentParser):
    """
    Custom ArgumentParser that overrides default argparse error handling.

    Prints a standardized mcsl error message and exits with status code 1
    instead of showing the default argparse error output.
    """

    def error(self, message):
        print(f"mcsl error: incorrect syntax. {message}")
        sys.exit(1)


# Parse argument
def parse_args(ctx: Context):
    """
    Parse and define mcsl CLI arguments.

    Builds the complete command-line interface using argparse subparsers,
    including all supported commands and their parameters.

    Also handles early interception of help flags to display custom help output
    before argparse processing.

    Returns:
        argparse.Namespace: Parsed CLI arguments containing command and options.
    """

    parser = ArgumentHandler(
        prog="mcsl",
        description="simple script to start and stop minecraft server based on tmux",
        add_help=False,
    )

    # Early help shortcut
    if any(arg in sys.argv for arg in ("-h", "--help", "-help")):
        from cli.help import print_help

        print_help(ctx.version_file)
        sys.exit(0)

    subparsers = parser.add_subparsers(dest="command", required=True)

    # help
    subparsers.add_parser("help")

    # version
    subparsers.add_parser("version")

    # start
    subparsers.add_parser("start")

    # stop
    parser = subparsers.add_parser("stop", aliases=["exit", "e"])
    parser.add_argument("-n", "--now", action="store_true")
    parser.add_argument("-t", "--timer", type=int)

    # restart
    parser = subparsers.add_parser("restart", aliases=["r", "re"])
    parser.add_argument("-n", "--now", action="store_true")
    parser.add_argument("-t", "--timer", type=int)

    # console
    subparsers.add_parser("console")

    # migrate
    subparsers.add_parser("migrate")

    # selfupdate
    subparsers.add_parser("selfupdate")

    return parser.parse_args()
