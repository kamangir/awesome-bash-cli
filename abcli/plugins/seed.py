from abcli import NAME
from blue_objects.env import abcli_object_name
from abcli.logger import logger


NAME = f"{NAME}.plugins.seed"


def log(
    object_name: str = ".",
    target: str = "open_object",
):
    object_name = abcli_object_name if object_name == "." else object_name

    lines = []
    if target == "download_object":
        lines = [
            f"abcli select {object_name}",
            "abcli download",
            "open .",
        ]
    elif target == "open_object":
        lines = [
            f"abcli select {object_name}",
            "open .",
        ]

    if not lines:
        logger.error(f"-{NAME}: seed: log({target}): target not found.")
    else:
        logger.info("; ".join(lines))
