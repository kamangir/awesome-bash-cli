import logging
from logging.handlers import RotatingFileHandler
import os

logger = logging.getLogger(__name__)


def crash_report(description):

    logger.info(f"crash: {description}")

    # https://stackoverflow.com/a/10645855
    logging.error("exception ", exc_info=1)


abcli_log_filename = os.getenv("abcli_log_filename", "abcli.log")

# Based on https://stackoverflow.com/a/22313803
logging.addLevelName(logging.INFO, "")
logging.addLevelName(logging.DEBUG, "")

logging_level = logging.INFO
# logging_level = logging.DEBUG

logging.getLogger().setLevel(logging_level)

log_formatter = logging.Formatter("%(message)s")

try:
    logger_file_handler = RotatingFileHandler(
        abcli_log_filename, maxBytes=10485760, backupCount=10000
    )
    logger_file_handler.setLevel(logging_level)
    logger_file_handler.setFormatter(log_formatter)
    logging.getLogger().addHandler(logger_file_handler)
except:
    pass

logger_console_handler = logging.StreamHandler()
logger_console_handler.setLevel(logging_level)
logger_console_handler.setFormatter(log_formatter)
logging.getLogger().addHandler(logger_console_handler)
