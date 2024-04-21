import argparse
from abcli.bash.colors import GREEN, NC

NAME = "abcli.bash.list"


LIST_OF_TASKS = "in|intersect|item|len|log|nonempty|resize|sort"

parser = argparse.ArgumentParser(NAME)
parser.add_argument(
    "task",
    type=str,
    help=LIST_OF_TASKS,
)
parser.add_argument(
    "--after",
    type=str,
    default="item(s)",
)
parser.add_argument(
    "--before",
    type=str,
    default="list of",
)
parser.add_argument(
    "--count",
    type=int,
)
parser.add_argument(
    "--delim",
    type=str,
    default=",",
)
parser.add_argument(
    "--index",
    type=int,
)
parser.add_argument(
    "--item",
    type=str,
)
parser.add_argument(
    "--items",
    type=str,
)
parser.add_argument(
    "--items_1",
    type=str,
)
parser.add_argument(
    "--items_2",
    type=str,
)
parser.add_argument(
    "--unique",
    type=int,
    help="0|1",
    default=0,
)
args = parser.parse_args()

delim = " " if args.delim == "space" else args.delim

list_of_items = (
    [item for item in args.items.split(delim) if item]
    if isinstance(args.items, str)
    else None
)

success = args.task in LIST_OF_TASKS.split("|")
if args.task == "in":
    print("True" if args.item in list_of_items else "False")
elif args.task == "intersect":
    print(
        delim.join(
            [
                item
                for item in args.items_1.split(delim)
                if item in args.items_2.split(delim) and item
            ]
        )
    )
elif args.task == "item":
    print(list_of_items[args.index])
elif args.task == "len":
    print(len(list_of_items))
elif args.task == "log":
    print(
        "{} {} {}: {}".format(
            args.before,
            f"{GREEN}{len(list_of_items)}{NC}",
            args.after,
            "{}{}{}.".format(
                GREEN,
                f"{NC}, {GREEN}".join(list_of_items),
                NC,
            ),
        )
    )
elif args.task == "nonempty":
    print(delim.join(list_of_items))
elif args.task == "resize":
    print(delim.join(list_of_items[: args.count]))
elif args.task == "sort":
    if args.unique:
        list_of_items = list(set(list_of_items))

    print(delim.join(sorted(list_of_items)))
else:
    print(f"-{NAME}: {args.task}: command not found")

if not success:
    print(f"-{NAME}: {args.task}: failed")
