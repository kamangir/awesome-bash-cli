import os
from ... import *
from ... import string
from ... import logging
import logging

logger = logging.getLogger(__name__)

name = f"{shortname}.tasks.objects"


def signature(info=None):
    return [
        f"{os.getenv('abcli_object_name')}{'' if info is None else f'/{str(info)}'}",
        string.pretty_date(include_time=False),
        string.pretty_date(include_date=False, include_zone=True),
    ]
