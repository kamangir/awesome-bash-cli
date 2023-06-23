import os
from abcli import logging
import logging

logger = logging.getLogger(__name__)

NAME = "abcli.plugins.seed"


def log(target: str):
    object_name = os.getenv("abcli_object_name", "")

    lines = []
    if target == "download_object":
        lines = [
            f"abcli select {object_name}",
            "abcli download",
            "open .",
        ]

    if not lines:
        logger.error(f"-{NAME}: seed: log({target}): target not found.")

    for line in lines:
        logger.info(line)
