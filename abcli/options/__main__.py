import argparse
from . import NAME, Options

list_of_tasks = "choice|get|subset"

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
    "--subset",
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
elif args.task == "get":
    output = Options(args.options).get(args.keyword, args.default)
    print((int(output) if output else 0) if args.is_int == 1 else output)
elif args.task == "subset":
    options = Options(args.options)
    subset = Options(args.subset)

    print(
        Options(
            {
                keyword: options.get(
                    keyword,
                    value,
                )
                for keyword, value in subset.items()
            }
        ).to_str()
    )
else:
    print(f"-{NAME}: {args.task}: command not found")

if not success:
    print(f"-{NAME}: {args.task}: failed")
