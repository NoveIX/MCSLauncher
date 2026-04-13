# fs.py

from pathlib import Path


# Create new dir
def new_dir(path: Path, is_file: bool = False) -> None:
    """
    Create a directory or ensure the parent directory of a file exists.

    If is_file is False, creates the directory at the given path.
    If is_file is True, creates only the parent directories of the given path.

    Note: this function does not create the file itself.
    """

    if is_file:
        path.parent.mkdir(parents=True, exist_ok=True)
    else:
        path.mkdir(parents=True, exist_ok=True)
