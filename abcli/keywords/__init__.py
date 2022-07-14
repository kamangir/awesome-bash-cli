from .. import *
from .keywords import keywords

name = f"{shortname}.keywords"


def pack(keyword):
    """pack keyword.

    Args:
        keyword (str): keyword.

    Returns:
        str: packed keyword.
    """
    return {v: k for k, v in keywords.items()}.get(keyword, keyword)
