import os
from abcli import string


def signature(info=None):
    return [
        "{}{}".format(
            os.getenv("abcli_object_name", ""),
            "" if info is None else f"/{str(info)}",
        ),
        string.pretty_date(include_time=False),
        string.pretty_date(include_date=False, include_zone=True),
    ]
