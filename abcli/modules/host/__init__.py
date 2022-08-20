import os
import os.path
from abcli import file

NAME = "abcli.modules.host"

_, cookie = file.load_json(
    os.path.join(
        os.getenv("abcli_path_cookie", ""),
        "cookie.json",
    )
)

HOST_NAME = None

HOST_TAGS = None

from .functions import *
