from abcli.keywords.keywords import KEYWORDS


def pack(keyword: str) -> str:
    return {v: k for k, v in KEYWORDS.items()}.get(keyword, keyword)
