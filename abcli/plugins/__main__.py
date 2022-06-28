import argparse
from . import *

parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="list_of_external",
)
parser.add_argument(
    "--delim",
    type=str,
    default=", ",
)
parser.add_argument(
    "--log",
    default=0,
    type=int,
    help="0/1",
)
args = parser.parse_args()

delim = ", " if args.log else " " if args.delim == "space" else args.delim

success = False
if args.task == "list_of_external":
    output = list_of_external()
    if args.log:
        logger.info("{:,} external plugin(s): {}".format(len(output), output))
    else:
        print(delim.join(output))
    success = True
else:
    logger.error(f"-{name}: {args.task}: command not found.")

if not success:
    logger.error(f"-{name}: {args.task}: failed.")
