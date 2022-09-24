import argparse
from . import *

list_of_tasks = "after|before|pretty_date|random"


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    help=list_of_tasks,
)
parser.add_argument(
    "--include_time",
    type=int,
    help="0|1",
    default=1,
)
parser.add_argument(
    "--length",
    type=int,
    default=16,
)
parser.add_argument(
    "--string",
    type=str,
)
parser.add_argument(
    "--substring",
    type=str,
)
parser.add_argument(
    "--unique",
    type=int,
    help="0|1",
    default=0,
)
args = parser.parse_args()

success = args.task in list_of_tasks.split("|")
if args.task == "after":
    print(after(args.string, args.substring))
elif args.task == "before":
    print(before(args.string, args.substring))
elif args.task == "pretty_date":
    print(
        pretty_date(
            as_filename=True,
            include_time=args.include_time,
            unique=args.unique,
        )
    )
elif args.task == "random":
    print(random_(args.length))
else:
    print(f"-{NAME}: {args.task}: command not found")

if not success:
    print(f"-{NAME}: {args.task}: failed")
