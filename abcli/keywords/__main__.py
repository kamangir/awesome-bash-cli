import argparse
from . import NAME, pack, KEYWORDS

list_of_tasks = "pack|unpack"

parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="",
    help=list_of_tasks,
)
parser.add_argument(
    "--keyword",
    type=str,
    default="",
)
parser.add_argument(
    "--default",
    type=str,
    default="",
)
args = parser.parse_args()

success = args.task in list_of_tasks.split("|")
if args.task == "pack":
    print(
        (lambda output: args.default if output in ",-".split(",") else output)(
            pack(args.keyword)
        )
    )
elif args.task == "unpack":
    print(
        (lambda output: args.default if output in ",-".split(",") else output)(
            KEYWORDS.get(args.keyword, args.keyword)
        )
    )
else:
    print(f"-{NAME}: {args.task}: command not found")

if not success:
    print(f"-{NAME}: {args.task}: failed")
