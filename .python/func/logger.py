import logging
from pathlib import Path

# File di log
LOG_FILE = Path("app.log")

# Colori ANSI per console
COLORS = {
    "DEBUG": "\033[94m",    # blu
    "INFO": "\033[92m",     # verde
    "WARNING": "\033[93m",  # giallo
    "ERROR": "\033[91m",    # rosso
    "CRITICAL": "\033[95m", # magenta
}
RESET_COLOR = "\033[0m"

# === Logger singleton ===
logger = logging.getLogger("my_logger")
logger.setLevel(logging.DEBUG)
logger.handlers.clear()

# Formatter per file (nessun colore)
file_formatter = logging.Formatter(
    "[%(asctime)s] [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

# FileHandler sempre attivo
file_handler = logging.FileHandler(LOG_FILE, encoding="utf-8")
file_handler.setLevel(logging.DEBUG)
file_handler.setFormatter(file_formatter)
logger.addHandler(file_handler)

# ConsoleHandler: personalizzato per mostrare colore solo DEBUG
class DebugOnlyConsoleHandler(logging.StreamHandler):
    def emit(self, record):
        # Se è DEBUG, coloralo
        if record.levelno == logging.DEBUG:
            record.msg = f"{COLORS['DEBUG']}{record.msg}{RESET_COLOR}"
        super().emit(record)

console_handler = DebugOnlyConsoleHandler()
console_handler.setLevel(logging.DEBUG)
console_formatter = logging.Formatter("[%(levelname)s] %(message)s")
console_handler.setFormatter(console_formatter)
logger.addHandler(console_handler)

# === Funzioni wrapper ===
def log_debug(msg):
    logger.debug(msg)

def log_info(msg):
    logger.info(msg)

def log_warning(msg):
    logger.warning(msg)

def log_error(msg):
    logger.error(msg)

def log_critical(msg):
    logger.critical(msg)
