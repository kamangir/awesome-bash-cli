import argparse
from . import *
from abcli.logger import logger
from blueness.argparse.generic import sys_exit


parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    default="read",
    help="clone,create,read,search,write",
)
parser.add_argument(
    "--all",
    default=0,
    type=int,
)
parser.add_argument(
    "--dataframe",
    default=0,
    type=int,
)
parser.add_argument(
    "--destination",
    type=str,
    default="",
)
parser.add_argument(
    "--keyword",
    type=str,
)
parser.add_argument(
    "--like",
    default=0,
    type=int,
)
parser.add_argument(
    "--source",
    type=str,
    default="",
)
parser.add_argument(
    "--unique",
    default=1,
    type=int,
    help="cache.read('unique')",
)
parser.add_argument(
    "--value",
    type=str,
    default="unknown",
)
args = parser.parse_args()

success = False
if args.task == "clone":
    success = clone(args.source, args.destination)
elif args.task == "create":
    success = create()
elif args.task == "read":
    output = read(
        args.keyword,
        all=args.all,
        like=args.like,
        dataframe=args.dataframe,
        unique=args.unique,
    )

    print(
        ("None" if output.empty else output.drop(columns=["log_id"]))
        if args.dataframe
        else output
    )
    success = True
elif args.task == "search":
    for keyword, value in search(args.keyword).items():
        print(f"{keyword}: {value}")
    success = True
elif args.task == "write":
    success = write(args.keyword, args.value)
else:
    success = None

sys_exit(logger, NAME, args.task, success)
