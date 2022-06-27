import argparse
from . import *
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
    else:
        print('host: cannot get "{}"'.format(args.keyword))
else:
    logger.error(f"-{name}: {args.task}: command not found")

if not success:
    logger.error(f"-{name}: {args.task}: failed")
