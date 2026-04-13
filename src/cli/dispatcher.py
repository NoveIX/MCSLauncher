# cli/dispatcher.py

from argparse import Namespace
from core.context import Context


def dispatch(args: Namespace, ctx: Context):
    """
    Route CLI commands to their corresponding handlers.

    This function acts as the central dispatcher for all CLI commands.
    It reads `args.command` and dynamically calls the appropriate handler,
    passing the CLI arguments and application context.

    Supported commands:
    - help
    - version
    - install
    - start
    - stop
    - restart
    - console
    - migrate
    - selfupdate

    Errors:
    - Raises KeyError internally for unknown commands
    - Handles KeyboardInterrupt for graceful cancellation
    """

    try:

        # Print help message
        if args.command == "help":
            from cli.help import print_help

            return print_help(ctx)

        # Print current version
        if args.command == "version":
            from cli.version import print_current_version

            return print_current_version(ctx)

        # Install server
        if args.command == "install":
            from commands.init import install_server

            return init_server(args, ctx)

        # Start server
        if args.command == "start":
            from commands.start import start_server

            return start_server(args, ctx)

        # Stop server
        if args.command == "stop":
            from commands.stop import stop_server

            return stop_server(args, ctx)

        # Restart server
        if args.command == "restart":
            from commands.restart import restart_server

            return restart_server(args, ctx)

        # Console server
        if args.command == "console":
            from commands.console import console_server

            return console_server(args, ctx)

        # Migrate server
        if args.command == "migrate":
            from commands.migrate import migrate_server

            return migrate_server(args, ctx)

        # Self update
        if args.command == "selfupdate":
            from commands.selfupdate import self_update

            return self_update(args, ctx)

        raise KeyError

    except KeyError:
        print("Unknown command. Use: mcsl help")
    except KeyboardInterrupt:
        print("\nOperation cancelled by user.")
