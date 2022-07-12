from .. import *

name = f"{shortname}.options"


keywords = {
    "!": "run",
    "?": "help",
    "V": "verbose",
    "--help": "help",
    "I": "install",
    "P": "plugins",
    "T": "terraform",
    "abcli": "awesome-bash-cli",
    "am": "add_month",
    "bld": "build",
    "br": "browser",
    "bw": "blue-wiki",
    "bwiki": "blue-wiki",
    "ce": "create_env",
    "det": "detect",
    "dl": "download",
    "em": "earthdaily_mosaic",
    "eval": "evaluate",
    "ic": "image_classifier",
    "id": "identify",
    "ing": "ingest",
    "le": "list_of_external",
    "ls": "list",
    "obj": "object",
    "op": "open",
    "pk": "pack_keyword",
    "pr": "predict",
    "pub": "publish",
    "rndr": "render",
    "sel": "select",
    "sl": "solid",
    "tf": "training_framework",
    "tr": "train",
    "uf": "update_fork",
    "uk": "unpack_keyword",
    "ul": "upload",
    "up": "upload",
    "upd": "update",
    "val": "validate",
    "video": "create_video",
    "yolo": "yolov5",
    "yt": "youtube",
}


def pack(keyword):
    """pack keyword.

    Args:
        keyword (str): keyword.

    Returns:
        str: packed keyword.
    """
    return {v: k for k, v in keywords.items()}.get(keyword, keyword)
