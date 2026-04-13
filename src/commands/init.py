# commands/install.py

from pathlib import Path

from cli.prompt import prompt, select_loader_type, select_java_installation, select_jvm_args
from utils.jsonio import write_json
from core.context import Context
from core.java import minecraft_to_java


def init_server(ctx: Context):

    # Minecraft configuration
    minecraft_version = prompt("Select Minecraft version (e.g. 1.20.1)")
    loader_type = select_loader_type()

    loader_version = None
    if loader_type in ("forge", "neoforge", "fabric", "quilt"):
        loader_version = prompt("Select loader version (e.g. 47.4.10)")

    # Runtime configuration
    java_major = minecraft_to_java(minecraft_version)
    java_mode = select_java_installation()

    jvm_args_mode = select_jvm_args()
    if jvm_args_mode == "inline":
        raw_args = prompt("Enter JVM args separated by space (e.g. -Xms4G -Xmx8G)")
        jvm_args = raw_args.split()

    # Crash behavior
    ans = prompt("Restart server on crash? [Y/n]", True)
    restart_server = ans == "y"
    if restart_server:
        on_crash_action = "restart"
        max_retries = int(prompt("Max crash retries (e.g. 3)"))
        delay_seconds = int(prompt("Delay between retries (seconds)"))

    # Build config
    config = {
        "minecraft": {"version": minecraft_version, "loader": {"type": loader_type}},
        "runtime": {
            "java": {"major": int(java_major), "location": {"mode": java_mode}},
            "server": {
                # "script": script_path,
                "jvmArgs": {"mode": jvm_args_mode},
            },
        },
    }

    # Add loader version
    if loader_version:
        config["minecraft"]["loader"]["version"] = loader_version

    # Add java path
    if java_mode == "local":
        config["runtime"]["java"]["location"]["path"] = str(Path("java", "bin", "java"))

    # add jvm args
    if jvm_args_mode == "inline" and jvm_args:
        config["runtime"]["server"]["jvmArgs"]["args"] = jvm_args

    # Add behavior
    if restart_server:
        config["behavior"]["onCrash"]["action"] = on_crash_action
        config["behavior"]["onCrash"]["maxRetries"] = max_retries
        config["behavior"]["onCrash"]["delaySeconds"] = delay_seconds

    # Write final JSON config
    write_json(Path(ctx.cfg_file), config)
    print("\nConfig created successfully.\n")
