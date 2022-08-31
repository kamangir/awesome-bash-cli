import os
import os.path
from abcli import file
from abcli import logging
import logging

logger = logging.getLogger(__name__)

NAME = "abcli.modules.host"

_, cookie = file.load_json(
    os.path.join(
        os.getenv("abcli_path_cookie", ""),
        "cookie.json",
    ),
    "civilized",
)

# for item in cookie:
#    logger.info(f"{NAME}: cookie: {item}: {cookie[item]}")

HOST_NAME = None

HOST_TAGS = None

from .functions import *
