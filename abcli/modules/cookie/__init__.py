import os
from abcli import file

_, cookie = file.load_json(
    os.path.join(
        os.getenv("abcli_path_cookie", ""),
        "cookie.json",
    ),
    "civilized",
)

# for item in cookie:
#    logger.info(f"{NAME}: cookie: {item}: {cookie[item]}")
