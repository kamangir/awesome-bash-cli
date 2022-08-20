from .keywords import KEYWORDS


def pack(keyword):
    """pack keyword.

    Args:
        keyword (str): keyword.

    Returns:
        str: packed keyword.
    """
    return {v: k for k, v in KEYWORDS.items()}.get(keyword, keyword)
