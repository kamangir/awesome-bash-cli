from abcli import env
from abcli.logger import logger

logger.info(f"{env.abcli_object_name}: started.")

# --- your script here

logger.info("Hello World!")

# /script

logger.info(f"{env.abcli_object_name}: completed.")
