import argparse
import sys
from abcli import string, NAME
from abcli import file
from abcli.logger import logger
from blueness.argparse.generic import sys_exit

parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    help="replace|size",
)
parser.add_argument(
    "--filename",
    type=str,
)
parser.add_argument(
    "--this",
    type=str,
)
parser.add_argument(
    "--that",
    type=str,
)
args = parser.parse_args()

if args.task in ["replace"]:
    if not file.exist(args.filename):
        logger.error(f"-{NAME}: {args.task}: {args.filename}: file not found.")
        sys.exit(1)

success = False
if args.task == "replace":
    logger.info(f"{NAME}.{args.task}: {args.this} -> {args.that} in {args.filename}")

    success, content = file.load_text(args.filename)
    if success:
        content = [line.replace(args.this, args.that) for line in content]

        success = file.save_text(args.filename, content)
elif args.task == "size":
    print(string.pretty_bytes(file.size(args.filename)))
    success = True
else:
    success = None

sys_exit(logger, NAME, args.task, success)
