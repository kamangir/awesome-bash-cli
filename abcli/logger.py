from abcli import env
import logging
from logging.handlers import RotatingFileHandler
import os

# to hide "botocore.credentials Found credentials in environment variables."
logging.getLogger("botocore.credentials").setLevel(logging.WARNING)


abcli_log_filename = env.abcli_log_filename

# Based on https://stackoverflow.com/a/22313803
logging.addLevelName(logging.INFO, "")
logging.addLevelName(logging.DEBUG, "❓ ")
logging.addLevelName(logging.ERROR, "❗️ ")
logging.addLevelName(logging.WARNING, "⚠️  ")

logging_level = logging.INFO

logging.getLogger().setLevel(logging_level)

log_formatter = logging.Formatter("%(levelname)s%(name)s %(message)s")
try:
    file_handler = RotatingFileHandler(
        abcli_log_filename,
        maxBytes=10485760,
        backupCount=10000,
    )
    file_handler.setLevel(logging_level)
    file_handler.setFormatter(log_formatter)
    logging.getLogger().addHandler(file_handler)
except:
    pass

console_handler = logging.StreamHandler()
console_handler.setLevel(logging_level)
console_handler.setFormatter(log_formatter)
logging.getLogger().addHandler(console_handler)

logger = logging.getLogger("::")


def crash_report(description):
    # https://stackoverflow.com/a/10645855
    logger.error(f"crash: {description}", exc_info=1)


def get_logger(ICON):
    return logging.getLogger(f"{ICON} ")
