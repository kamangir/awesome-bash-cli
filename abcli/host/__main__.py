import argparse
from . import *
from ..tags.utils import *
from .. import logging
import logging

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    default="get",
    help="get,sign",
)
parser.add_argument(
    "--filename",
    type=str,
    default="",
)
parser.add_argument(
    "--name",
    type=str,
    default=".",
)
parser.add_argument(
    "--keyword",
    type=str,
    help="name/tags",
)
args = parser.parse_args()

success = False
if args.task == "get":
    if args.keyword == "name":
        print(get_name())
        success = True
    elif args.keyword == "tags":
        print(",".join(get(args.name if args.name not in ",.".split(",") else name)))
        success = True
    else:
        logger.error(f"-{name}: get: {args.keyword}: unknown keyword.")
        print("unknown")
else:
    logger.error(f"-{name}: {args.task}: command not found.")

if not success:
    logger.error(f"-{name}: {args.task}: failed.")
