# utils/cpu.py

import platform
import sys


def get_system_arch() -> str:
    """
    Detect system architecture and map it to a standardized format.

    Returns:
        str: "x64" or "aarch64"

    Raises:
        RuntimeError: If architecture is not supported.
    """

    sys_arch = platform.machine()

    if sys_arch == "x86_64":
        return "x64"

    elif sys_arch == "aarch64":
        return "aarch64"

    else:
        error_msg = (
            "\n"
            "============================================\n"
            "SYSTEM NOT SUPPORTED\n"
            f"Detected architecture: {sys_arch}\n"
            "Required architecture: 64-bit (x64 or ARM64)\n"
            "============================================\n"
        )

        print(error_msg, file=sys.stderr)
        raise RuntimeError("Unsupported system architecture")
