# cli/io.py


# Helper function for prompts
def prompt(field: str, lowercase: bool = False) -> str:
    """
    Prompt the user for input and return the entered string.

    Args:
        field: Label displayed to the user in the prompt.
        lowercase: If True, converts the input to lowercase before returning.

    Returns:
        str: User input string.
    """

    prompt_text = f"{field}: "
    value = input(prompt_text).strip()
    if lowercase:
        value = value.lower()
    return value


# Select minecraft loader type
def select_loader_type() -> str:
    mapping = {"1": "forge", "2": "neoforge", "3": "fabric", "4": "quilt", "5": "vanilla", "6": "other"}

    while True:
        print("\nSelect loader type:\n")
        print("1) Forge")
        print("2) NeoForge")
        print("3) Fabric")
        print("4) Quilt")
        print("5) Vanilla")
        print("6) Other\n")

        choice = prompt("Choose an option (1-6)", True)

        if choice in mapping:
            return mapping[choice]

        print("\nInvalid selection. Please choose a number between 1 and 6.")


# select java installation type
def select_java_installation() -> str:
    mapping = {"1": "local", "2": "system"}

    while True:
        print("\nSelect java installation mode:\n")
        print("1) Local installation (Uses bundled ./java/bin/java)")
        print("2) System installation (Uses JAVA from PATH)\n")

        choice = prompt("Choose an option (1-2)", True)

        if choice in mapping:
            return mapping[choice]

        print("\nInvalid selection. Please choose a number between 1 and 2.")


# Select jvm args
def select_jvm_args() -> str:
    mapping = {"1": "inline", "2": "file"}

    while True:
        print("\nSelect JVM args mode:\n")
        print("1) Inline (e.g. -Xms4G -Xmx8G)")
        print("2) File (e.g. user_jvm_args.txt)\n")

        choice = prompt("Choose an option (1-2)", True)

        if choice in mapping:
            return mapping[choice]

        print("\nInvalid selection. Please choose a number between 1 and 2.")
