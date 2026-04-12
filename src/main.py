# main.py

from cli.dispatcher import dispatch
from cli.parser import parse_args
from core.context import Context


# mcsl
def main():
    """
    Entry point of the mcsl CLI application.

    Initializes the application context, parses command-line arguments,
    and dispatches the requested command to the appropriate handler.

    Flow:
    - Create project context
    - Parse CLI arguments
    - Execute command dispatcher
    """

    ctx = Context.from_project()
    args = parse_args(ctx)
    dispatch(args, ctx)


# Execute mcsl
if __name__ == "__main__":
    main()
