import argparse
from . import *
from . import *
from . import string
from .funcs import *
from . import logging
import logging

logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    help="size",
)
parser.add_argument(
    "--filename",
    type=str,
)
args = parser.parse_args()

success = False
if args.task == "size":
    print(string.pretty_bytes(size(args.filename)))
    success = True
else:
    logger.error(f"-{name}: {args.task}: command not found.")

if not success:
    logger.error(f"-{name}: {args.task}: failed.")
