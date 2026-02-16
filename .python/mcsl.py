import subprocess
import yaml
from pathlib import Path

CONFIG_PATH = Path("config/mcsl.yml")

def load_config():
    with open(CONFIG_PATH) as f:
        return yaml.safe_load(f)

def has_session(session):
    return subprocess.run(
        ["tmux", "has-session", "-t", session],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    ).returncode == 0

def start():
    config = load_config()
    session = config["session"]
    if has_session(session):
        print("Server already running.")
        return
    subprocess.run(["tmux", "new-session", "-d", "-s", session, "script/run.sh"])
    print("Server started.")

def status():
    config = load_config()
    session = config["session"]
    print("Running." if has_session(session) else "Not running.")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: mcsl.py [start|status]")
    elif sys.argv[1] == "start":
        start()
    elif sys.argv[1] == "status":
        status()
