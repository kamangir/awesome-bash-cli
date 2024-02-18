import argparse
from abcli import file
from . import *
from abcli.logging import logger


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="",
    help="read|write",
)
parser.add_argument(
    "--default",
    type=str,
    default="",
)
parser.add_argument(
    "--keyword",
    type=str,
    default="",
)
parser.add_argument(
    "--value",
    type=str,
    default="",
)

args = parser.parse_args()

success = True
if args.task == "read":
    print(cookie.get(args.keyword, args.default))
elif args.task == "write":
    cookie[args.keyword] = args.value
    success = file.save_json(cookie_filename, cookie)
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
