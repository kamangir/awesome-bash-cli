import os
from abcli import file

NAME = "abcli.modules.cookie"

cookie_filename = os.path.join(os.getenv("abcli_path_cookie", ""), "cookie.json")

_, cookie = file.load_json(cookie_filename, "civilized")

# for keyword in cookie:
#    print(f"{NAME}: {keyword}: {cookie[keyword]}")
