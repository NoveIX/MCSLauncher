# core/config.py

import json
from pathlib import Path
from utils.filesystem import new_dir


def read_json(file_path: Path) -> dict:
    if not file_path.exists():
        return {}

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        if not isinstance(data, dict):
            return {}

        mcsl = data.get("mcsl", {})

        return mcsl if isinstance(mcsl, dict) else {}

    except Exception as e:
        print(f"Could not read file: {e}")
        return {}


def write_json(file_path: Path, mcsl: dict) -> None:
    if not isinstance(mcsl, dict):
        print("Invalid config: mcsl must be a dict")
        return

    data = {"mcsl": mcsl}

    try:
        new_dir(file_path, True)
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"Could not write file: {e}")
