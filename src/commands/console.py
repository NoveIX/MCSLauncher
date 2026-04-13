# commands/console.py


import subprocess
from core.context import Context


def console_server(ctx: Context) -> None:
    try:
        subprocess.run(["tmux", "attach", "-t", ctx.tmux_name], check=True)
    except subprocess.CalledProcessError:
        print(f"Errore: impossibile collegarsi alla sessione tmux '{ctx.tmux_name}'.")
    except FileNotFoundError:
        print("tmux non è installato o non è disponibile nel PATH.")
