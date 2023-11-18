import argparse
from . import *
from abcli import keywords

list_of_tasks = "choice|default|get"

parser = argparse.ArgumentParser(NAME)
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
    "--choices",
    type=str,
    default="",
)
parser.add_argument(
    "--default",
    type=str,
    default="",
)
parser.add_argument(
    "--delim",
    type=str,
    default=",",
)
parser.add_argument(
    "--is_int",
    type=int,
    default=0,
    help="0|1",
)
args = parser.parse_args()

delim = " " if args.delim == "space" else args.delim

success = args.task in list_of_tasks.split("|")
if args.task == "choice":
    options = Options(args.options)

    found = False
    for keyword in args.choices.split(","):
        if options.get(keyword, 0):
            print(keyword)
            found = True
            break

    if not found:
        print(args.default)
elif args.task == "default":
    print(Options(args.options).default(args.keyword, args.default).to_str())
elif args.task == "get":
    print(
        (lambda output: int(output) if args.is_int == 1 else output)(
            Options(args.options).default(args.keyword, args.default)[args.keyword]
        )
    )
else:
    print(f"-{NAME}: {args.task}: command not found")

if not success:
    print(f"-{NAME}: {args.task}: failed")
