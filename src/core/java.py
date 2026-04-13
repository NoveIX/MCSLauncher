def minecraft_to_java(mc_version: str) -> int:
    """
    Converts a Minecraft version string into the required Java version.

    Supported rules:

    Minecraft Java Edition mapping:
        - 1.20.5  1.21.11 -> Java 21
        - 1.18  1.20.4     -> Java 17
        - 1.17              -> Java 16
        - 1.16 and older    -> Java 8

    Year-based versions:
        - 26.x+ -> Java 25

    Args:
        mc_version (str): Minecraft version (e.g. "1.20.1", "1.21.10", "26.1")

    Returns:
        int: Required Java major version
    """

    v = mc_version.strip()
    parts = v.split(".")

    # YEAR-BASED VERSIONS (26+)
    if not v.startswith("1."):
        try:
            major = int(parts[0])
        except ValueError:
            raise ValueError(f"Invalid Minecraft version: {mc_version}")

        if major >= 26:
            return 25

        raise ValueError(f"Unsupported year-based version: {mc_version}")

    # CLASSIC VERSIONS 1.x.y
    try:
        major = int(parts[0])  # always 1
        minor = int(parts[1]) if len(parts) > 1 else 0
        patch = int(parts[2]) if len(parts) > 2 else 0
    except ValueError:
        raise ValueError(f"Invalid Minecraft version: {mc_version}")

    version = (major, minor, patch)

    # JAVA RULES (UPDATED)
    if version >= (1, 20, 5):
        return 21
    elif version >= (1, 18, 0):
        return 17
    elif version >= (1, 17, 0):
        return 16
    else:
        return 8
