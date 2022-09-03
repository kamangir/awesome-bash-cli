import os
from abcli import file

cookie_filename = os.path.join(os.getenv("abcli_path_cookie", ""), "cookie.json")

_, cookie = file.load_json(cookie_filename, "civilized")

# for item in cookie:
#    logger.info(f"{NAME}: cookie: {item}: {cookie[item]}")

NAME = "abcli.modules.cookie"
