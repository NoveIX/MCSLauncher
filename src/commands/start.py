# commands/start.py

from pathlib import Path
from core.context import Context
from utils.jsonio import read_json
from commands.init import init_server


def start_server(ctx: Context):

    # Read data from config
    data = read_json(Path(ctx.cfg_file))

    # if config data not found generate new one
    if not data:
        print("\nNo configuration find. Generate new one\n")
        init_server(ctx)
