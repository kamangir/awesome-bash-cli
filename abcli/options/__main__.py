import argparse

from . import *
from .. import keywords

list_of_tasks = "default,get,get_unpacked"

parser = argparse.ArgumentParser(name)
parser.add_argument(
    "task",
    type=str,
    default="",
    help=list_of_tasks,
)
parser.add_argument(
    "--options",
    type=str,
    default="",
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
parser.add_argument(
    "--is_int",
    type=int,
    default=0,
    help="0/1",
)
args = parser.parse_args()

success = args.task in list_of_tasks.split(",")
if args.task == "default":
    print(Options(args.options).default(args.keyword, args.default).to_str())
elif args.task == "get":
    print(
        (lambda output: int(output) if args.is_int == 1 else output)(
            Options(args.options).default(args.keyword, args.default)[args.keyword]
        )
    )
elif args.task == "get_unpacked":
    keyword_unpacked = keywords.pack(args.keyword)

    options = Options(args.options)

    output = options.default(
        keyword_unpacked, options.default(args.keyword, args.default)[args.keyword]
    )[keyword_unpacked]

    print(int(output) if args.is_int == 1 else output)
else:
    print(f"-{name}: {args.task}: command not found")

if not success:
    print(f"-{name}: {args.task}: failed")
