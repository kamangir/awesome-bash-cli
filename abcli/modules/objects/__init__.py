import os
from abcli import string
from abcli import logging
import logging

logger = logging.getLogger(__name__)


def signature(info=None):
    return [
        "{}{}".format(
            os.getenv("ABCLI_OBJECT_NAME"),
            "" if info is None else f"/{str(info)}",
        ),
        string.pretty_date(include_time=False),
        string.pretty_date(include_date=False, include_zone=True),
    ]
