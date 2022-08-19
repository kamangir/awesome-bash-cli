from abcli.keywords import keywords

NAME = f"abcli.keywords"


def pack(keyword):
    """pack keyword.

    Args:
        keyword (str): keyword.

    Returns:
        str: packed keyword.
    """
    return {v: k for k, v in keywords.items()}.get(keyword, keyword)
