# core/context.py

from pathlib import Path


# Create context runtime
class Context:
    """
    Holds global filesystem paths for the application.

    This context centralizes all important project directories such as:
    - project root
    - configuration directory
    - version file path

    It is used to avoid hardcoding paths across the codebase.
    """

    def __init__(self, project_root):
        self.project_root = project_root
        self.cfg_dir = Path(project_root, "cfg")
        self.logs_dir = Path(project_root, "logs")
        self.version_file = Path(project_root, "src", "data", "current-version.txt")

    @classmethod
    def from_project(cls):
        project_root = Path(__file__).resolve().parents[2]
        return cls(project_root)
