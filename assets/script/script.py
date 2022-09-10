import os
from abcli import logging
import logging

logger = logging.getLogger(__name__)

abcli_object_name = os.getenv("abcli_object_name")
logger.info(f"{abcli_object_name}: started.")

# --- your script here

logger.info("Hello World!")

# /script

logger.info(f"{abcli_object_name}: completed.")
