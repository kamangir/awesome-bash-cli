from .. import *

name = f"{shortname}.options"


keywords = {
    "!": "run",
    "?": "help",
    "V": "verbose",
    "--help": "help",
    "T": "terraform",
    "abcli": "awesome-bash-cli",
    "bld": "build",
    "br": "browse",
    "cce": "create_conda_env",
    "det": "detect",
    "dl": "download",
    "eval": "evaluate",
    "id": "identify",
    "ing": "ingest",
    "ls": "list",
    "op": "open",
    "pk": "pack_keyword",
    "pr": "predict",
    "pub": "publish",
    "rndr": "render",
    "sel": "select",
    "sl": "solid",
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
    return {v: k for k, v in keywords.items()}.get(keyword, keyword)