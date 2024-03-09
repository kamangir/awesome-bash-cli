import argparse
from abcli import string, NAME
from abcli.file import size
from abcli.file import load_text, save_text
from abcli.logger import logger

parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    help="size",
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

success = False
if args.task == "replace":
    logger.info(f"{NAME}.{args.task}: {args.this} -> {args.that} in {args.filename}")
    success, content = load_text(args.filename)
    if success:
        content = [line.replace(args.this, args.that) for line in content]

        success = save_text(args.filename, content)
elif args.task == "size":
    print(string.pretty_bytes(size(args.filename)))
    success = True
else:
    logger.error(f"-{NAME}: {args.task}: command not found.")

if not success:
    logger.error(f"-{NAME}: {args.task}: failed.")
