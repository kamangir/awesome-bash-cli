import argparse
from . import *

parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="get_from_json",
)
parser.add_argument(
    "--default",
    type=str,
    default="",
)
parser.add_argument(
    "--thing",
    type=str,
    default="",
)

args = parser.parse_args()

success = True
if args.task == "get_from_json":
    print(get_from_json(args.thing, args.default))
    success = True
else:
    logger.error(f"-{name}: {args.task}: command not found.")

if not success:
    logger.error(f"-{name}: {args.task}: failed.")
